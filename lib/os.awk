@namespace "os";

@include "./lib/array.awk";
@include "./lib/shlex.awk";

func listdir(path, filelist, __ARGV__, save_rs, cmd_array, cmd, quiet_cmd, result) {
    array::new(filelist);
    array::new(cmd_array);
    array::push(cmd_array, "find");
    array::push(cmd_array, path);
    array::push(cmd_array, "-maxdepth");
    array::push(cmd_array, "1");
    array::push(cmd_array, "-print0");
    cmd = shlex::join(cmd_array);

    array::new(cmd_array);
    array::push(cmd_array, cmd);
    array::push(cmd_array, "> /dev/null");
    array::push(cmd_array, "2> /dev/null");
    quiet_cmd = array::join(cmd_array, " ");

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

    RS = save_rs;
    return 1;
}
