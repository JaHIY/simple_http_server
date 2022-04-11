#!/usr/bin/gawk -f

@load "readfile";
@load "filefuncs";

@include "./lib/http_server.awk";
@include "./lib/html.awk";
@include "./lib/operator.awk";
@include "./lib/os.awk";
@include "./lib/posixpath.awk";
@include "./lib/urllib_parse.awk";

BEGIN {
    if (length(Port) == 0) {
        Port = "8080";
    }
    if (length(Dir) == 0) {
        Dir = ".";
    }
    serve_forever(Port, Dir);
}

func serve_forever(port, dir) {
    while (1) {
        run(port, dir);
    }
}

func run(port, dir, __ARGV_END__, store) {
    store["http_server"] = sprintf("/inet/tcp/%d/0/0", port);
    store["directory"] = dir;
    http_server::init(store);
    http_server::handle(store);
    close(store["http_server"]);
}

func do_GET(store, __ARGV_END__, content) {
    content = send_head(store);
    if (content) {
        printf("%s\r\n", content) |& store["http_server"];
    }
}

func do_HEAD(store) {
    send_head(store);
}

func send_head(store,
               __ARGV_END__, path, parts, new_url, index_files, ii, has_index_file,
               ctype, ret, sdata, content) {
    path = translate_path(store["path"], store["directory"]);
    if (posixpath::isdir(path) == 1) {
        urllib_parse::urlsplit(path, parts);
        if (!string::endswith(parts[3], "/")) {
            http_server::send_response(store, store["HTTPStatus"]["MOVED_PERMANENTLY"]);
            parts[3] = string::concat(parts[3], "/");
            new_url = urllib_parse::urlunsplit(parts);
            http_server::send_header(store, "Location", new_url);
            http_server::send_header(store, "Content-Length", "0");
            http_server::end_headers(store);
            return;
        }
        array::new(index_files);
        array::push(index_files, "index.html");
        array::push(index_files, "index.htm");
        has_index_file = 0;
        for (i in index_file) {
            i = posixpath::join(path, i);
            if (posixpath::exists(i)) {
                path = i;
                has_index_file = 1;
                break;
            }
        }
        if (!has_index_file) {
            return list_directory(store, path);
        }
    }
    ctype = guess_type(path);
    if (string::endswith(path, "/")) {
        http_server::send_error(store, store["HTTPStatus"]["NOT_FOUND"], "File not found");
        return;
    }
    ret = stat(path, sdata);
    if (ret < 0) {
        http_server::send_error(store, store["HTTPStatus"]["NOT_FOUND"], "File not found");
        return;
    }
    content = readfile(path);
    if (content == "" && ERRNO != "") {
        send_error(store, store["HTTPStatus"]["NOT_FOUND"], "File not found");
        return;
    }
    http_server::send_response(store, store["HTTPStatus"]["OK"]);
    http_server::send_header(store, "Content-type", ctype);
    http_server::send_header(store, "Content-Length", sdata["size"]);
    http_server::send_header(store, "Last-Modified", http_server::date_time_string(sdata["mtime"]));
    http_server::end_headers(store);
    return content;
}

func list_directory(store, path,
                    __ARGV_END__, ret, list, displaypath, title, r, i, name, fullname,
                    displayname, linkname, text) {
    ret = os::listdir(path, list);
    if (!ret) {
        http_server::send_error(store, store["HTTPStatus"]["NOT_FOUND"], "No permission to list directory");
        return;
    }
    displaypath = urllib_parse::unquote(store["path"]);
    displaypath = html::escape(displaypath, 0);
    title = sprintf("Directory listing for %s", displaypath);
    array::new(r);
    array::push(r, "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">");
    array::push(r, "<html>\n<head>");
    array::push(r, "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">");
    array::push(r, sprintf("<title>%s</title>\n</head>", title));
    array::push(r, sprintf("<body>\n<h1>%s</h1>", title));
    array::push(r, "<hr>\n<ul>");
    for (i in list) {
        name = list[i];
        fullname = posixpath::join(path, name);
        linkname = name;
        displayname = name;
        if (posixpath::isdir(fullname) == 1) {
            displayname = string::concat(name, "/");
            linkname = string::concat(name, "/");
        }
        if (posixpath::islink(fullname) == 1) {
            displayname = string::concat(name, "@");
        }
        array::push(r, sprintf("<li><a href=\"%s\">%s</a></li>", urllib_parse::quote(linkname), html::escape(displayname, 0)));
    }
    array::push(r, "</ul>\n<hr>\n</body>\n</html>\n");
    text = array::join(r, "\n");
    http_server::send_response(store, store["HTTPStatus"]["OK"]);
    http_server::send_header(store, "Content-type", "text/html; charset=utf-8");
    http_server::send_header(store, "Content-Length", length(text));
    http_server::end_headers(store);
    return text;
}

func translate_path(path, dir, __ARGV_END__, p, trailing_slash, words, i, word) {
    split(path, p, "?");
    path = p[1];
    split(path, p, "#");
    path = p[1];
    trailing_slash = (path ~ /\/[[:space:]]*$/);
    path = urllib_parse::unquote(path);
    path = posixpath::normpath(path);
    split(path, words, "/");
    array::filter(words, "operator::is_null");
    path = dir;
    for (i in words) {
        word = words[i];
        if (posixpath::dirname(word) || (word == "." || word == "..")) {
            continue;
        }
        path = posixpath::join(path, word);
    }
    if (trailing_slash) {
        path = string::concat(path, "/");
    }
    return path;
}

func guess_type(path) {
    return "application/octet-stream";
}
