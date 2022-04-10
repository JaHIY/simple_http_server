@namespace "html";

func escape(str, quote_flag) {
    gsub("&", "&amp;", str);
    gsub("<", "&lt;", str);
    gsub(">", "&gt;", str);
    if (quote_flag) {
        gsub("\"", "&quot;", str);
        gsub("'", "&#x27;", str);
    }
    return str;
}
