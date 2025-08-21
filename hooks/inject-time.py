#!/usr/bin/env python3
import json
import sys
import datetime

# Load input from stdin
input_data = json.load(sys.stdin)
prompt = input_data.get("prompt", "")

# Add current time to context
current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S %Z")
context = f"Current time: {current_time}"

# Output the context to be injected
print(context)

# Allow prompt to proceed
sys.exit(0)