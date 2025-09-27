#!/bin/bash

# norg-to-org.sh - Convert Neorg files to Org-mode format
# Usage: norg-to-org.sh /path/to/file.norg
# 
# This script converts a .norg file to .org format and places it in the
# corresponding location in ~/orgmode, maintaining the same directory structure
# as found in ~/org

set -euo pipefail

# Check if argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <path-to-norg-file>"
    echo "Example: $0 ~/org/ai_slop/prompts.norg"
    exit 1
fi

NORG_FILE="$1"

# Check if file exists and has .norg extension
if [ ! -f "$NORG_FILE" ]; then
    echo "Error: File '$NORG_FILE' does not exist"
    exit 1
fi

if [[ ! "$NORG_FILE" == *.norg ]]; then
    echo "Error: File must have .norg extension"
    exit 1
fi

# Extract relative path from ~/org and convert to ~/orgmode
NORG_FILE_ABS=$(realpath "$NORG_FILE")
ORG_BASE=$(realpath ~/org)

# Check if file is under ~/org
if [[ ! "$NORG_FILE_ABS" == "$ORG_BASE"* ]]; then
    echo "Error: File must be under ~/org directory"
    exit 1
fi

# Get relative path and construct target path
REL_PATH="${NORG_FILE_ABS#$ORG_BASE/}"
TARGET_PATH="$HOME/orgmode/${REL_PATH%.norg}.org"
TARGET_DIR=$(dirname "$TARGET_PATH")

# Create target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

echo "Converting: $NORG_FILE"
echo "Target: $TARGET_PATH"

