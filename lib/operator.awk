@namespace "operator";

func truth(s) {
    return !!s;
}

func not(s) {
    return !s;
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

func min(a, b) {
    return (a < b) ? a : b;
}

func max(a, b) {
    return (a > b) ? a : b;
}

func add(a, b) {
    return a + b;
}

func minus(a, b) {
    return a - b;
}

func mul(a, b) {
    return a * b;
}

func truediv(a, b) {
    return a / b;
}

func floordiv(a, b) {
    return int(a / b);
}

func mod(a, b) {
    return a % b;
}

func pow(a, b) {
    return a ** b;
}

func neg(a) {
    return -a;
}

func pos(a) {
    return +a;
}

func and_(a, b) {
    return a && b;
}

func or_(a, b) {
    return a || b;
}

func lt(a, b) {
    return compare(a, b) < 0;
}

func le(a, b) {
    return not(gt(a, b));
}

func eq(a, b) {
    return not(ne(a, b));
}

func ne(a, b) {
    return or_(gt(a, b), lt(a, b));
}

func gt(a, b) {
    return lt(b, a);
}

func ge(a, b) {
    return not(lt(a, b));
}

func compose1(f, a, __ARGV_END__, i, fun) {
    if (awk::isarray(f)) {
        for (i = length(f); i > 0; i -= 1) {
            fun = f[i];
            a = @fun(a);
        }
        return a;
    }
    return @f(a);
}

func compose2(f, a, b, __ARGV_END__, fc, fun) {
    if (awk::isarray(f)) {
        array::copy(f, fc);
        fun = array::pop(fc);
        a = @fun(a, b);
        return compose1(fc, a);
    }
    return @f(a, b);
}
