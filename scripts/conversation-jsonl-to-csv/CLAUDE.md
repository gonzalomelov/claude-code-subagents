# JSONL to CSV Conversion Tools

This project contains scripts to convert Claude Code conversation files from JSONL format to compressed CSV format with smart trimming, reducing file sizes by 80-97%.

## Scripts

### jsonl-to-csv.py
Core conversion script that transforms JSONL conversation files to compact CSV format with smart trimming.

**Usage:**
```bash
python3 jsonl-to-csv.py /path/to/input.jsonl [/path/to/output.csv]
```

**Features:**
- Smart trimming: Read file responses → 150 chars, other content → 500 chars
- Tracks multiple sequential Read tool calls accurately
- Handles various content structures (string, array, tool results)
- Removes metadata to minimize file size
- Typical compression: 80-97% reduction

**Output Format:**
CSV with 3 columns: `type`, `timestamp`, `description`

### watch-and-convert.sh
File watcher that monitors directories for JSONL file changes and automatically converts them.

**Usage:**
```bash
./watch-and-convert.sh [directory]  # defaults to current directory
```

**Features:**
- Polls every 2 seconds for changes
- Auto-converts new or modified JSONL files
- Creates `csv-minified/` subdirectory for outputs
- Color-coded status messages
- Shows compression statistics

### batch-convert-all.sh
Batch processor for converting all JSONL files in a directory tree.

**Usage:**
```bash
./batch-convert-all.sh [base_directory]  # defaults to ~/.claude/projects
```

**Features:**
- Processes all subdirectories with JSONL files
- Skips already converted files (checks timestamps)
- Creates `csv-minified/` subdirectories
- Shows progress and statistics
- Handles large-scale conversions (500+ files)

## Directory Structure
```
project-folder/
├── *.jsonl                 # Original conversation files
├── csv-minified/          # Auto-created output directory
│   └── *.csv              # Compressed CSV files
└── [scripts]              # Conversion scripts
```

## Typical Use Cases

1. **Convert single file:**
   ```bash
   python3 jsonl-to-csv.py conversation.jsonl
   ```

2. **Watch folder for changes:**
   ```bash
   ./watch-and-convert.sh ~/.claude/projects/my-project
   ```

3. **Convert all files at once:**
   ```bash
   ./batch-convert-all.sh
   ```

## Notes
- CSV files retain essential conversation data while removing verbose metadata
- Read file responses are intelligently trimmed to 150 chars for optimal compression
- Other content is trimmed to 500 chars to preserve context
- Original JSONL files are preserved
- Scripts handle various Claude Code message formats automatically