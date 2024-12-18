#!/bin/bash

# define working directory
# check if argument is provided
if [ $# -eq 0 ]; then
    echo "No directory provided. Using current directory."
    WORKING_DIR="$(pwd)"
else
    WORKING_DIR="$1"
    
    # check if provided directory exists
    if [ ! -d "$WORKING_DIR" ]; then
        echo "Directory $WORKING_DIR does not exist."
        exit 1
    fi
fi

# define output directory
OUTPUT_DIR="$WORKING_DIR/output"

# define desired output format list
OUTPUT_FORMATS=("txt" "srt")

# Define which whisper model to use
WHISPER_MODELS=("turbo" "medium")
# WHISPER_MODELS=("large-v3" "turbo" "medium")
# WHISPER_MODELS=("large-v3")

# Define supported audio formats
AUDIO_FORMATS=("*.mp3" "*.m4a" "*.wav" "*.flac")

# Loop through each whisper model
for MODEL in "${WHISPER_MODELS[@]}"; do
    echo "Using model: $MODEL"

    # Loop through each audio format
    for FORMAT in "${AUDIO_FORMATS[@]}"; do
        # Process each file of that format
        for FILE in "$WORKING_DIR"/$FORMAT; do
            echo "Processing: $FILE"

            # Skip if no files match the pattern
            [ -e "$FILE" ] || continue

            # whisper "$FILE"
            whisper "$FILE" \
                --language English \
                --model $MODEL \
                --verbose False \
                --output_dir "$OUTPUT_DIR/$MODEL"

            # Get base filename without extension
            BASENAME=$(basename "$FILE" | sed 's/\.[^.]*$//')

            # Remove unwanted output formats
            for f in "$OUTPUT_DIR/$MODEL/$BASENAME".*; do
                EXT="${f##*.}"
                if [[ ! " ${OUTPUT_FORMATS[@]} " =~ " ${EXT} " ]]; then
                    rm -f "$f"
                fi
            done
        done
    done
done


