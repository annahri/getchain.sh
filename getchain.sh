#!/bin/bash
# getchain.sh -- by ahfas.annahri@gmail.com

cmd="$(basename "$0")"
url="https://whatsmychaincert.com/generate"
declare -a curl_opts

usage() {
    printf '%s\n' \
        "$cmd -- CLI wrapper for whatsmychaincert.com" \
        " " \
        "Usage: $cmd <-c certfile|-h hostname> [-r]" \
        " " \
        "Flags: " \
        " -c certfile  Get cert chain by certificate file." \
        " -h hostname  Get cert chain by hostname." \
        " -r           Include root certificate." \
        " " \
        "Note:" \
        " Both -c and -h are mutually exclusive. If both are defined, the last one will be used." \
        " " \
        "Examples: " \
        " $cmd -c ./cert.pem -r" \
        " $cmd -h yourdomain.com -r"
}

err() {
    printf 'ERROR: %s\n' "$@"
}

main() {
    if [[ $# -eq 0 ]]; then
        usage
        exit
    fi

    if ! command -v curl > /dev/null 2>&1; then
        err "Please install \`curl\`."
        exit 1
    fi

    while [[ $# -ne 0 ]]; do case "$1" in
        -c) # Certificate file
            if [[ -z "$2" ]]; then
                err "$1 requires an argument: certfile"
                exit 1
            fi

            if [[ -n "$cert" ]]; then
                err "You cannot use -c twice."
                exit 1
            fi

            cert="$2"
            unset hostname

            if [[ ! -f "$cert" ]]; then
                err "Certificate $cert doesn't exist."
                exit 1
            fi

            if ! head -1 "$cert" | grep -q -- "-----BEGIN CERTIFICATE-----"; then
                err "Invalid certificate file."
                exit 1
            fi

            curl_opts+=(--data-urlencode "pem@${cert}")
            shift
            ;;
        -h) # Hostname
            if [[ -z "$2" ]]; then
                err "$1 requires an argument: hostname"
                exit 1
            fi

            if [[ -n "$hostname" ]]; then
                err "You cannot use -h twice."
                exit
            fi

            hostname="$2"
            unset cert

            curl_opts+=(--get --data "host=${hostname}")
            shift
            ;;
        -r) # Include root
            if [[ "$leaf" -eq 1 ]]; then
                err "You cannot use -r twice."
                exit
            fi

            leaf="1"
            curl_opts+=(--data "include_leaf=${leaf}")
            ;;
        *)  # Usage
            usage
            exit
            ;;
    esac; shift; done

    result=$(curl -Ss "${curl_opts[@]}" "$url")
    if [[ $? -ne 0 ]]; then
        err "Unable to reach $url"
        exit 1
    fi

    case "$result" in
        Unable*)
            err "Cannot resolve ${hostname}"
            exit 1
            ;;
        Failed*)
            err "Upstream unable to parse the certificate."
            exit 1
            ;;
    esac

    echo "$result"
}

main "$@"
