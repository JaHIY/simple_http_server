@namespace "urllib_parse";

@load "ordchr";

@include "./lib/array.awk";
@include "./lib/number.awk";
@include "./lib/operator.awk";
@include "./lib/string.awk";

function unquote(str, __ARGV_END__, bits, res, i, len) {
    if (!match(str, "%")) {
        return str;
    }
    re_split(str, bits, @/[\x00-\x7f]+/);
    array::new(res);

    array::push(res, bits[1]);
    len = length(bits);
    for (i = 2; i <= len; i += 2) {
        array::push(res, _unquote(bits[i]));
        array::push(res, bits[i + 1]);
    }
    return array::join(res, "");
}

function re_split(str, arr, sep, __ARGV_END__, a, seps) {
    array::new(arr);

    split(str, a, sep, seps);
    array::zip_longest(a, seps, arr);
}

function _unquote(str,
                  __ARGV_END__, non_percent_group, percent_group, hex_array,
                  len, i, result, j, hlen, ret, decode_result, temp) {
    split(str, non_percent_group, /(%[[:xdigit:]]{2})+/, percent_group);
    len = length(percent_group);
    for (i = 1; i <= len; i += 1) {
        split(substr(percent_group[i], 2), hex_array, "%");
        array::map(hex_array, "number::from_hex");
        array::new(temp);
        hlen = length(hex_array);
        for (j = 1; j <= hlen;) {
            ret = string::utf8_decode_one(hex_array, decode_result, j);
            if (ret < 0) {
                array::push(temp, percent_hex(hex_array[j]));
                j += 1;
            } else {
                array::push(temp, decode_result[2]);
                j += ret;
            }
        }
        percent_group[i] = array::join(temp, "");
    }
    array::zip_longest(non_percent_group, percent_group, result);
    return array::join(result, "");
}

function _unsafe_url_bytes_to_remove(arr, __ARGV_END__, chars) {
    # Unsafe bytes to be removed per WHATWG spec
    chars = "\t\r\n";
    split(chars, arr, "");
}

function _scheme_chars(arr, __ARGV_END__, chars) {
    chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+-.";
    split(chars, arr, "");
}

function _uses_netloc(arr) {
    array::push(arr, "");
    array::push(arr, "ftp");
    array::push(arr, "http");
    array::push(arr, "gopher");
    array::push(arr, "nntp");
    array::push(arr, "telnet");
    array::push(arr, "imap");
    array::push(arr, "wais");
    array::push(arr, "file");
    array::push(arr, "mms");
    array::push(arr, "https");
    array::push(arr, "shttp");
    array::push(arr, "snews");
    array::push(arr, "prospero");
    array::push(arr, "rtsp");
    array::push(arr, "rtspu");
    array::push(arr, "rsync");
    array::push(arr, "svn");
    array::push(arr, "svn+ssh");
    array::push(arr, "sftp");
    array::push(arr, "nfs");
    array::push(arr, "git");
    array::push(arr, "git+ssh");
    array::push(arr, "ws");
    array::push(arr, "wss");
}

function _always_safe_bytes(arr, __ARGV_END__, chars) {
    chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_.-~";
    split(chars, arr, "");
}

