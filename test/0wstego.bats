#!/usr/bin/env bats
#
# How to run:
#   ~$ bats test/0wstego.bats

BATS_TEST_SKIPPED=

setup() {
    _SCRIPT="./0wstego.sh"
    _PERL="$(command -v perl)"

    source $_SCRIPT
}

@test "CHECK: command_not_found()" {
    run command_not_found "bats"
    [ "$status" -eq 1 ]
    [ "$output" = "[31mbats[0m command not found!" ]
}

@test "CHECK: command_not_found(): show where-to-install" {
    run command_not_found "bats" "batsland"
    [ "$status" -eq 1 ]
    [ "${lines[0]}" = "[31mbats[0m command not found!" ]
    [ "${lines[1]}" = "Install from [31mbatsland[0m" ]
}

@test "CHECK: ascii2bin()" {
    run ascii2bin "toto"
    [ "$status" -eq 0 ]
    [ "$output" == "01110100011011110111010001101111" ]
}

@test "CHECK: ascii2bin(): empty input" {
    run ascii2bin
    [ "$status" -eq 0 ]
    [ "$output" == "" ]
}

@test "CHECK: bin2ascii()" {
    run bin2ascii "01110100011011110111010001101111"
    [ "$status" -eq 0 ]
    [ "$output" == "toto" ]
}

@test "CHECK: bin2ascii(): empty input" {
    run bin2ascii
    [ "$status" -eq 0 ]
    [ "$output" == "" ]
}

@test "CHECK: zerowidth2bin()" {
    run zerowidth2bin "$(printf '%b%b%b%b%b' 'othertextbefore' '\u200b' '\u200c' '\u200b' 'othertextafter')"
    [ "$status" -eq 0 ]
    [ "$output" == "101" ]
}

@test "CHECK: zerowidth2bin(): empty input" {
    run zerowidth2bin
    [ "$status" -eq 0 ]
    [ "$output" == "" ]
}

@test "CHECK: bin2zerowidth()" {
    run bin2zerowidth "101"
    [ "$status" -eq 0 ]
    [ "$output" == "$(printf %b '\u200b\u200c\u200b')" ]
}

@test "CHECK: bin2zerowidth(): empty input" {
    run bin2zerowidth
    [ "$status" -eq 0 ]
    [ "$output" == "" ]
}

@test "CHECK: start_encode()" {
    input_visible_message() {
        printf %b "toto tata"
    }
    input_hidden_message() {
        printf %b "secret"
    }
    run start_encode
    [ "$status" -eq 0 ]
    [ "$output" == "$(printf %b "‌​​​‌‌​​‌​​‌‌​‌​‌​​‌‌‌​​‌​​​‌‌​‌‌​​‌‌​‌​‌​​​‌​‌‌toto tata")" ]
}

@test "CHECK: start_decode()" {
    input_encoded_message() {
        printf %b "‌​​​‌‌​​‌​​‌‌​‌​‌​​‌‌‌​​‌​​​‌‌​‌‌​​‌‌​‌​‌​​​‌​‌‌toto tata"
    }
    run start_decode
    [ "$status" -eq 0 ]
    [ "$output" == "secret" ]
}
