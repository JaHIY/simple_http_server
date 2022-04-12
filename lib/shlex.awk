@namespace "shlex";

@include "./lib/array.awk";

function join(split_command, __ARGV_END__, quote_command) {
    array::map(split_command, "shlex::quote", quote_command);
    return array::join(quote_command, " ");
}

function quote(s) {
    if (length(s) == 0) {
        return "''";
    }
    if (!_find_unsafe(s)) {
        return s;
    }
    gsub("'", "'\"'\"'", s);
    return "'" s "'";
}

function _find_unsafe(s) {
    return match(s, /[^A-Za-z0-9_@%+=:,./-]/);
}
