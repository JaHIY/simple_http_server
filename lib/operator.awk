@namespace "operator";

func is_null(s) {
    return !!s;
}

func is_ascii(s) {
    if (s ~ /[^\x00-\x7F]/) {
        return 0;
    }
    return 1;
}

func identity(s) {
    return s;
}

func compare(a, b) {
    if (a > b) {
        return 1;
    }
    if (a < b) {
        return -1;
    }
    return 0;
}
