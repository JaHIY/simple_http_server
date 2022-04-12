@namespace "array";

@include "./lib/operator.awk";

function push(arr, value) {
    arr[length(arr) + 1] = value;
}

function pop(arr, __ARGV_END__, value, len) {
    len = length(arr);
    value = arr[len];
    delete arr[len];
    return value;
}

function unshift(arr, value, __ARGV_END__, new_arr) {
    new_arr[1] = value;
    concat(new_arr, arr);
    copy(new_arr, arr);
}

function shift(arr, __ARGV_END__, value, new_arr) {
    value = arr[1];
    delete arr[1];
    array::new(new_arr);
    concat(new_arr, arr);
    copy(new_arr, arr);
    return value;
}

function concat(arr1, arr2, __ARGV_END__, i) {
    for (i in arr1) {
        push(arr1, arr2[i]);
    }
}

function join(arr, sep, start, end, __ARGV_END__, result, i) {
    if (length(start) == 0) {
        start = 1;
    }
    if (length(end) == 0) {
        end = length(arr);
    }
    if (awk::typeof(start) != "number") {
        printf("%s\n", "join: third argument is not number") > "/dev/stderr";
        exit(1);
    }
    if (awk::typeof(end) != "number") {
        printf("%s\n", "join: forth argument is not number") > "/dev/stderr";
        exit(1);
    }

    start = awk::strtonum(sprintf("%d", start));
    end = awk::strtonum(sprintf("%d", end));

    result = arr[start];
    for (i = start + 1; i <= end; i++) {
        result = sprintf("%s%s%s", result, sep, arr[i]);;
    }
    return result;
}

function contains(arr, target, __ARGV_END__, i) {
    for (i in arr) {
        if (arr[i] == target) {
            return 1;
        }
    }
    return 0;
}

function is_in(array_f, target, __ARGV_END__, arr) {
    @array_f(arr);
    return contains(arr, target);
}

function clear(arr, __ARGV_END__, i) {
    for (i in arr) {
        delete arr[i];
    }
}

function new(arr) {
    arr[0] = "";
    clear(arr);
}

function copy(from, to, __ARGV_END__, i) {
    new(to);
    for (i in from) {
        to[i] = from[i];
    }
}

function filter(arr, fun, new_arr, __ARGV_END__, in_place, i, len, item) {
    if (awk::isarray(new_arr)) {
        in_place = 0;
    } else {
        in_place = 1;
    }

    new(new_arr);
    len = length(arr);
    for (i = 1; i <= len; i += 1) {
        item = arr[i];
        if (@fun(item)) {
            push(new_arr, item);
        }
    }
    if (in_place) {
        copy(new_arr, arr);
    }
}

function map(arr, fun, new_arr, __ARGV_END__, in_place, i) {
    if (awk::isarray(new_arr)) {
        in_place = 0;
    } else {
        in_place = 1;
    }

    new(new_arr);
    for (i in arr) {
        new_arr[i] = @fun(arr[i]);
    }
    if (in_place) {
        copy(new_arr, arr);
    }
}

function union(arr1, arr2, new_arr, __ARGV_END__, dict, i, item, in_place) {
    if (awk::isarray(new_arr)) {
        in_place = 0;
    } else {
        in_place = 1;
    }

    new(new_arr);

    for (i in arr1) {
        item = arr1[i];
        dict[item] = 1;
    }

    for (i in arr2) {
        item = arr2[i];
        dict[item] = 1;
    }

    for (i in dict) {
        array::push(new_arr, i);
    }

    if (in_place) {
        copy(new_arr, arr1);
    }
}

function swap(arr, i, j, __ARGV_END__, t) {
    t = arr[i];
    arr[i] = arr[j];
    arr[j] = t;
}

function qsort_by(arr, left, right, key, reverse, __ARGV_END__, r, last, i, arr_i, arr_left) {
    if (left >= right) {
        return;
    }

    r = 1;
    if (reverse == 1) {
        r = -1;
    }
    if (length(key) == 0) {
        key = "operator::identity";
    }

    swap(arr, left, int((left + right) / 2));
    last = left;
    for (i = left + 1; i <= right; i++) {
        arr_i = @key(arr[i]);
        arr_left = @key(arr[left]);
        if (operator::compare(arr_i, arr_left) * r < 0) {
            last += 1;
            swap(arr, last, i);
        }
    }
    swap(arr, left, last);
    qsort_by(arr, left, last - 1, key, reverse);
    qsort_by(arr, last + 1, right, key, reverse);
}

function sortd_by(arr, key, reverse) {
    qsort_by(arr, 1, length(arr), key, reverse);
}

function sort_by(arr, new_arr, key, reverse) {
    copy(arr, new_arr);
    qsort_by(new_arr, 1, length(new_arr), key, reverse);
}

function reduce(arr, fun, init, __ARGV_END__, len, i, start, result) {
    start = 1;
    if (awk::typeof(init) == "untyped") {
        init = arr[start];
        start += 1;
    }
    len = length(arr);
    result = init;
    for (i = start; i <= len; i += 1) {
        result = operator::compose2(fun, result, arr[i]);
    }
    return result;
}

function sum(arr) {
    return reduce("operator::add", arr);
}

function setitem(arr, i, v) {
    arr[i] = v;
    return v;
}

function getitem(arr, i) {
    return arr[i];
}

function delitem(arr, i, __ARGV_END__, v) {
    v = arr[i];
    delete arr[i];
    return v;
}

function all(arr, fun, __ARGV_END__, i) {
    for (i in arr) {
        if (!operator::compose1(fun, arr[i])) {
            return 0;
        }
    }
    return 1;
}

function notall(arr, fun) {
    return operator::not(all(arr, fun));
}

function any(arr, fun, __ARGV_END__, i, f) {
    return operator::not(none(arr, fun));
}

function none(arr, fun) {
    f[1] = "operator::not";
    if (awk::isarray(fun)) {
        concat(f, fun);
    } else {
        push(f, fun);
    }
    return all(arr, f);
}

function zip(arr1, arr2, new_arr, __ARGV_END__, len, i, in_place) {
    if (awk::isarray(new_arr)) {
        in_place = 0;
    } else {
        in_place = 1;
    }

    new(new_arr);

    len = operator::min(length(arr1), length(arr2));
    for (i = 1; i <= len; i += 1) {
        push(new_arr, arr1[i]);
        push(new_arr, arr2[i]);
    }

    if (in_place) {
        copy(new_arr, arr1);
    }
}

function zip_longest(arr1, arr2, new_arr, __ARGV_END__, len1, len2, minlen, i, in_place) {
    if (awk::isarray(new_arr)) {
        in_place = 0;
    } else {
        in_place = 1;
    }

    new(new_arr);
    zip(arr1, arr2, new_arr);
    len1 = length(arr1);
    len2 = length(arr2);
    minlen = operator::min(len1, len2);
    if (len1 > len2) {
        for (i = minlen + 1; i <= len1; i += 1) {
            push(new_arr, arr1[i]);
        }
    } else {
        for (i = minlen + 1; i <= len2; i += 1) {
            push(new_arr, arr2[i]);
        }
    }

    if (in_place) {
        copy(new_arr, arr1);
    }
}
