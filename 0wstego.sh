#!/usr/bin/env bash
#
# Hide/Reveal message using zero-width characters
#
#/ Usage:
#/   ./0wstega.sh [-d|-f <file_path>]
#/
#/ Options:
#/                    Without any parameters, encode message
#/   -d               Decode message
#/   -f <file_path>   Decode message in file
#/   -h | --help      Display this help message

set -e
set -u

usage() {
    # Display usage message
    printf "%b\n" "$(grep '^#/' "$0" | cut -c4-)" && exit 0
}

set_command() {
    # Declare commands
    _PERL="$(command -v perl)" || command_not_found "perl" "https://www.perl.org/"
}

set_args() {
    # Declare arguments
    expr "$*" : ".*--help" > /dev/null && usage

    _ENCODE_PROCESS=true
    while getopts ":hdf:" opt; do
        case $opt in
            d)
                _ENCODE_PROCESS=false
                ;;
            f)
                _ENCODE_PROCESS=false
                _FILE_PATH="$OPTARG"
                ;;
            h)
                usage
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                usage
                ;;
        esac
    done
}

command_not_found() {
    # Show command not found message
    # $1: command name
    # $2: installation URL
    printf "%b\n" '\033[31m'"$1"'\033[0m command not found!'
    [[ -n "${2:-}" ]] && printf "%b\n" 'Install from \033[31m'"$2"'\033[0m'
    exit 1
}

ascii2bin() {
    # ASCII to binary
    # $1: message

    # shellcheck disable=SC2016
    echo -n "${1:-}" | $_PERL -lpe '$_=unpack "B*"'
}

bin2ascii() {
    # Binary to ASCII
    # $1: binary text

    # shellcheck disable=SC2016
    echo "${1:-}" | $_PERL -lpe '$_=pack"B*",$_'
}

zerowidth2bin() {
    # Zero-width characters to binary
    # $1: encoded message
    local str arr
    read -r -a arr <<< "$(echo "${1:-}" | sed -E 's/./& /g')"
    str=""
    for b in "${arr[@]}"; do
        if [[ "$b" == "$(printf %b '\u200b')" ]]; then
            str="${str}1"
        fi
        if [[ "$b" == "$(printf %b '\u200c')" ]]; then
            str="${str}0"
        fi
    done
    echo "$str"
}

bin2zerowidth() {
    # Binary to zero-width characters
    # $1: binary text
    local arr
    read -r -a arr <<< "$(echo "${1:-}" | sed -E 's/./& /g')"
    for l in "${arr[@]}"; do
        if [[ "$l" == "1" ]]; then
            printf %b '\u200b'
        fi
        if [[ "$l" == "0" ]]; then
            printf %b '\u200c'
        fi
    done
}

input_encoded_message() {
    # Prompt for encoded message
    local txt
    echo -n "Paste encoded message here: " >&2
    read -r txt
    printf %b "$txt"
}

input_visible_message() {
    # Prompt for visible message
    local txt
    echo -n "Visible message: " >&2
    read -r txt
    printf %b "$txt"
}

input_hidden_message() {
    # Prompt for hidden message
    local txt
    echo -n "Secret message to hide: " >&2
    read -r txt
    printf %b "$txt"
}

start_encode() {
    # Encode message
    local v h
    v="$(input_visible_message)"
    h="$(input_hidden_message)"

    printf "%b%b" "$(bin2zerowidth "$(ascii2bin "$h")")" "$v"
}

start_decode() {
    # Decode message
    local h
    if [[ -z "${_FILE_PATH:-}" ]]; then
        h="$(input_encoded_message)"
    else
        h="$(cat $_FILE_PATH)"
    fi
    bin2ascii "$(zerowidth2bin "$h")"
}

main() {
    set_args "$@"
    set_command

    if [[ "$_ENCODE_PROCESS" == true ]]; then
        start_encode
    else
        start_decode
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
