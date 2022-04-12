@namespace "http_server";

@include "./lib/array.awk";
@include "./lib/html.awk";
@include "./lib/http_status.awk";

function serve_forever(port) {
    while (1) {
        run(port);
    }
}

function run(port, __ARGV_END__, store) {
    store["http_server"] = sprintf("/inet/tcp/%d/0/0", port);
    init(store);
    handle(store);
    close(store["http_server"]);
}

function init(store) {
    store["HTTPStatus"][0] = "";
    array::new(store["HTTPStatus"]);
    http_status::new(store["HTTPStatus"]);

    store["__version__"] = "0.1";
    store["server_version"] = sprintf("SimpleHTTP/%s", store["__version__"]);
    store["sys_version"] = sprintf("GNU Awk/%s", PROCINFO["version"]);
    store["default_request_version"] = "HTTP/0.9";
    store["protocol_version"] = "HTTP/1.0";
    store["error_message_format"] = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">\n\
    <html>\n\
        <head>\n\
            <meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\">\n\
            <title>Error response</title>\n\
        </head>\n\
        <body>\n\
            <h1>Error response</h1>\n\
            <p>Error code: %d</p>\n\
            <p>Message: %s.</p>\n\
            <p>Error code explanation: %d - %s.</p>\n\
        </body>\n\
    </html>";
    store["error_content_type"] = "text/html;charset=utf-8";
}

function parse_request(store, __ARGV_END__,
                   version, words, base_version_number, version_number,
                   command, path, conntype, expect) {
    store["command"] = "";
    store["request_version"] = store["default_request_version"];
    version = store["default_request_version"];
    store["close_connection"] = 1;

    split(store["requestline"], words, /[[:space:]]+/);
    if (length(words) == 0) {
        return 0;
    }

    if (length(words) >= 3) {
        version = words[length(words)];
        if (version !~ /^HTTP\//) {
            send_error(store, store["HTTPStatus"]["BAD_REQUEST"], sprintf("Bad request version (%s)", version));
            return 0;
        }
        split(version, base_version_number, "/");
        split(base_version_number[2], version_number, ".");
        if (length(version_number) != 2) {
            send_error(store, store["HTTPStatus"]["BAD_REQUEST"], sprintf("Bad request version (%s)", version));
            return 0;
        }
        if ((version_number[1] >= 1) && (version_number[2] >= 1) &&
             (store["protocol_version"] >= "HTTP/1.1")) {
            store["close_connection"] = 0;
        }
        if ((version_number[1] >= 2) && (version_number[2] >= 0)) {
            send_error(store, store["HTTPStatus"]["HTTP_VERSION_NOT_SUPPORTED"], sprintf("Invalid HTTP version (%s)", base_version_number[2]));
            return 0;
        }
        store["request_version"] = version;
    }

    if ((length(words) < 2) || (length(words) > 3)) {
        send_error(store, store["HTTPStatus"]["BAD_REQUEST"], sprintf("Bad request syntax (%s)", store["requestline"]));
        return 0;
    }

    command = words[1];
    path = words[2];
    if (length(words) == 2) {
        store["close_connection"] = 1;
        if (command != "GET") {
            send_error(store, store["HTTPStatus"]["BAD_REQUEST"], sprintf("Bad HTTP/0.9 request type (%s)", command));
            return 0;
        }
    }
    store["command"] = command;
    store["path"] = path;

    parse_headers(store);

    conntype = store["headers"]["Connection"];
    if (tolower(conntype) == "close") {
        store["close_connection"] = 1;
    } else if ((tolower(conntype) == "keep-alive") &&
           (store["protocol_version"] >= "HTTP/1.1")) {
        store["close_connection"] = 0;
    }
    expect = store["headers"]["Expect"];
    if ((tolower(expect) == "100-continue") &&
         (store["protocol_version"] >= "HTTP/1.1") &&
         (store["request_version"] >= "HTTP/1.1")) {
        if (!handle_expect_100(store)) {
            return 0;
        }
    }
    return 1;
}

function parse_headers(store, __ARGV_END__,
                   save_rs, line, strpos, match_group, key, value) {
    store["headers"][0] = "";
    array::new(store["headers"]);

    while (1) {
        save_rs = RS;
        RS = "\r\n";
        store["http_server"] |& getline line;
        RS = save_rs;
        if (length(line) > 65536) {
            send_error(store, store["HTTPStatus"]["REQUEST_HEADER_FIELDS_TOO_LARGE"], "Line too long");
            return 0;
        }
        strpos = match(line, /:[[:space:]]+/, match_group);
        if (strpos > 0) {
            key = substr(line, 1, strpos - 1);
            value = substr(line, strpos + length(match_group[0]));
            store["headers"][key] = value;
        }
        if (length(store["headers"]) > 100) {
            send_error(store, store["HTTPStatus"]["REQUEST_HEADER_FIELDS_TOO_LARGE"], "Too many headers");
            return 0;
        }
        if ((line == "\r\n") || (line == "\n") || (line == "")) {
            break;
        }
    }
}

