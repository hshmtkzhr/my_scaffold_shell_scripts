#!/bin/bash

tmp=`mktemp`
trap 'rm -f $tmp*' 0

dir=$(cd $(dirname $0) && pwd)

help=$(cat << EOF
usage: $0 [OPTIONS]

Options:
  -h, --help                Print this message.
  -a, --long-a <param>      help message for -a
  -b, --long-b <param>      help message for -b
  --long-opt-only           help message for --long-opt-only
EOF
)

function __print_help() {
    echo "$help"
    exit 1
}

for OPT in "$@"
do
    case $OPT in
        -h | --help)
            __print_help
            ;;
        -a | --long-a)
            if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "option requires an argument -- $1" 1>&2
                __print_help
            fi
            var_contains_long_a=$2
            shift 2
            ;;
        -b | --long-b)
            if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "option requires an argument -- $1" 1>&2
                __print_help
            fi
            var_contains_long_b=$2
            shift 2
            ;;
        --long-opt-opnly)
            var_used_like_boolean="switch_string"
            shift 1
            ;;
        *)
            if [[ ! -z "$1" ]] && [[ ! "$1" =~ ^-+ ]]; then
                param+=( "$1" )
                shift 1
            fi
            ;;
    esac
done
