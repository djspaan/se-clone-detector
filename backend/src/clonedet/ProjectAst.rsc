module clonedet::ProjectAst

import lang::java::jdt::m3::AST;


map[loc, set[Declaration]] CACHE = ();

set[Declaration] createAstsFromEclipseProjectCached(loc project){
	if(project notin CACHE) 	
		CACHE[project] = createAstsFromEclipseProject(project, true);
		
	return CACHE[project];
}
