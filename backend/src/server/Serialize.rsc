module server::Serialize

import clonedet::Clonedet;
import IO;
import Exception;
import util::Webserver;
import server::Server;

map[loc, str] CONTENT_CACHE = ();

str readCached(loc l){
	if(l notin CONTENT_CACHE)
		CONTENT_CACHE[l] = readFile(l);
	return CONTENT_CACHE[l];
}

str url(str path, map[str, str] query=()){
	str qstr = ("" | it + (it == "" ? "?" : "&") + k + "=" + query[k] | k <- query);
	str leadingSlash = /^\// := path ? "" : "/"; 
	host = server::Server::defaultServer.uri;
	return "<host><leadingSlash><path><qstr>";
}


value serialize(list[value] values) = [serialize(v) | value v <- values];
value serialize(set[value] values) = [serialize(v) | value v <- values];
value serialize(map[str, value] m) = (k: serialize(m[k]) | value k <- m);
value serialize(map[value, value] m) = ("<k>": serialize(m[k]) | value k <- m);
value serialize(clone(int \type, int weight, set[loc] locs)) = ("type": serialize(\type), "weight": serialize(weight), "locs": serialize(locs));

value serialize(loc v){
	try {
		return (
			"uri": v.uri, 
			"offset": v.offset, 
			"length": v.length, 
			//"text": readCached(v),
			"fragmentUrl": url("/src", query=("uri": v.uri, "offset": "<v.offset>", "length": "<v.length>")),
			"fileUrl": url("/src", query=("uri": v.uri))
			);
	}
	catch UnavailableInformation : return ("uri": v.uri);
}

public value serialize(value val){
	switch(val){
		case Clone d: return serialize(d) ;
		case list[value] values: return serialize(values);
		case set[value] values: return serialize(values);
		case map[str, value] m: return serialize(m);
		case map[value, value] m: return serialize(m);
		case int v: return v;
		case real v: return v;
		case loc v: return serialize(v);
		case str v: return v;
		case v: return ("unserializable": "<v>");
	}
}
