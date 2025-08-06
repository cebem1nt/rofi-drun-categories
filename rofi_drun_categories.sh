#!/bin/bash

if [ $# -eq 0 ]; then
    echo "No categories were given, perhaps you forgot them?"
    exit 1
fi

GLOBAL_ENTRIES=("/usr/share/applications"/*.desktop)
USER_ENTRIES=("$HOME/.local/share/applications"/*.desktop)

if [ "${USER_ENTRIES[0]}" == "$HOME/.local/share/applications/*.desktop" ]; then
    USER_ENTRIES=()
fi

extract_icon() {
    local file="$1"
    # rofi seems to be able to fin icon by itself
    echo $(grep -E '^Icon=' "$file" | cut -d'=' -f2)
}


extract_name() {
    local file="$1"
    echo $(grep -E '^Name=' "$file" | cut -d'=' -f2)
}

is_in_category() {
    local file="$1"
    shift
    local given_categories=("$@")

    local file_categories
    file_categories=$(grep -E '^Categories=' "$file" | cut -d'=' -f2)

    for category in "${given_categories[@]}"; do
        if [[ "$file_categories" == *"$category"* ]]; then
            echo "true"
            return
        fi
    done

    echo "false"
}

len1=${#GLOBAL_ENTRIES[@]}
len2=${#USER_ENTRIES[@]}

max_length=$(( len1 > len2 ? len1 : len2 ))

for (( i=0; i<max_length; i++ )); do
    if [ $i -lt $len1 ]; then
        IN_CATEGORY=$(is_in_category "${GLOBAL_ENTRIES[i]}" "$@")
        if [ "$IN_CATEGORY" == "true" ]; then
            CURRENT_ICON=$(extract_icon "${GLOBAL_ENTRIES[i]}") 
            CURRENT_NAME=$(extract_name "${GLOBAL_ENTRIES[i]}")
            echo -en "$CURRENT_NAME\0icon\x1f$CURRENT_ICON\n"
        fi
    fi

    if [ $i -lt $len2 ]; then
        IN_CATEGORY=$(is_in_category "${USER_ENTRIES[i]}" "$@")
        if [ "$IN_CATEGORY" == "true" ]; then
            CURRENT_ICON=$(extract_icon "${USER_ENTRIES[i]}") 
            CURRENT_NAME=$(extract_name "${USER_ENTRIES[i]}")
            echo -en "$CURRENT_NAME\0icon\x1f$CURRENT_ICON\n"
        fi
    fi
done
