module server::Views

import IO;
import String;
import util::Webserver;
import lang::java::jdt::m3::AST;

import server::Serialize;
import clonedet::Clonedet;
import clonedet::ProjectAst;


map[str, str] DEFAULT_HEADERS = (
	"Access-Control-Allow-Origin": "*"
);
// This is probably highly likely to be not very safe at all.
// Use with caution.
Response viewSrc(Request r){
	if("uri" in r.parameters){
		loc path;
		if("offset" in r.parameters && "length" in r.parameters){
			path = |nil://placeholder|(0,0);
			path.uri = r.parameters["uri"];
			path.offset = toInt(r.parameters["offset"]);
			path.length = toInt(r.parameters["length"]);
		}
		else{
			path = |nil://placeholder|;
			path.uri = r.parameters["uri"];
		}
		return jsonResponse(ok(), DEFAULT_HEADERS, ("body": readFile(path)));
	}
	return jsonResponse(badRequest(), DEFAULT_HEADERS, ("message": "expected \'uri\' query parameter"));
}


Response viewClones(Request r){
	if("project" in r.parameters){
		loc path = |nil://placeholder|(0,0);
		path.uri = r.parameters["project"];
		if(path.scheme == "project"){
			set[Declaration] asts = createAstsFromEclipseProjectCached(path);
			list[Clone] clones = uniqClones(type2OrderedClones(path, asts = asts)) + uniqClones(type1OrderedClones(path, asts = asts));
			value jsondata = serialize(clones);
			return jsonResponse(ok(), DEFAULT_HEADERS, jsondata);
		}
	}
	return jsonResponse(badRequest(), DEFAULT_HEADERS, ("message": "expected \'project\' query parameter"));
}

