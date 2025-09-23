#!/usr/bin/env python3
"""
Convert Claude Code JSONL conversation files to compact CSV format with smart trimming.
Read file responses are trimmed to 150 chars, other content is trimmed to 500 chars.
"""

import json
import csv
import sys
import os
from pathlib import Path

def is_read_tool_call(msg):
    """Check if a message is a Read tool call"""
    if msg.get('type') != 'assistant':
        return False

    content = msg.get('message', {}).get('content')
    if not content:
        return False

    # Handle string content
    if isinstance(content, str):
        return 'Tool: Read file_path=' in content

    # Handle array content
    if isinstance(content, list) and len(content) > 0:
        first_item = content[0]
        return (first_item.get('type') == 'tool_use' and
                first_item.get('name') == 'Read')

    return False

def extract_description(msg, is_read_response=False):
    """Extract description from a message, with smart trimming"""
    trim_length = 150 if is_read_response else 500

    # System message
    if msg.get('type') == 'system' and msg.get('content'):
        content = msg['content']
        if trim_length and len(content) > trim_length:
            return content[:trim_length] + "..."
        return content

    # Message with content
    message_content = msg.get('message', {}).get('content')
    if not message_content:
        return "No message content"

    # Handle string content
    if isinstance(message_content, str):
        if trim_length and len(message_content) > trim_length:
            return message_content[:trim_length] + "..."
        return message_content

    # Handle array content
    if isinstance(message_content, list) and len(message_content) > 0:
        first_item = message_content[0]

        # Handle nested content structure
        if first_item.get('content'):
            content = first_item['content']

            # Nested array with text
            if isinstance(content, list) and len(content) > 0:
                text = content[0].get('text', '')
                if trim_length and len(text) > trim_length:
                    return text[:trim_length] + "..."
                return text

            # Direct string content
            if isinstance(content, str):
                if trim_length and len(content) > trim_length:
                    return content[:trim_length] + "..."
                return content

            return "Tool result content"

        # Tool use
        if first_item.get('type') == 'tool_use' and first_item.get('name'):
            tool_input = first_item.get('input', {})
            params = ' '.join(f"{k}={v}" for k, v in tool_input.items())
            return f"Tool: {first_item['name']} {params}"

        # Direct text
        if first_item.get('type') == 'text' and first_item.get('text'):
            text = first_item['text']
            if trim_length and len(text) > trim_length:
                return text[:trim_length] + "..."
            return text

        return "No content"

    return "Empty content array"

def process_jsonl(input_file, output_file):
    """Process JSONL file and convert to CSV with smart trimming"""

    # Read all messages
    messages = []
    with open(input_file, 'r') as f:
        for line in f:
            if line.strip():
                messages.append(json.loads(line))

    # Track pending Read responses
    pending_read_count = 0
    csv_rows = []

    for msg in messages:
        # Check if this is a Read tool call
        if is_read_tool_call(msg):
            pending_read_count += 1

        # Check if this is a Read response
        is_read_response = (msg.get('type') == 'user' and pending_read_count > 0)

        # If it's a Read response, decrement the counter
        if is_read_response:
            pending_read_count -= 1

        # Extract description with appropriate trimming
        description = extract_description(msg, is_read_response)

        # Clean up description for CSV
        description = description.replace('\n', ' ').replace('\r', '').replace('"', '""')

        # Add row
        csv_rows.append({
            'type': msg.get('type', ''),
            'timestamp': msg.get('timestamp', ''),
            'description': description
        })

    # Write CSV
    with open(output_file, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=['type', 'timestamp', 'description'])
        for row in csv_rows:
            writer.writerow(row)

    # Print stats
    input_size = os.path.getsize(input_file)
    output_size = os.path.getsize(output_file)

    def format_size(size):
        for unit in ['B', 'KB', 'MB']:
            if size < 1024.0:
                return f"{size:.0f}{unit}" if unit == 'B' else f"{size:.0f}{unit}"
            size /= 1024.0
        return f"{size:.0f}GB"

    print(f"✅ Conversion complete!")
    print(f"   Original: {format_size(input_size)}")
    print(f"   CSV: {format_size(output_size)}")
    print(f"   Output: {output_file}")
    compression = (1 - output_size/input_size) * 100
    print(f"   Compression: {compression:.0f}%")

def main():
    if len(sys.argv) < 2:
        print("Usage: python jsonl-to-csv.py /path/to/input.jsonl [/path/to/output.csv]")
        print("Converts Claude Code JSONL conversation files to compact CSV format")
        print("Smart trimming: Read file responses → 150 chars, other content → 500 chars")
        sys.exit(1)

    input_file = sys.argv[1]

    if not os.path.exists(input_file):
        print(f"Error: Input file '{input_file}' not found")
        sys.exit(1)

    # Determine output file
    if len(sys.argv) > 2:
        output_file = sys.argv[2]
    else:
        input_path = Path(input_file)
        output_file = str(input_path.with_suffix('.csv'))

    print("Converting JSONL to CSV format with smart trimming...")
    print("Read file responses → 150 chars, other content → 500 chars")

    try:
        process_jsonl(input_file, output_file)
    except Exception as e:
        print(f"❌ Conversion failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()