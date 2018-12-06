module server::Views

import IO;
import String;
import util::Webserver;

// This is probably highly likely to be not very safe at all.
// Use with caution.
Response viewSrc(Request r){
	if("uri" in r.parameters){
		loc path = |nil://placeholder|(0,0);
		path.uri = r.parameters["uri"];
		if("offset" in r.parameters && "length" in r.parameters){
			path.offset = toInt(r.parameters["offset"]);
			path.length = toInt(r.parameters["length"]);
		}
		return jsonResponse(ok(), (), ("body": readFile(path)));
	}
	return jsonResponse(badRequest(), (), ("message": "expected \'uri\' query parameter"));
}

