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
		println(path);
		return response(ok(), "text/plain", DEFAULT_HEADERS, readFile(path));
	}
	return jsonResponse(badRequest(), DEFAULT_HEADERS, ("message": "expected \'uri\' query parameter"));
}


Response viewClones(Request r){
	if("project" in r.parameters){
		loc path = |nil://placeholder|(0,0);
		path.uri = r.parameters["project"];
		if(path.scheme == "project"){
			set[Declaration] asts = createAstsFromEclipseProjectCached(path);
			list[Clone] clones = uniqClones(type2OrderedClones(path, asts = asts))
				 + uniqClones(type1OrderedClones(path, asts = asts));
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
			value jsondata = ("classes": [(
			            "uri": c.src.uri,
						"srcUrl": url("/src", query=("uri": c.src.uri))
					 )| c <- asts]);
			return jsonResponse(ok(), DEFAULT_HEADERS, jsondata);
		}
	}
	return jsonResponse(badRequest(), DEFAULT_HEADERS, ("message": "expected \'project\' query parameter"));
}

Response viewProjects(Request r){
	jsondata = ("projects": (project.uri: (
						"clonesUrl": url("/clones", query=("project": project.uri)), 
						"classesUrl": url("/classes", query=("project": project.uri)) 
					) | loc project <- projects()));
	return jsonResponse(ok(), DEFAULT_HEADERS, jsondata);
}

Response apiBrowser(Request r){
	html = "
	\<html\>
	\<head\>
	\<meta charset=\"utf-8\"\>
	\</head\>
	\<body style=\"margin:10px;font-family:sans-serif;\"\>
	\<h2\>API browser\<h2\>
	\<div id=\"wrapper\"\>
	\<input readonly id=\"location\" style=\"width: 100%; height:35px; margin: 5px 0; border-radius:5px; border:1px solid grey; padding: 5px 10px; font-size:20px\"\> 
	\<iframe id=\"browser\" src=\"/projects\" style=\"border:none;width:100%;height:calc(100% - 65px);background-color:#eee;\"\>\</iframe\>
	\</div\>
	\</body\>
	\<script\>
	function replacer(k, v){
		if(typeof v !== `string`) return v;
		if(!k.endsWith(`Url`)){
			const div = document.createElement(`div`);
			div.innerText = v;
			return div.innerHTML;			
		}
		console.log(`${v}`);
		return `\<a href=${v}\>${v}\</a\>`;
	}
	document.querySelector(\'#browser\').onload = (e) =\>{
		try{
			const jsonText = JSON.stringify(JSON.parse(e.target.contentDocument.body.innerText), replacer, \'  \');
			e.target.contentDocument.querySelector(\'pre\').innerHTML = jsonText;
		} catch(e){}
		document.querySelector(\'#location\').value = e.target.contentWindow.location.href;
	}
	\</script\>
	\</html\>
	";
	return response(ok(), "text/html", DEFAULT_HEADERS, html);
}

