@namespace "os";

@include "./lib/array.awk";
@include "./lib/shlex.awk";
@include "./lib/string.awk";

BEGIN {
    GLOBAL["FIND_COMMAND"] = "find";
}

function listdir(path, filelist, __ARGV__, save_rs, fmt, cmd, quiet_cmd, result) {
    array::new(filelist);
    fmt = "%s %s -maxdepth 1 -print0";
    cmd = sprintf(fmt, shlex::quote(GLOBAL["FIND_COMMAND"]), shlex::quote(path));
    quiet_cmd = string::concat(cmd, " > /dev/null 2> /dev/null");

    if (system(quiet_cmd)) {
        return 0;
    }

    save_rs = RS;
    RS = "\0";

    while ((cmd | getline result) > 0) {
        if (result == path) {
            continue;
        }
        sub(/^.*\//, "", result);
        array::push(filelist, result);
    }
    close(cmd);
    array::sortd_by(filelist, "tolower");

    RS = save_rs;
    return 1;
}
