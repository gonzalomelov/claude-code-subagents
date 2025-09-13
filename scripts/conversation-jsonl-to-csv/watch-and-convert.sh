#!/bin/bash
# Simple file watcher for JSONL files that runs jsonl-to-csv.sh on changes
# No external dependencies required - uses polling to detect changes

# Configuration
WATCH_DIR="${1:-.}"  # Directory to watch (default: current directory)
CHECK_INTERVAL=2      # Check for changes every 2 seconds
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONVERTER_SCRIPT="$SCRIPT_DIR/jsonl-to-csv.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if converter script exists
if [ ! -f "$CONVERTER_SCRIPT" ]; then
    echo -e "${RED}Error: jsonl-to-csv.sh not found at $CONVERTER_SCRIPT${NC}"
    exit 1
fi

# Make sure converter script is executable
chmod +x "$CONVERTER_SCRIPT"

echo -e "${BLUE}📁 Watching directory: $WATCH_DIR${NC}"
echo -e "${BLUE}🔄 Check interval: ${CHECK_INTERVAL}s${NC}"
echo -e "${GREEN}✅ Ready! Monitoring for JSONL file changes...${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
echo ""

# Store file states in a temporary file (bash 3.2 compatible)
TEMP_FILE_TIMES="/tmp/watch_file_times_$$"

# Function to get all JSONL files and their modification times
get_jsonl_files() {
    find "$WATCH_DIR" -name "*.jsonl" -type f 2>/dev/null | while read -r file; do
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            mod_time=$(stat -f "%m" "$file" 2>/dev/null)
        else
            # Linux
            mod_time=$(stat -c "%Y" "$file" 2>/dev/null)
        fi
        echo "$mod_time:$file"
    done
}

# Initialize file times
get_jsonl_files > "$TEMP_FILE_TIMES"

# Function to convert a file
convert_file() {
    local file="$1"
    local file_dir=$(dirname "$file")
    local file_name=$(basename "$file" .jsonl)
    local basename=$(basename "$file")
    
    # Create csv-minified directory if it doesn't exist
    local output_dir="$file_dir/csv-minified"
    if [ ! -d "$output_dir" ]; then
        echo -e "${BLUE}📁 Creating directory: $output_dir${NC}"
        mkdir -p "$output_dir"
    fi
    
    # Set output path
    local output_file="$output_dir/${file_name}.csv"
    
    echo -e "${YELLOW}🔄 Converting: $basename${NC}"
    echo -e "${BLUE}   → Output: csv-minified/${file_name}.csv${NC}"
    
    # Run the converter script with explicit output path
    if "$CONVERTER_SCRIPT" "$file" "$output_file" 2>&1 | sed 's/^/   /'; then
        echo -e "${GREEN}   ✅ Successfully converted $basename${NC}"
    else
        echo -e "${RED}   ❌ Failed to convert $basename${NC}"
    fi
    echo ""
}

# Cleanup function
cleanup() {
    rm -f "$TEMP_FILE_TIMES" "$TEMP_FILE_TIMES.new"
    exit 0
}
trap cleanup EXIT INT TERM

# Main watching loop
while true; do
    # Get current file states
    get_jsonl_files > "$TEMP_FILE_TIMES.new"
    
    # Compare with previous states
    if [ -f "$TEMP_FILE_TIMES" ]; then
        # Find new and changed files
        while IFS=':' read -r mod_time file; do
            if [ -n "$file" ]; then
                # Check if file existed before
                old_entry=$(grep ":$file$" "$TEMP_FILE_TIMES" 2>/dev/null || echo "")
                if [ -z "$old_entry" ]; then
                    # New file
                    echo -e "${GREEN}🆕 New file detected: $(basename "$file")${NC}"
                    convert_file "$file"
                else
                    # Check if modified
                    old_mod_time=$(echo "$old_entry" | cut -d: -f1)
                    if [ "$mod_time" != "$old_mod_time" ]; then
                        echo -e "${BLUE}📝 File modified: $(basename "$file")${NC}"
                        convert_file "$file"
                    fi
                fi
            fi
        done < "$TEMP_FILE_TIMES.new"
    else
        # First run - convert all existing files
        while IFS=':' read -r mod_time file; do
            if [ -n "$file" ]; then
                echo -e "${GREEN}🆕 Processing existing file: $(basename "$file")${NC}"
                convert_file "$file"
            fi
        done < "$TEMP_FILE_TIMES.new"
    fi
    
    # Update the stored states
    mv "$TEMP_FILE_TIMES.new" "$TEMP_FILE_TIMES"
    
    # Sleep before next check
    sleep "$CHECK_INTERVAL"
done