function urlsplit(url, split_result, scheme, allow_fragments,
              __ARGV_END__, unsafe_url_bytes, i, j, has_scheme_char,
              netloc, fragment, query, split_netloc, split_url) {
    array::new(split_result);
    if (length(scheme) == 0) {
        scheme = "";
    }
    if (length(allow_fragments) == 0) {
        allow_fragments = 1;
    }

    _unsafe_url_bytes_to_remove(unsafe_url_bytes);
    for (i in unsafe_url_bytes) {
        gsub(unsafe_url_bytes[i], "", url);
        gsub(unsafe_url_bytes[i], "", scheme);
    }

    i = string::find(url, ":");
    if (i > 1) {
        has_scheme_char = 1;
        for (j = 1; j < i; j += 1) {
            if (!array::is_in("urllib_parse::_scheme_chars", substr(url, j, 1))) {
                has_scheme_char = 0;
                break;
            }
        }
        if (has_scheme_char) {
            scheme = tolower(substr(url, 1, i - 1));
            url = substr(url, i + 1);
        }
    }

    netloc = "";
    fragment = "";
    query = "";
    if (substr(url, 1, 2) == "//") {
        _splitnetloc(url, split_netloc, 3);
        netloc = split_netloc[1];
        url = split_netloc[2];

        if ((string::find(netloc, "[") && !string::find(netloc, "]")) ||
             (string::find(netloc, "]") && !string::find(netloc, "["))) {
            printf("%s\n", "urlsplit: Invalid IPv6 URL") > "/dev/stderr";
            exit(1);
        }
    }
    if (allow_fragments && string::find(url, "#")) {
        string::Split(url, split_url, "#", 1);
        url = split_url[1];
        fragment = split_url[2];
    }
    if (string::find(url, "?")) {
        string::Split(url, split_url, "?", 1);
        url = split_url[1];
        query = split_url[2];
    }
    array::push(split_result, scheme);
    array::push(split_result, netloc);
    array::push(split_result, url);
    array::push(split_result, query);
    array::push(split_result, fragment);
}

function _splitnetloc(url, result, start,
                  __ARGV_END__, delim, delimiters, i, wdelim) {
    array::new(result);
    if (length(start) == 0) {
        start = 1;
    }
    if (awk::typeof(start) != "number") {
        printf("%s\n", "_splitnetloc: third argument is not number") > "/dev/stderr";
        exit(1);
    }

    delim = length(url);
    split("/?#", delimiters, "");
    for (i in delimiters) {
        wdelim = string::find(url, delimiters[i], start);
        if (wdelim > 0) {
            delim = operator::min(delim, wdelim);
        }
    }
    array::push(result, substr(url, start, delim - 1));
    array::push(result, substr(url, start + delim - 1));
}

function urlunsplit(components, __ARGV_END__, scheme, netloc, url, query, fragment) {
    scheme = components[1];
    netloc = components[2];
    url = components[3];
    query = components[4];
    fragment = components[5];

    if (netloc ||
        (scheme && array::is_in("urllib_parse::_uses_netloc", scheme) &&
        (substr(url, 1, 2) != "//"))) {
        if (url && (substr(url, 1, 1) != "/")) {
            url = string::concat("/", url);
        }
        url = string::concat(netloc, url);
        url = string::concat("//", url);
    }
    if (scheme) {
        url = string::concat(":", url);
        url = string::concat(scheme, url);
    }
    if (query) {
        url = string::concat(url, "?");
        url = string::concat(url, query);
    }
    if (fragment) {
        url = string::concat(url, "#");
        url = string::concat(url, fragment);
    }
    return url;
}

function quote(str, safe,
           __ARGV_END__, always_safe_array, safe_array, i, char,
           safe_dict, cp_array, cp, result, utf8_seq) {
    if (length(safe) == 0) {
        safe = "/";
    }
    _always_safe_bytes(always_safe_array);
    split(safe, safe_array, "");
    array::union(safe_array, always_safe_array);
    array::filter(safe_array, "operator::is_ascii");

    for (i in safe_array) {
        char = safe_array[i];
        key = string::ord(char);
        safe_dict[key] = char;
    }

    string::code_point(str, cp_array);
    array::new(result);
    for (i in cp_array) {
        cp = cp_array[i];
        if (cp in safe_dict) {
            char = safe_dict[cp];
        } else {
            string::utf8_encode_one(cp, utf8_seq);
            array::map(utf8_seq, "urllib_parse::percent_hex");
            char = array::join(utf8_seq, "");
        }
        array::push(result, char);
    }

    return array::join(result, "");
}

function percent_hex(num) {
    return sprintf("%%%02X", num);
}
