@namespace "array";

func push(arr, value) {
    arr[length(arr) + 1] = value;
}

func pop(arr) {
    delete arr[length(arr)];
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