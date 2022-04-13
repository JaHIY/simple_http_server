@namespace "string"

@include "./lib/array.awk";
@include "./lib/shlex.awk";

BEGIN {
    GLOBAL["STRING"]["UNICODE_TABLE"][0] = "";
    array::new(GLOBAL["STRING"]["UNICODE_TABLE"]);
    GLOBAL["STRING"]["UTF8_TABLE"][0] = "";
    array::new(GLOBAL["STRING"]["UTF8_TABLE"]);
}

function _gen_unicode_table(unicode_table, __ARGV_END__, char) {
    for (i = 0; i < 1114111; i += 1) {
        char = sprintf("%c", i);
        if (!(char in unicode_table)) {
            unicode_table[char] = i;
        }
    }
}

function startswith(str, prefix, start, end, __ARGV_END__, plen, slen, i, teststr) {
    if (awk::isarray(prefix)) {
        for (i in prefix) {
            if (startswith(str, prefix[i], start, end)) {
                return 1;
            }
        }
        return 0;
    }

    slen = length(str);
    if (length(start) == 0) {
        start = 1;
    }
    if (length(end) == 0) {
        end = slen;
    }
    if (awk::typeof(start) != "number") {
        printf("%s\n", "startswith: third argument is not number") > "/dev/stderr";
        exit(1);
    }
    if (awk::typeof(end) != "number") {
        printf("%s\n", "startswith: fourth argument is not number") > "/dev/stderr";
        exit(1);
    }
    if (start < 1) {
        start = 1;
    }
    if (end > slen) {
        end = slen;
    }
    if (start > slen || end < 1) {
        return 0;
    }

    plen = length(prefix);
    if (plen > slen) {
        return 0;
    }

    teststr = substr(str, start, end - start + 1);
    return (substr(teststr, 1, plen) == prefix);
}

function endswith(str, prefix, start, end, __ARGV_END__, plen, slen, i, teststr) {
    if (awk::isarray(prefix)) {
        for (i in prefix) {
            if (endswith(str, prefix[i], start, end)) {
                return 1;
            }
        }
        return 0;
    }

    slen = length(str);
    if (length(start) == 0) {
        start = 1;
    }
    if (length(end) == 0) {
        end = slen;
    }
    if (awk::typeof(start) != "number") {
        printf("%s\n", "endswith: third argument is not number") > "/dev/stderr";
        exit(1);
    }
    if (awk::typeof(end) != "number") {
        printf("%s\n", "endswith: fourth argument is not number") > "/dev/stderr";
        exit(1);
    }
    if (start < 1) {
        start = 1;
    }
    if (end > slen) {
        end = slen;
    }
    if (start > slen || end < 1) {
        return 0;
    }

    plen = length(prefix);
    if (plen > slen) {
        return 0;
    }

    teststr = substr(str, start, end - start + 1);
    return (substr(teststr, length(teststr) - plen + 1, plen) == prefix);
}

function at(str, i, __ARGV_END__, slen) {
    slen = length(str);
    if (i < 1) {
        i = slen - i;
    }
    if ((i < 1) || (i > slen)) {
        printf("%s\n", "at: string index out of range") > "/dev/stderr";
        exit(1);
    }
    return substr(str, i, 1);
}

function repeat(str, times, __ARGV_END__, i, result) {
    if (awk::typeof(times) != "number") {
        printf("%s\n", "repeat: second argument is not number") > "/dev/stderr";
        exit(1);
    }

    times = awk::strtonum(sprintf("%d", times));

    result = "";
    for (i = 0; i < times; i += 1) {
        result = sprintf("%s%s", result, str);
    }

    return result;
}

function find(str, target, start, end, __ARGV__, slen) {
    slen = length(str);
    if (length(start) == 0) {
        start = 1;
    }
    if (length(end) == 0) {
        end = slen;
    }
    if (awk::typeof(start) != "number") {
        printf("%s\n", "find: third argument is not number") > "/dev/stderr";
        exit(1);
    }
    if (awk::typeof(end) != "number") {
        printf("%s\n", "find: fourth argument is not number") > "/dev/stderr";
        exit(1);
    }
    if (start < 1) {
        start = 1;
    }
    if (end > slen) {
        end = slen;
    }
    if (start > slen || end < 1) {
        return 0;
    }

    str = substr(str, start, end - start + 1);
    return index(str, target);
}

