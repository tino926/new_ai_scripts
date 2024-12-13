#!/bin/bash

# define working directory
WORKING_DIR=$(pwd)

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
        for FILE in $FORMAT; do
            # Skip if no files match the pattern
            [ -e "$FILE" ] || continue

            echo "Processing: $FILE"

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


