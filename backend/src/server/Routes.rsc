module server::Routes

import IO;

import util::Webserver;

import server::Views;

Response route(Request r){
	switch(r.path){
		case "/": return index(r);
		case "/src": return viewSrc(r);
		case "/clones": return viewClones(r);
		case "/classes": return viewClasses(r);
	}
	return jsonResponse(notFound(), (), ("message": "Failed to find route for path", "path": r.path));
}