function handle_expect_100(store) {
    send_response_only(store, store["HTTPStatus"]["CONTINUE"]);
    end_headers(store);
    return 1;
}

function handle(store) {
    store["close_connection"] = 1;

    handle_one_request(store);
    while (!store["close_connection"]) {
        handle_one_request(store);
    }
}

function handle_one_request(store, __ARGV_END__, save_rs, ret, method) {
    save_rs = RS;
    RS = "\r\n";
    ret = store["http_server"] |& getline store["requestline"];
    RS = save_rs;
    if (ret > 0) {
        if (length(store["requestline"]) > 65536) {
            store["requestline"] = "";
            store["request_version"] = "";
            store["command"] = "";
            send_error(store, store["HTTPStatus"]["REQUEST_URI_TOO_LONG"]);
            return;
        }
        if (length(store["requestline"]) == 0) {
            store["close_connection"] = 1;
            return;
        }
        if (!parse_request(store)) {
            return
        }

        method = mname(store["command"]);
        if (!(method in PROCINFO["identifiers"]) || PROCINFO["identifiers"][method] != "user") {
            send_error(store, store["HTTPStatus"]["NOT_IMPLEMENTED"], sprintf("Unsupported method (%s)", store["command"]));
            return;
        }
        @method(store);
        fflush(store["http_server"]);
    }
}

function mname(command) {
    return sprintf("do_%s", command);
}

function send_error(store, http_status, message, explain, __ARGV_END__, body) {
    if (length(message) == 0) {
        message = http_status["phrase"];
    }
    if (length(explain) == 0) {
        explain = http_status["description"];
    }
    log_error(sprintf("code %d, message %s", http_status["code"], message));
    send_response(store, http_status, message);
    send_header(store, "Connection", "close");

    body = "";
    if ((http_status["code"] >= 200) &&
        (http_status["code"] != store["HTTPStatus"]["NO_CONTENT"]["code"]) &&
        (http_status["code"] != store["HTTPStatus"]["RESET_CONTENT"]["code"]) &&
        (http_status["code"] != store["HTTPStatus"]["NOT_MODIFIED"]["code"])) {
        body = sprintf(store["error_message_format"], http_status["code"], html::escape(message, 0), http_status["code"], html::escape(explain, 0));
        send_header(store, "Content-Type", store["error_content_type"]);
        send_header(store, "Content-Length", length(body));
    }
    end_headers(store);

    if ((store["command"] != "HEAD") && (length(body) > 0)) {
        printf("%s", body) |& store["http_server"];
    }
}

function send_response(store, http_status, message) {
    log_request(store, http_status, "-");
    send_response_only(store, http_status, message);
    send_header(store, "Server", version_string(store));
    send_header(store, "Date", date_time_string());
}

function send_response_only(store, http_status, message) {
    if (store["request_version"] != "HTTP/0.9") {
        if (length(message) == 0) {
            message = http_status["phrase"];
        }
        if (!("_headers_buffer" in store)) {
            store["_headers_buffer"][0] = "";
            array::new(store["_headers_buffer"]);
        }
        array::push(store["_headers_buffer"], sprintf("%s %d %s", store["protocol_version"], http_status["code"], message));
    }
}

function send_header(store, key, value) {
    if (store["request_version"] != "HTTP/0.9") {
        if (!("_headers_buffer" in store)) {
            store["_headers_buffer"][0] = "";
            array::new(store["_headers_buffer"]);
        }
        array::push(store["_headers_buffer"], sprintf("%s: %s", key, value));
    }
}

function end_headers(store) {
    if (store["request_version"] != "HTTP/0.9") {
        array::push(store["_headers_buffer"], "");
        flush_headers(store);
    }
}

function flush_headers(store) {
    if ("_headers_buffer" in store) {
        printf("%s\r\n", array::join(store["_headers_buffer"], "\r\n")) |& store["http_server"];
        delete store["_headers_buffer"];
    }
}

function log_request(store, http_status, size, __ARGV_END__, code) {
    code = "-";
    if (http_status::gen_key(http_status["phrase"]) in store["HTTPStatus"]) {
        code = http_status["code"];
    }
    log_message(sprintf("\"%s\" %s %s", store["requestline"], code, size));
}

function log_error(message) {
    log_message(message);
}

function log_message(message) {
    printf("[%s] %s\n", log_date_time_string(), message) > "/dev/stderr";
}

function version_string(store) {
    return sprintf("%s %s", store["server_version"], store["sys_version"]);
}

function date_time_string(timestamp) {
    if (length(timestamp) == 0) {
        timestamp = awk::systime();
    }
    return awk::strftime("%a, %d %b %Y %H:%M:%S GMT", timestamp, 1);
}

function log_date_time_string() {
    return awk::strftime("%d/%m/%y %H:%M:%S");
}