function rfind(str, target, start, end, __ARGV_END__, slen, pos) {
    slen = length(str);
    if (length(start) == 0) {
        start = 1;
    }
    if (length(end) == 0) {
        end = slen;
    }
    if (awk::typeof(start) != "number") {
        printf("%s\n", "rfind: third argument is not number") > "/dev/stderr";
        exit(1);
    }
    if (awk::typeof(end) != "number") {
        printf("%s\n", "rfind: fourth argument is not number") > "/dev/stderr";
        exit(1);
    }
    if (start < 1) {
        start = 1;
    }
    if (end > slen) {
        end = slen;
    }
    if (start > slen || end < 1) {
        return 0;
    }

    slen = end - start + 1;
    str = substr(str, start, slen);
    pos = index(reverse(str), reverse(target));
    if (pos == 0) {
        return 0;
    }
    return (slen - pos + 1);
}

function reverse(str, __ARGV_END__, i, result) {
    result = "";
    for (i = length(str); i > 0; i -= 1) {
        result = sprintf("%s%s", result, substr(str, i, 1));
    }
    return result;
}

function rstrip(str, chars, __ARGV_END__, char_array, i, s, result) {
    split(chars, char_array, "");
    for (i = length(str); i > 0; i -= 1) {
        s = substr(str, i, 1);
        if (!array::contains(char_array, s)) {
            break;
        }
    }
    return substr(str, 1, i);
}

function concat(a, b) {
    return sprintf("%s%s", a, b);
}

function Split(str, result, sep, maxsplit, __ARGV_END__, start, end, i, match_group, slen) {
    array::new(result);
    if (length(maxsplit) == 0) {
        maxsplit = -1;
    }
    if (awk::typeof(maxsplit) != "number") {
        printf("%s\n", "Split: fourth argument is not number") > "/dev/stderr";
        exit(1);
    }
    while (1) {
        start = 1;
        i = match(str, sep, match_group);
        if (i == 0) {
            break;
        }
        slen = length(match_group[0]);
        array::push(result, substr(str, start, i - start));
        start = i + slen;
        str = substr(str, start);
        if (maxsplit > 0) {
            maxsplit -= 1;
            if (maxsplit == 0) {
                break;
            }
        }
    }
    array::push(result, str);
}

function chr(char_point) {
    return sprintf("%c", char_point);
}

function ord(str, __ARGV_END__, len) {
    len = length(str);
    if (len != 1) {
        printf("ord: expected a character, but string of length %d found\n", len) > "/dev/stderr";
        exit(1);
    }
    if (length(GLOBAL["STRING"]["UNICODE_TABLE"]) == 0) {
        _gen_unicode_table(GLOBAL["STRING"]["UNICODE_TABLE"]);
    }
    return GLOBAL["STRING"]["UNICODE_TABLE"][str];
}

function code_point(str, cp_array, __ARGV_END__, i, len, char) {
    array::new(cp_array);
    len = length(str);
    for (i = 1; i <= len; i += 1) {
        char = substr(str, i, 1);
        array::push(cp_array, ord(char));
    }
}

function _gen_utf8_table(table) {
    table[1]["cmask"] = 128; #0x80
    table[1]["cval"] = 0; #0x00
    table[1]["shift"] = 0 * 6;
    table[1]["lmask"] = 127; #0x7F
    table[1]["lval"] = 0; #0x00
    table[2]["cmask"] = 224; #0xE0
    table[2]["cval"] = 192; #0xC0
    table[2]["shift"] = 1 * 6;
    table[2]["lmask"] = 2047; #0x7FF
    table[2]["lval"] = 128; #0x80
    table[3]["cmask"] = 240; #0xF0
    table[3]["cval"] = 224; #0xE0
    table[3]["shift"] = 2 * 6;
    table[3]["lmask"] = 65535; #0xFFFF
    table[3]["lval"] = 2048; #0x800
    table[4]["cmask"] = 248; #0xF8
    table[4]["cval"] = 240; #0xF0
    table[4]["shift"] = 3 * 6;
    table[4]["lmask"] = 2097151; #0x1FFFFF
    table[4]["lval"] = 65536; #0x10000
    table[5]["cmask"] = 252; #0xFC
    table[5]["cval"] = 248; #0xF8
    table[5]["shift"] = 4 * 6;
    table[5]["lmask"] = 67108863; #0x3ffffff
    table[5]["lval"] = 2097152; #0x200000
    table[6]["cmask"] = 254; #0xFE
    table[6]["cval"] = 252; #0xFC
    table[6]["shift"] = 5 * 6;
    table[6]["lmask"] = 2147483647; #0x7FFFFFFF
    table[6]["lval"] = 67108864; #0x4000000
}

