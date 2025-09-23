#!/bin/bash
# Batch convert all JSONL files to CSV in csv-minified folders
# Usage: ./batch-convert-all.sh [base_directory]

BASE_DIR="${1:-$HOME/.claude/projects}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONVERTER_SCRIPT="$SCRIPT_DIR/jsonl-to-csv.py"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Statistics
total_files=0
processed_files=0
failed_files=0
total_original_size=0
total_compressed_size=0
start_time=$(date +%s)

echo -e "${CYAN}🚀 Starting batch conversion of JSONL files${NC}"
echo -e "${BLUE}Base directory: $BASE_DIR${NC}"
echo -e "${BLUE}Converter script: $CONVERTER_SCRIPT${NC}"
echo ""

# Check if converter script exists
if [ ! -f "$CONVERTER_SCRIPT" ]; then
    echo -e "${RED}Error: jsonl-to-csv.py not found at $CONVERTER_SCRIPT${NC}"
    exit 1
fi

# Make sure converter script is executable
chmod +x "$CONVERTER_SCRIPT"

# Function to get file size in bytes
get_file_size() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        stat -f%z "$1" 2>/dev/null || echo 0
    else
        # Linux
        stat -c%s "$1" 2>/dev/null || echo 0
    fi
}

# Function to convert bytes to human readable format
human_readable() {
    local bytes=$1
    if [ $bytes -gt 1073741824 ]; then
        echo "$(($bytes / 1073741824))GB"
    elif [ $bytes -gt 1048576 ]; then
        echo "$(($bytes / 1048576))MB"
    elif [ $bytes -gt 1024 ]; then
        echo "$(($bytes / 1024))KB"
    else
        echo "${bytes}B"
    fi
}

# Function to process a directory
process_directory() {
    local dir="$1"
    local dir_name=$(basename "$dir")
    
    # Count JSONL files in this directory
    local jsonl_count=$(find "$dir" -maxdepth 1 -name "*.jsonl" -type f 2>/dev/null | wc -l)
    
    if [ $jsonl_count -eq 0 ]; then
        return 0
    fi
    
    echo -e "${YELLOW}📁 Processing directory: $dir_name ($jsonl_count files)${NC}"
    
    # Create csv-minified directory if it doesn't exist
    local output_dir="$dir/csv-minified"
    if [ ! -d "$output_dir" ]; then
        echo -e "${BLUE}   📁 Creating directory: csv-minified${NC}"
        mkdir -p "$output_dir"
    fi
    
    local dir_processed=0
    local dir_failed=0
    local dir_original_size=0
    local dir_compressed_size=0
    
    # Process each JSONL file in the directory
    find "$dir" -maxdepth 1 -name "*.jsonl" -type f 2>/dev/null | while read -r jsonl_file; do
        local file_name=$(basename "$jsonl_file" .jsonl)
        local csv_file="$output_dir/${file_name}.csv"
        
        # Skip if CSV already exists and is newer than JSONL
        if [ -f "$csv_file" ] && [ "$csv_file" -nt "$jsonl_file" ]; then
            echo -e "${BLUE}   ⏭️  Skipping (CSV exists): $file_name${NC}"
            continue
        fi
        
        echo -e "${CYAN}   🔄 Converting: $file_name${NC}"
        
        # Get original file size
        local original_size=$(get_file_size "$jsonl_file")
        
        # Run conversion with Python
        if python3 "$CONVERTER_SCRIPT" "$jsonl_file" "$csv_file" >/dev/null 2>&1; then
            local compressed_size=$(get_file_size "$csv_file")
            local reduction=$(( (original_size - compressed_size) * 100 / original_size ))
            
            echo -e "${GREEN}   ✅ Success: $(human_readable $original_size) → $(human_readable $compressed_size) (${reduction}% reduction)${NC}"
            
            dir_processed=$((dir_processed + 1))
            dir_original_size=$((dir_original_size + original_size))
            dir_compressed_size=$((dir_compressed_size + compressed_size))
        else
            echo -e "${RED}   ❌ Failed: $file_name${NC}"
            dir_failed=$((dir_failed + 1))
        fi
    done
    
    # Update totals (note: these won't work in subshell, but we'll recalculate at the end)
    echo -e "${BLUE}   📊 Directory summary: $dir_processed processed, $dir_failed failed${NC}"
    echo ""
}

echo -e "${CYAN}🔍 Scanning for directories with JSONL files...${NC}"

# Find all directories with JSONL files and sort by file count (largest first)
directories_with_files=$(for dir in "$BASE_DIR"/*; do
    if [ -d "$dir" ] && [ "$(basename "$dir")" != "csv-minified" ]; then
        count=$(find "$dir" -maxdepth 1 -name "*.jsonl" -type f 2>/dev/null | wc -l)
        if [ $count -gt 0 ]; then
            echo "$count:$dir"
        fi
    fi
done | sort -nr)

total_directories=$(echo "$directories_with_files" | wc -l)
echo -e "${BLUE}Found $total_directories directories with JSONL files${NC}"
echo ""

# Process each directory
echo "$directories_with_files" | while IFS=':' read -r count dir_path; do
    process_directory "$dir_path"
done

# Calculate final statistics
echo -e "${CYAN}📊 Final Statistics:${NC}"
total_files=$(find "$BASE_DIR" -name "*.jsonl" -type f 2>/dev/null | wc -l)
total_csv_files=$(find "$BASE_DIR" -path "*/csv-minified/*.csv" -type f 2>/dev/null | wc -l)

# Calculate total sizes
total_original_size=0
total_compressed_size=0
find "$BASE_DIR" -name "*.jsonl" -type f 2>/dev/null | while read -r file; do
    size=$(get_file_size "$file")
    total_original_size=$((total_original_size + size))
done

find "$BASE_DIR" -path "*/csv-minified/*.csv" -type f 2>/dev/null | while read -r file; do
    size=$(get_file_size "$file")
    total_compressed_size=$((total_compressed_size + size))
done

end_time=$(date +%s)
duration=$((end_time - start_time))

echo -e "${GREEN}✅ Batch conversion completed!${NC}"
echo -e "${BLUE}Total JSONL files: $total_files${NC}"
echo -e "${BLUE}Total CSV files: $total_csv_files${NC}"
echo -e "${BLUE}Processing time: ${duration} seconds${NC}"
echo -e "${BLUE}All conversions saved to csv-minified/ subdirectories${NC}"