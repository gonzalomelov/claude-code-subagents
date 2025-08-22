#!/usr/bin/env python3
import json
import sys
import datetime

# Load input from stdin
input_data = json.load(sys.stdin)
prompt = input_data.get("prompt", "")

# Add current date and time to context
now = datetime.datetime.now()
context = f"Current time: {now:%H:%M:%S, %A, %B %d, %Y} (Week: Monday-Sunday)"

# Output the context to be injected
print(context)

# Allow prompt to proceed
sys.exit(0)