# Conversion function
convert_norg_to_org() {
    local input_file="$1"
    local output_file="$2"
    
    # Use awk for the conversion
    awk '
    BEGIN {
        in_meta = 0
        in_code = 0
        code_lang = ""
        meta_content = ""
        collecting_categories = 0
        collecting_tangle = 0
        tangle_content = ""
        next_block_tangle = 0
    }
    
    # Handle document metadata
    /^@document\.meta/ {
        in_meta = 1
        next
    }
    
    /^@end/ && in_meta {
        in_meta = 0
        collecting_categories = 0
        collecting_tangle = 0
        # Convert metadata to org-mode properties
        print "#+TITLE: " title
        if (description != "") print "#+DESCRIPTION: " description
        if (author != "") print "#+AUTHOR: " author
        if (categories != "") print "#+CATEGORIES: " categories
        if (created != "") print "#+CREATED: " created
        if (updated != "") print "#+UPDATED: " updated
        if (version != "") print "#+VERSION: " version
        # Handle tangle metadata for literate programming
        if (tangle_content != "") {
            print "#+PROPERTY: header-args :tangle yes"
            # Extract the output file from tangle metadata if possible
            if (tangle_content ~ /toml:/) {
                gsub(/.*toml: */, "", tangle_content)
                gsub(/[{} \n].*/, "", tangle_content)
                if (tangle_content != "") {
                    print "#+PROPERTY: header-args:toml :tangle " tangle_content
                }
            }
        }
        # Add other metadata fields
        for (field in other_meta) {
            print "#+" toupper(field) ": " other_meta[field]
        }
        print ""
        next
    }
    
    # Parse metadata fields
    in_meta && /^title:/ {
        title = substr($0, 8)
        gsub(/^[ \t]+|[ \t]+$/, "", title)  # trim whitespace
        next
    }
    
    in_meta && /^description:/ {
        description = substr($0, 13)
        gsub(/^[ \t]+|[ \t]+$/, "", description)
        next
    }
    
    in_meta && /^authors:/ {
        author = substr($0, 9)
        gsub(/^[ \t]+|[ \t]+$/, "", author)
        next
    }
    
    in_meta && /^categories:/ {
        # Handle both single line and multi-line categories
        if ($0 ~ /\[/) {
            # Multi-line array format
            categories = substr($0, 12)
            gsub(/[\[\]]/, "", categories)
            gsub(/^[ \t]+|[ \t]+$/, "", categories)
            if (categories == "") {
                # Start collecting categories from next lines
                collecting_categories = 1
                categories = ""
            }
        } else {
            categories = substr($0, 12)
            gsub(/^[ \t]+|[ \t]+$/, "", categories)
        }
        next
    }
    
    in_meta && /^created:/ {
        created = substr($0, 9)
        gsub(/^[ \t]+|[ \t]+$/, "", created)
        next
    }
    
    in_meta && /^updated:/ {
        updated = substr($0, 9)
        gsub(/^[ \t]+|[ \t]+$/, "", updated)
        next
    }
    
    in_meta && /^version:/ {
        version = substr($0, 9)
        gsub(/^[ \t]+|[ \t]+$/, "", version)
        next
    }
    
    # Handle multi-line categories and other metadata fields
    in_meta && collecting_categories && /^[ \t]+[a-zA-Z]/ {
        line = $0
        gsub(/^[ \t]+|[ \t]+$/, "", line)
        if (line != "" && line !~ /^[\]\}]/) {
            if (categories == "") {
                categories = line
            } else {
                categories = categories ", " line
            }
        }
        next
    }
    
    # End of categories array
    in_meta && /^[ \t]*\]/ && collecting_categories {
        collecting_categories = 0
        next
    }
    
    # Handle tangle metadata specially
    in_meta && /^tangle:/ {
        # Start collecting tangle metadata
        collecting_tangle = 1
        tangle_content = ""
        next
    }
    
    # Collect tangle metadata lines
    in_meta && collecting_tangle && (/^[ \t]+/ || /^[{}]/ || /^\s*languages:/ || /^\s*delimiter:/) {
        line = $0
        gsub(/^[ \t]+|[ \t]+$/, "", line)
        if (line != "" && line !~ /^[}]$/) {
            if (tangle_content == "") {
                tangle_content = line
            } else {
                tangle_content = tangle_content "\n" line
            }
        }
        next
    }
    
    # End of tangle metadata
    in_meta && /^[a-zA-Z_]+:/ && collecting_tangle {
        collecting_tangle = 0
        # Continue processing the current line
    }
    
    # Handle other metadata fields
    in_meta && /^[a-zA-Z_]+:/ && !(/^(title|description|authors|categories|created|updated|version|tangle):/) {
        # Extract field name and value for other metadata
        field = $0
        sub(/:.*/, "", field)
        value = $0
        sub(/^[^:]*:[ \t]*/, "", value)
        gsub(/^[ \t]+|[ \t]+$/, "", value)
        if (value != "") {
            other_meta[field] = value
        }
        next
    }
    
    # Skip other metadata lines
    in_meta { next }
    
    # Handle code blocks (with possible indentation)
    /^[ \t]*@code/ {
        in_code = 1
        # Extract indentation
        match($0, /^[ \t]*/)
        indent = substr($0, 1, RLENGTH)
        # Extract language (everything after @code)
        line = $0
        sub(/^[ \t]*@code[ \t]*/, "", line)
        code_lang = line
        gsub(/^[ \t]+|[ \t]+$/, "", code_lang)
        
        # Add tangle property if #tangle was specified before this block
        tangle_prop = ""
        if (next_block_tangle == 1) {
            tangle_prop = " :tangle yes"
            next_block_tangle = 0
        }
        
        if (code_lang == "" || code_lang == "lang") {
            print indent "#+BEGIN_SRC" tangle_prop
        } else {
            print indent "#+BEGIN_SRC " code_lang tangle_prop
        }
        next
    }
    
    # End code blocks with @end (with possible indentation)
    /^[ \t]*@end/ && in_code {
        in_code = 0
        # Extract indentation
        match($0, /^[ \t]*/)
        indent = substr($0, 1, RLENGTH)
        print indent "#+END_SRC"
        next
    }
    
    # Convert links [text]{url} to [[url][text]] (org-mode convention)
    !in_code {
        gsub(/\[([^\]]+)\]\{([^}]+)\}/, "[[\\2][\\1]]")
    }
    
    # Convert emphasis /text/ to *text* (org-mode convention)
    !in_code {
        gsub(/\/([^\/]+)\//, "*\\1*")
    }
    
    # Convert #tangle directives to org-mode properties
    /^[ \t]*#tangle/ {
        # Mark that the next code block should be tangled
        next_block_tangle = 1
        next
    }
    
    # Print all other lines as-is
    { print }
    
    # Handle end of file when in code block
    END {
        if (in_code) {
            print "#+END_SRC"
        }
    }
    ' "$input_file" > "$output_file"
}

# Perform the conversion
convert_norg_to_org "$NORG_FILE" "$TARGET_PATH"

echo "Conversion completed successfully!"
echo "Output saved to: $TARGET_PATH"

# Show a preview of the converted file
echo ""
echo "Preview (first 10 lines):"
echo "========================="
head -10 "$TARGET_PATH"