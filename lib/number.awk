@namespace "number";

@include "./lib/string.awk";

function to_hex(num) {
    return sprintf("%x", num);
}

function from_hex(hex_str) {
    if (hex_str !~ /^[[:xdigit:]]+$/) {
        printf("from_hex: invalid literal: '%s'\n", hex_str) > "/dev/stderr";
        exit(1);
    }
    return awk::strtonum(string::concat("0x", hex_str));
}