function utf8_encode_one(code_point, result, __ARGV_END__, l, nc, c) {
    array::new(result);
    if (length(code_point) == 0) {
        return 0;
    }

    if (length(GLOBAL["STRING"]["UTF8_TABLE"]) == 0) {
        _gen_utf8_table(GLOBAL["STRING"]["UTF8_TABLE"]);
    }

    l = code_point;
    nc = 0;
    len = length(GLOBAL["STRING"]["UTF8_TABLE"]);

    for (i = 1; i <= len; i += 1) {
        nc += 1;
        if (l <= GLOBAL["STRING"]["UTF8_TABLE"][i]["lmask"]) {
            c = GLOBAL["STRING"]["UTF8_TABLE"][i]["shift"];
            array::push(result, awk::or(GLOBAL["STRING"]["UTF8_TABLE"][i]["cval"], awk::rshift(l, c)));
            while (c > 0) {
                c -= 6;
                array::push(result, awk::or(128, awk::and(awk::rshift(l, c), 63)));
            }

            return nc;
        }
    }
    return -1;
}

function utf8_encode(str, result,
                     __ARGV_END__, code_point_array, len, i, utf8_seq, ret, slen, nc) {
    array::new(result);
    nc = 0;
    code_point(str, code_point_array);
    len = length(code_point_array);
    for (i = 1; i <= len; i += 1) {
        ret = utf8_encode_one(code_point_array[i], utf8_seq);
        if (ret < 0) {
            return -1;
        }
        array::concat(result, utf8_seq);
        nc += ret;
    }
    return nc;
}

function utf8_decode_one(utf8_seq, result, start, end,
                          __ARGV_END__, n, l, i, j, len, c0, c, nc) {
    array::new(result);
    n = length(utf8_seq);
    if (length(start) == 0) {
        start = 1;
    }
    if (length(end) == 0) {
        end = n;
    }
    if (awk::typeof(start) != "number") {
        printf("%s\n", "_utf8_decode_one: third argument is not number") > "/dev/stderr";
        exit(1);
    }
    if (awk::typeof(end) != "number") {
        printf("%s\n", "_utf8_decode_one: fourth argument is not number") > "/dev/stderr";
        exit(1);
    }

    if (start < 1) {
        start = 1;
    }
    if (end > n) {
        end = n;
    }
    if (start > n || end < 1) {
        return -1;
    }
    if (start > end) {
        return -1;
    }


    i = start;
    c0 = awk::and(utf8_seq[i], 255);
    l = c0;

    if (length(GLOBAL["STRING"]["UTF8_TABLE"]) == 0) {
        _gen_utf8_table(GLOBAL["STRING"]["UTF8_TABLE"]);
    }

    len = length(GLOBAL["STRING"]["UTF8_TABLE"]);

    nc = 0;
    for (j = 1; j <= len; j += 1) {
        nc += 1;

        if (awk::and(c0, GLOBAL["STRING"]["UTF8_TABLE"][j]["cmask"]) == GLOBAL["STRING"]["UTF8_TABLE"][j]["cval"]) {
            l = awk::and(l, GLOBAL["STRING"]["UTF8_TABLE"][j]["lmask"]);

            if (l < GLOBAL["STRING"]["UTF8_TABLE"][j]["lval"]) {
                return -1;
            }

            array::push(result, l);
            array::push(result, chr(l));
            return nc;
        }

        i += 1;

        if (i > end) {
            return -1;
        }

        c = awk::and(awk::xor(utf8_seq[i], 128), 255);

        if (awk::and(c, 192)) {
            return -1;
        }

        l = awk::or(awk::lshift(l, 6), c);
    }

    return -1;
}

function utf8_decode(utf8_seq, result, __ARGV_END__, char_array, i, len) {
    array::new(result);
    array::new(char_array);
    len = length(utf8_seq);
    for (i = 1; i <= len;) {
        nc = utf8_decode_one(utf8_seq, decode_result, i);
        if (nc < 0) {
            result[2] = sprintf("utf8_decode: can't decode 0x%02X in position %s", utf8_seq[i], i);
            return -1;
        }
        array::push(char_array, decode_result[2]);
        i += nc;
    }
    result[1] = array::join(char_array, "");

    return length(char_array);
}
