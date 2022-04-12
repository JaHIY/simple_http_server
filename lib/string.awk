@namespace "string"

@include "./lib/array.awk";
@include "./lib/shlex.awk";

BEGIN {
    GLOBAL["PRINTF_COMMAND"] = "printf";
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

function bytes(str, bs_array, __ARGV_END__, save_rs, fmt, cmd, od_line, od_array, i, h) {
    array::new(bs_array);
    fmt = "%s '%%s' %s | od -An -t x1";
    cmd = sprintf(fmt, shlex::quote(GLOBAL["PRINTF_COMMAND"]), shlex::quote(str));
    save_rs = RS;
    RS = "\n";
    while ((cmd | getline od_line) > 0) {
        split(od_line, od_array, /[[:space:]]+/);
        for (i in od_array) {
            h = od_array[i];
            if (!match(h, /^[[:xdigit:]]{2}$/)) {
                continue;
            }
            array::push(bs_array, h);
        }
    }
    close(cmd);
    RS = save_rs;
}

function escape(str, __ARGV_END__, fmt, cmd, result) {
    fmt = "%s '%%b' %s";
    cmd = sprintf(fmt, shlex::quote(GLOBAL["PRINTF_COMMAND"]), shlex::quote(str));
    save_rs = RS;
    RS = "^$";
    cmd | getline result;
    close(cmd);
    RS = save_rs;

    return result;
}
