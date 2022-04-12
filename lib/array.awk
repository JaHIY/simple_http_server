@namespace "array";

@include "./lib/operator.awk";

func push(arr, value) {
    arr[length(arr) + 1] = value;
}

func pop(arr, __ARGV_END__, value, len) {
    len = length(arr);
    value = arr[len];
    delete arr[len];
    return value;
}

func unshift(arr, value, __ARGV_END__, i, new_arr) {
    new_arr[1] = value;
    concat(new_arr, arr);
    copy(new_arr, arr);
}

func shift(arr, __ARGV_END__, value, i, new_arr) {
    value = arr[1];
    delete arr[1];
    array::new(new_arr);
    concat(new_arr, arr);
    copy(new_arr, arr);
    return value;
}

func concat(arr1, arr2, __ARGV_END__, i) {
    for (i in arr1) {
        push(arr1, arr2[i]);
    }
}

func join(arr, sep, start, end, __ARGV_END__, result, i) {
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

func contains(arr, target, __ARGV_END__, i) {
    for (i in arr) {
        if (arr[i] == target) {
            return 1;
        }
    }
    return 0;
}

func is_in(array_f, target, __ARGV_END__, arr) {
    @array_f(arr);
    return contains(arr, target);
}

func clear(arr, __ARGV_END__, i) {
    for (i in arr) {
        delete arr[i];
    }
}

func new(arr) {
    arr[0] = "";
    clear(arr);
}

func copy(from, to, __ARGV_END__, i) {
    new(to);
    for (i in from) {
        to[i] = from[i];
    }
}

func filter(arr, fun, new_arr, __ARGV_END__, in_place, i, len, item) {
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

func map(arr, fun, new_arr, __ARGV_END__, in_place, i) {
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

func union(arr1, arr2, new_arr, __ARGV_END__, dict, i, item) {
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

func swap(arr, i, j, __ARGV_END__, t) {
    t = arr[i];
    arr[i] = arr[j];
    arr[j] = t;
}

func qsort_by(arr, left, right, key, reverse, __ARGV_END__, r, last, i, arr_i, arr_left) {
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

func sortd_by(arr, key, reverse) {
    qsort_by(arr, 1, length(arr), key, reverse);
}

func sort_by(arr, new_arr, key, reverse) {
    copy(arr, new_arr);
    qsort_by(new_arr, 1, length(new_arr), key, reverse);
}

func reduce(arr, fun, init, __ARGV_END__, len, i, start, result) {
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

func sum(arr) {
    return reduce("operator::add", arr);
}

func setitem(arr, i, v) {
    arr[i] = v;
    return v;
}

func getitem(arr, i) {
    return arr[i];
}

func delitem(arr, i, __ARGV_END__, v) {
    v = arr[i];
    delete arr[i];
    return v;
}

func all(arr, fun, __ARGV_END__, i) {
    for (i in arr) {
        if (!operator::compose1(fun, arr[i])) {
            return 0;
        }
    }
    return 1;
}

func notall(arr, fun) {
    return operator::not(all(arr, fun));
}

func any(arr, fun, __ARGV_END__, i, f) {
    return operator::not(none(arr, fun));
}

func none(arr, fun) {
    f[1] = "operator::not";
    if (awk::isarray(fun)) {
        concat(f, fun);
    } else {
        push(f, fun);
    }
    return all(arr, f);
}
