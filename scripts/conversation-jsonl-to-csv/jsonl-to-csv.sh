#!/bin/bash
# Convert Claude Code JSONL conversation files to compact CSV format
# Usage: ./jsonl-to-csv.sh /path/to/input.jsonl [/path/to/output.csv]

if [ $# -eq 0 ]; then
    echo "Usage: $0 /path/to/input.jsonl [/path/to/output.csv]"
    echo "Converts Claude Code JSONL conversation files to compact CSV format"
    echo "If output.csv is not specified, uses input filename with .csv extension"
    echo "Supports full paths - input and output can be anywhere on the filesystem"
    exit 1
fi

INPUT_FILE="$1"
# Extract directory and filename for default output
INPUT_DIR=$(dirname "$INPUT_FILE")
INPUT_BASENAME=$(basename "$INPUT_FILE" .jsonl)
OUTPUT_FILE="${2:-${INPUT_DIR}/${INPUT_BASENAME}.csv}"

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found"
    exit 1
fi

echo "Converting $INPUT_FILE to CSV format..."

# Step 1: Remove metadata and trim content, then convert to CSV
jq -c '{
  type: .type,
  timestamp: .timestamp,
  description: (
    if .type == "system" and .content? then
      (.content[:250] + if (.content | length) > 250 then "..." else "" end)
    elif .message.content? then
      # Handle string content (direct text)
      if (.message.content | type) == "string" then
        (.message.content[:250] + if (.message.content | length) > 250 then "..." else "" end)
      # Handle array content (structured messages)
      elif (.message.content | type) == "array" and (.message.content | length) > 0 then
        if .message.content[0].content? and (.message.content[0].content | type) == "array" and (.message.content[0].content | length) > 0 and .message.content[0].content[0].text? then
          (.message.content[0].content[0].text[:250] + if (.message.content[0].content[0].text | length) > 250 then "..." else "" end)
        elif .message.content[0].type? and .message.content[0].type == "tool_result" and .message.content[0].content? then
          if (.message.content[0].content | type) == "string" then
            (.message.content[0].content[:250] + if (.message.content[0].content | length) > 250 then "..." else "" end)
          elif (.message.content[0].content | type) == "array" and (.message.content[0].content | length) > 0 and .message.content[0].content[0].text? then
            (.message.content[0].content[0].text[:250] + if (.message.content[0].content[0].text | length) > 250 then "..." else "" end)
          else
            "Tool result content"
          end
        elif .message.content[0].type? and .message.content[0].type == "tool_use" and .message.content[0].name? then
          ("Tool: " + .message.content[0].name + " " + (.message.content[0].input | to_entries | map("\(.key)=\(.value)") | join(" ") | .[:200]) + if ((.message.content[0].input | to_entries | map("\(.key)=\(.value)") | join(" ")) | length) > 200 then "..." else "" end)
        elif .message.content[0].type? and .message.content[0].type == "text" and .message.content[0].text? then
          (.message.content[0].text[:250] + if (.message.content[0].text | length) > 250 then "..." else "" end)
        else
          "No content"
        end
      else
        "Empty content array"
      end
    else
      "No message content"
    end
  )
}' "$INPUT_FILE" | \
jq -r '[.type, .timestamp, (.description | gsub("\n"; " ") | gsub("\r"; "") | gsub("\""; "\"\""))] | @csv' > "$OUTPUT_FILE"

if [ $? -eq 0 ]; then
    ORIGINAL_SIZE=$(du -h "$INPUT_FILE" | cut -f1)
    COMPRESSED_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
    echo "✅ Conversion complete!"
    echo "   Original: $ORIGINAL_SIZE"
    echo "   CSV: $COMPRESSED_SIZE"
    echo "   Output: $OUTPUT_FILE"
else
    echo "❌ Conversion failed"
    exit 1
fi