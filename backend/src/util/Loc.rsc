module util::Loc

import lang::java::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Set;
import String;
import List;
import IO;
import util::Resources;

public M3 projectM3(loc project){
	return createM3FromEclipseProject(project);
}

public int countLinesForProject(loc project) {
	M3 m3Project = createM3FromEclipseProject(project);
	return countLinesForM3(m3Project);
}

public int countLinesForM3(M3 m3Project) {
	set[loc] files = files(m3Project);
	return sum([countLinesForLocation(file) | loc file <- files]);
}


public str getRankForLineScore(int linesOfCode){
	if(linesOfCode <= 66000){
		return "++";
	} else if(linesOfCode > 66000 && linesOfCode <= 246000){
		return "+";
	} else if(linesOfCode > 246000 && linesOfCode <= 665000){
		return "o";
	} else if(linesOfCode > 665000 && linesOfCode <= 1310000){
		return "-";
	} else {
		return "--";
	}
}

public int countLinesForLocation(loc location) {
	str fileContents = readFile(location);
	str fileContentsWithoutComments = removeComments(fileContents);
	list[str] lines = getLines(fileContentsWithoutComments);
	list[str] filteredLines = filterLines(lines);
	return size(filteredLines);
	
}

public str removeComments(str text) {
	return visit(text){
		
	    // Special case: '\"' or '"'
		case /^<s:'("|\\")'>/ => s

	    // Strings. Not 100% correct, but will work for most cases. 
	    // The goal is to prevent accidentally filtering out strings that look like comments.
		case /^<s:"((\\[a-z]|\\"|\\')|[^"\r\n\\])*">/ => s

		// /*...*/
		case /^<ws1:\s*>(\/\*([^*]+|\*[^\/])*\*\/)<ws2:\s*>/ => (ws1 + ws2) == "" ? " " : ws1 + ws2

		// //...
		case /^<s:\/\/[^\r\n]*><newline:\n?>/ => "  " 
		
		// whitelist irrelevant chars --> big performance boost
		case /^<s:[^\/"']+>/ => s 

	};
}

private list[str] getLines(str text) {
	list[str] lines = split("\n", text);
	return lines;
}

private list[str] filterLines(list[str] lines) {
	lines = mapper(lines, filterLine);
	return [line | line <- lines, line != ""];
}

private str filterLine(str line) {
	//line = replaceAll(line, "\r", "");
	line = trim(line);
	return line;
}
