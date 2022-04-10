@namespace "posixpath";

@load "filefuncs";

@include "./lib/array.awk";
@include "./lib/string.awk";

func normpath(path,
              __ARGV_END__, sep, empty, dot, dotdot, initial_slashes,
              i, comps, new_comps, comp, nlen) {
    sep = "/";
    empty = "";
    dot = ".";
    dotdot = "..";

    if (path == empty) {
        return dot;
    }

    initial_slashes = string::startswith(path, sep);

    if (initial_slashes &&
        (string::startswith(path, string::repeat(sep, 2))) &&
        (!string::startswith(path, string::repeat(sep, 3)))) {
        initial_slashes = 2;
    }
    split(path, comps, sep);

    array::new(new_comps);

    for (i in comps) {
        comp = comps[i];
        if ((comp == empty) || (comp == dot)) {
            continue;
        }

        nlen = length(new_comps);
        if ((comp != dotdot) || (!initial_slashes && (nlen == 0)) ||
             ((nlen > 0) && (new_comps[nlen] == dotdot))) {
            array::push(new_comps, comp);
        } else if (nlen > 0) {
            array::pop(new_comps);
        }
    }
    path = array::join(new_comps, sep);

    if (initial_slashes) {
        path = sprintf("%s%s", string::repeat(sep, initial_slashes), path)
    }
    if (length(path) > 0) {
        return path;
    }
    return dot;
}

func _get_sep() {
    return "/";
}

func dirname(path, __ARGV_END__, sep, i, head) {
    sep = _get_sep();
    i = string::rfind(path, sep);
    head = substr(path, 1, i - 1);
    if (head && (head != string::repeat(sep, length(head)))) {
        head = string::rstrip(head, sep);
    }
    return head;
}

func join(a, p, __ARGV_END__, sep, path) {
    sep = _get_sep();
    path = a;
    if (string::startswith(p, sep)) {
        path = p;
    } else if ((length(path) == 0) || string::endswith(path, sep)) {
        path = string::concat(path, p);
    } else {
        path = string::concat(path, string::concat(sep, p));
    }
    return path;
}

func isdir(path, __ARGV_END__, ret, stat_data) {
    ret = awk::stat(path, stat_data);
    if (ret < 0) {
        printf("isdir: could not stat '%s`: %s\n", path, ERRNO) > "/dev/stderr";
        exit(1);
    }
    return (stat_data["type"] == "directory");
}

func islink(path, __ARGV_END__, ret, stat_data) {
    ret = awk::stat(path, stat_data);
    if (ret < 0) {
        printf("islink: could not stat '%s`: %s\n", path, ERRNO) > "/dev/stderr";
        exit(1);
    }
    return (stat_data["type"] == "symlink");
}

func exists(path, __ARGV_END__, ret) {
    ret = awk::stat(path);
    if (ret < 0) {
        return 0;
    }
    return 1;
}
