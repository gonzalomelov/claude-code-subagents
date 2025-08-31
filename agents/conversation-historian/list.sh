#!/bin/bash

# List recent Claude Code conversations for the current project
# Usage: ./list.sh [number_of_conversations]

# Configuration
CONVERSATIONS_TO_SHOW=${1:-10}
PROJECT_DIR=$(pwd)
PROJECT_NAME=$(echo "$PROJECT_DIR" | sed 's/\//-/g')
CLAUDE_PROJECT_DIR="$HOME/.claude/projects/$PROJECT_NAME"

# Check if project directory exists
if [ ! -d "$CLAUDE_PROJECT_DIR" ]; then
    echo "No Claude Code sessions found for this project"
    exit 1
fi

echo "Recent Claude Code Conversations for: $PROJECT_DIR"
echo "================================================"
echo ""

# Get conversation files sorted by modification time
cd "$CLAUDE_PROJECT_DIR"
conversations=($(ls -t *.jsonl 2>/dev/null | head -n "$CONVERSATIONS_TO_SHOW"))

# Check if any conversations exist
if [ ${#conversations[@]} -eq 0 ]; then
    echo "No conversations found"
    exit 1
fi

# Process each conversation
count=1
for conversation_file in "${conversations[@]}"; do
    conversation_id="${conversation_file%.jsonl}"
    
    # Get first meaningful message (skip caveats and commands)
    if [ -f "$conversation_file" ]; then
        # Try to find the first real user message (checking first 20 lines)
        # Handle both plain text and JSON-formatted messages
        preview_msg=$(head -20 "$conversation_file" | \
            jq -r 'select(.message.role == "user") | 
                   if (.message.content | type) == "string" then 
                       .message.content 
                   elif (.message.content | type) == "array" then 
                       .message.content[] | select(.type == "text") | .text 
                   else 
                       empty 
                   end' 2>/dev/null | \
            grep -v "^Caveat:" | \
            grep -v "^<" | \
            grep -v "^\[" | \
            grep -v "^{" | \
            grep -v "^$" | \
            grep -v "^[[:space:]]*$" | \
            sed '/^[[:space:]]*<.*>.*<\/.*>$/d' | \
            head -1)
        
        # Clean up any trailing backslashes or special characters
        preview_msg=$(echo "$preview_msg" | sed 's/\\$//' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        
        # If no meaningful message found, set default
        if [ -z "$preview_msg" ] || [ "$preview_msg" = "" ]; then
            preview_msg="No content preview available"
        fi
        
        # Get timestamp from first line
        timestamp=$(head -1 "$conversation_file" | jq -r '.timestamp // "Unknown time"' 2>/dev/null)
        
        # Convert timestamp to readable format if available
        if [ "$timestamp" != "Unknown time" ]; then
            # Use gdate if available (from coreutils), otherwise fallback
            if command -v gdate > /dev/null; then
                readable_date=$(gdate -d "$timestamp" "+%Y-%m-%d %H:%M" 2>/dev/null || echo "$timestamp")
            else
                readable_date="$timestamp"
            fi
        else
            readable_date="Unknown time"
        fi
        
        # Count messages in conversation
        msg_count=$(wc -l < "$conversation_file" | tr -d ' ')
        
        # Output conversation details
        echo "$count. Conversation: $conversation_id"
        echo "   Started: $readable_date"
        echo "   Messages: $msg_count"
        echo "   Preview: ${preview_msg}"
        echo ""
    fi
    
    ((count++))
done

echo "================================================"
echo "To resume a conversation, run: claude --resume <conversation-id>"