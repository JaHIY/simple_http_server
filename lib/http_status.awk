@namespace "http_status";

@include "./lib/array.awk";

function new(http_status) {
    array::new(http_status);

    # informational
    insert(http_status, 100, "Continue", "Request received, please continue");
    insert(http_status, 101, "Switching Protocols", "Switching to new protocol; obey Upgrade header");
    insert(http_status, 102, "Processing", "");
    insert(http_status, 103, "Early Hints", "");

    # success
    insert(http_status, 200, "OK", "Request fulfilled, document follows");
    insert(http_status, 201, "Created", "Document created, URL follows");
    insert(http_status, 202, "Accepted", "Request accepted, processing continues off-line");
    insert(http_status, 203, "Non-Authoritative Information", "Request fulfilled from cache");
    insert(http_status, 204, "No Content", "Request fulfilled, nothing follows");
    insert(http_status, 205, "Reset Content", "Clear input form for further input");
    insert(http_status, 206, "Partial Content", "Partial content follows");
    insert(http_status, 207, "Multi-Status", "");
    insert(http_status, 208, "Already Reported", "");
    insert(http_status, 226, "IM Used", "");

    # redirection
    insert(http_status, 300, "Multiple Choices", "Object has several resources -- see URI list");
    insert(http_status, 301, "Moved Permanently", "Object moved permanently -- see URI list");
    insert(http_status, 302, "Found", "Object moved temporarily -- see URI list");
    insert(http_status, 303, "See Other", "Object moved -- see Method and URL list");
    insert(http_status, 304, "Not Modified", "Document has not changed since given time");
    insert(http_status, 305, "Use Proxy", "You must use proxy specified in Location to access this resource");
    insert(http_status, 307, "Temporary Redirect", "Object moved temporarily -- see URI list");
    insert(http_status, 308, "Permanent Redirect", "Object moved permanently -- see URI list");

    # client error
    insert(http_status, 400, "Bad Request", "Bad request syntax or unsupported method");
    insert(http_status, 401, "Unauthorized", "No permission -- see authorization schemes");
    insert(http_status, 402, "Payment Required", "No payment -- see charging schemes");
    insert(http_status, 403, "Forbidden", "Request forbidden -- authorization will not help");
    insert(http_status, 404, "Not Found", "Nothing matches the given URI");
    insert(http_status, 405, "Method Not Allowed", "Specified method is invalid for this resource");
    insert(http_status, 406, "Not Acceptable", "URI not available in preferred format");
    insert(http_status, 407, "Proxy Authentication Required", "You must authenticate with this proxy before proceeding");
    insert(http_status, 408, "Request Timeout", "Request timed out; try again later");
    insert(http_status, 409, "Conflict", "Request conflict");
    insert(http_status, 410, "Gone", "URI no longer exists and has been permanently removed");
    insert(http_status, 411, "Length Required", "Client must specify Content-Length");
    insert(http_status, 412, "Precondition Failed", "Precondition in headers is false");
    insert(http_status, 413, "Request Entity Too Large", "Entity is too large");
    insert(http_status, 414, "Request-URI Too Long", "URI is too long");
    insert(http_status, 415, "Unsupported Media Type", "Entity body in unsupported format");
    insert(http_status, 416, "Requested Range Not Satisfiable", "Cannot satisfy request range");
    insert(http_status, 417, "Expectation Failed", "Expect condition could not be satisfied");
    insert(http_status, 418, "I'm a Teapot", "Server refuses to brew coffee because it is a teapot.");
    insert(http_status, 421, "Misdirected Request", "Server is not able to produce a response");
    insert(http_status, 422, "Unprocessable Entity", "");
    insert(http_status, 423, "Locked", "");
    insert(http_status, 424, "Failed Dependency", "");
    insert(http_status, 425, "Too Early", "");
    insert(http_status, 426, "Upgrade Required", "");
    insert(http_status, 428, "Precondition Required", "The origin server requires the request to be conditional");
    insert(http_status, 429, "Too Many Requests", "The user has sent too many requests in a given amount of time (\"rate limiting\")");
    insert(http_status, 431, "Request Header Fields Too Large", "The server is unwilling to process the request because its header fields are too large");
    insert(http_status, 451, "Unavailable For Legal Reasons", "The server is denying access to the resource as a consequence of a legal demand");

    # server errors
    insert(http_status, 500, "Internal Server Error", "Server got itself in trouble");
    insert(http_status, 501, "Not Implemented", "Server does not support this operation");
    insert(http_status, 502, "Bad Gateway", "Invalid responses from another server/proxy");
    insert(http_status, 503, "Service Unavailable", "The server cannot process the request due to a high load");
    insert(http_status, 504, "Gateway Timeout", "The gateway server did not receive a timely response");
    insert(http_status, 505, "HTTP Version Not Supported", "Cannot fulfill request");
    insert(http_status, 506, "Variant Also Negotiates", "");
    insert(http_status, 507, "Insufficient Storage", "");
    insert(http_status, 508, "Loop Detected", "");
    insert(http_status, 510, "Not Extended", "");
    insert(http_status, 511, "Network Authentication Required", "The client needs to authenticate to gain network access");
}

function gen_key(s) {
    s = toupper(s);
    gsub("[[:space:]]", "_", s);
    return s;
}

function insert(http_status, code, phrase, description, __ARGV_END__, key) {
    key = gen_key(phrase);
    http_status[key]["code"] = code;
    http_status[key]["phrase"] = phrase;
    http_status[key]["description"] = description;
}
