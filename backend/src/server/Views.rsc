module server::Views

import IO;
import String;
import util::Webserver;
import lang::java::jdt::m3::AST;
import util::Resources;

import server::Serialize;
import clonedet::Clonedet;
import clonedet::ProjectAst;


map[str, str] DEFAULT_HEADERS = (
	"Access-Control-Allow-Origin": "*"
);

str resolve(Request r, str path, map[str, str] query=()){
	str qstr = ("" | it + (it == "" ? "?" : "&") + k + "=" + query[k] | k <- query); 
	return "http://<r.headers["host"]><path><qstr>";
}

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

Response viewClasses(Request r){
	if("project" in r.parameters){
		loc path = |nil://placeholder|(0,0);
		path.uri = r.parameters["project"];
		if(path.scheme == "project"){
			set[Declaration] asts = createAstsFromEclipseProjectCached(path);
			value jsondata = (c.src.uri: (
						"srcUrl": resolve(r, "/src", query=("uri": c.src.uri))
					) | c <- asts);
			return jsonResponse(ok(), DEFAULT_HEADERS, jsondata);
		}
	}
	return jsonResponse(badRequest(), DEFAULT_HEADERS, ("message": "expected \'project\' query parameter"));
}

Response index(Request r){
	println(r.headers);
	jsondata = ("projects": (project.uri: (
						"clonesUrl": resolve(r, "/clones", query=("project": project.uri)), 
						"classesUrl": resolve(r, "/classes", query=("project": project.uri)) 
					) | loc project <- projects()));
	return jsonResponse(ok(), DEFAULT_HEADERS, jsondata);
}
