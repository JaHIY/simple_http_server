@namespace "operator";

function truth(s) {
    return !!s;
}

function not(s) {
    return !s;
}

function is_ascii(s) {
    if (s ~ /[^\x00-\x7F]/) {
        return 0;
    }
    return 1;
}

function identity(s) {
    return s;
}

function compare(a, b) {
    if (a > b) {
        return 1;
    }
    if (a < b) {
        return -1;
    }
    return 0;
}

function min(a, b) {
    return (a < b) ? a : b;
}

function max(a, b) {
    return (a > b) ? a : b;
}

function add(a, b) {
    return a + b;
}

function minus(a, b) {
    return a - b;
}

function mul(a, b) {
    return a * b;
}

function truediv(a, b) {
    return a / b;
}

function floordiv(a, b) {
    return int(a / b);
}

function mod(a, b) {
    return a % b;
}

function pow(a, b) {
    return a ** b;
}

function neg(a) {
    return -a;
}

function pos(a) {
    return +a;
}

function and_(a, b) {
    return a && b;
}

function or_(a, b) {
    return a || b;
}

function lt(a, b) {
    return compare(a, b) < 0;
}

function le(a, b) {
    return not(gt(a, b));
}

function eq(a, b) {
    return not(ne(a, b));
}

function ne(a, b) {
    return or_(gt(a, b), lt(a, b));
}

function gt(a, b) {
    return lt(b, a);
}

function ge(a, b) {
    return not(lt(a, b));
}

function compose1(f, a, __ARGV_END__, i, fun) {
    if (awk::isarray(f)) {
        for (i = length(f); i > 0; i -= 1) {
            fun = f[i];
            a = @fun(a);
        }
        return a;
    }
    return @f(a);
}

function compose2(f, a, b, __ARGV_END__, fc, fun) {
    if (awk::isarray(f)) {
        array::copy(f, fc);
        fun = array::pop(fc);
        a = @fun(a, b);
        return compose1(fc, a);
    }
    return @f(a, b);
}
