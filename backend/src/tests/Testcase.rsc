module tests::Testcase

import server::Routes;
import util::Webserver;
import tests::TestCases;
import tests::CloneAssertion;
import IO;
import List;

list[rel[loc, set[CloneAssertion]]()] testCases = [
	getTestProjectTestCases
];



loc deserialize(map[str, value] locmap){
	loc l = |undefined:///|(0,0);
	if(str uri := locmap["uri"], int length := locmap["length"], int offset := locmap["offset"]){
		l.uri = uri;
		l.length = length;
		l.offset = offset;
	}
	return l;
}

set[tuple[int, int, set[loc]]] requestAllClones(loc project){
	str path = "/clones";
	map[str, str] options = ("project": project.uri, "NanoHttpd.QUERY_STRING": "project=<project.uri>");
	Request request = get(path, parameters=options);
	jsonResponse(_, _, dat) = route(request);
	if(list[map[str, value]] items := dat)
		return {<\type, weight, {deserialize(l) | list[map[str, value]] locs := clone["locs"], l <- locs}> | clone <- items, 
			int weight := clone["weight"], int \type := clone["type"]};
}


bool contains(loc container, loc child){
	int ctrEnd = container.offset + container.length;
	int cldEnd = child.offset + child.length;
	return container.uri == child.uri && (container.offset <= child.offset) && cldEnd <= ctrEnd; 
}

test bool testTestCases(){
	for(testCase <- testCases, <loc project, set[CloneAssertion] assertions> <- testCase()){
		set[tuple[int, int, set[loc]]] clones = requestAllClones(project);
		for(assertion <- assertions){
			bool fails = false;
			list[loc] testSet = [];
			switch(assertion){
				case atMostInRange(int cloneType, loc location, int count):{
					testSet = [l | <t, w, locs> <- clones, l <- locs, t == cloneType, contains(location, l)];
					fails = fails || size(testSet) > count;
				}
				case atLeastInRange(int cloneType, loc location, int count):{
					testSet = [l | <t, w, locs> <- clones, l <- locs, t == cloneType, contains(location, l)];
					fails = fails || size(testSet) < count;
				}
				case atLeastInRange(int cloneType, loc location, int count, int minWeight):{
					testSet = [l | <t, w, locs> <- clones, l <- locs, t == cloneType, w >= minWeight, contains(location, l)];
					fails = fails || size(testSet) < count;
				}
			}
			if(fails){
				println("Assertion failed: <assertion>");
				println("Found locations: <testSet>");
				return false;
			}
		}
	}
	return true;
}