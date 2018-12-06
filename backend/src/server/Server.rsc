module server::Server

import Exception;
import IO;
import util::Webserver;

import server::Routes;

loc defaultServer = |http://localhost:8082|;


void startServer(loc server = defaultServer){
	stopServer(server=server);
	serve(server,
		Response (Request r){
			return route(r);
		}
	);
	println("Started server");
	println("Listening: <server>");
}

void stopServer(loc server = defaultServer){
	try {
		shutdown(server);
		println("Shut down server");
	}
	catch IllegalArgument(loc e, "could not shutdown"):{
		;
	}
}