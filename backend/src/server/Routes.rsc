module server::Routes

import IO;

import util::Webserver;

import server::Views;

Response route(Request r){
	switch(r.path){
		case "/src": return viewSrc(r);
	}
	return jsonResponse(notFound(), (), ("message": "Failed to find route for path", "path": r.path));
}