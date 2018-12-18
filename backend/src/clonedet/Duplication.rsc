module clonedet::Duplication

import IO;
import String;
import List;
import Set;
import Map;
import Exception;
import util::Math;
import util::Benchmark;

import lang::java::jdt::m3::AST;

import util::Loc;
import util::Trie;


str readJavaFile(loc mloc){
	return removeComments(readFile(mloc));
}

rel[str, loc] srcs(set[Declaration] asts){
	return {<readJavaFile(ast.src), ast.src> | Declaration ast <- asts};
}

/*
 * Split method body to lines;
 */
rel[list[str], loc] lines(set[Declaration] asts){
	return {<[trim(line)| line <- split("\n", src)], mloc> | <str src, loc mloc> <- srcs(asts)};
}

data Line = clean(str, loc src = |undefined:///|, int lineNo = 0) | skip(str, loc src = |undefined:///|, int lineNo = 0);

/*
 * Clean invalid (empty) lines
 */
rel[list[Line], loc] cleanLines(set[Declaration] asts){
	rel[list[Line], loc] lines = {};
	for(Declaration ast <- asts){
		str text = readFile(ast.src);
		list[int] lineBoundaries = [0];
		int n = 0;
		while(n < size(text)){
			if(text[n] == "\n") lineBoundaries += n;
			n += 1;
		}
		lineBoundaries += size(text);
		list[Line] fileLines = [];
		bool openComment = false;
		for(int i <- [1..size(lineBoundaries)]){
			<offset, stop> = <lineBoundaries[i - 1], lineBoundaries[i]>;
			loc src = |undefined:///|(offset, stop - offset);
			src.uri = ast.src.uri;
			str line = text[offset..stop];
			bool isValid;
			<line, openComment, isValid> = validLine(line, openComment);
			fileLines += isValid ? clean(line, src=src, lineNo=i): skip(line, src=src, lineNo=i);
		}
		lines += <fileLines, ast.src>;
	}
	return lines;
} 

tuple[str, bool, bool] validLine(str l, bool openComment){
	l = trim(l);
	if(size(l) == 0) return <"", openComment, false>;
	if(/^import\s+/ := l) return <"", openComment, false>;
	str result;
	result = visit(l){
		case /^<s:'("|\\")'>/ => s
		case /^<s:"((\\[a-z]|\\"|\\')|[^"\r\n\\])*">/ => s
		case /^(\/\*([^*]+|\*[^\/])*)/ => {openComment = true; "";}
		case /^\*\// => {openComment = false; "";}
		case /^<s:\/\/[^\r\n]*><newline:\n?>/ => "  " 
		// whitelist irrelevant chars --> big performance boost
		case /^<s:[^\/"']+>/ => s 
	}
	result = trim(result);
	if(size(result) == 0) return <"", openComment, false>;
	return <trim(result), openComment, !openComment>;
}

Trie createLinesTrie(rel[list[str], loc] lines){
	t0 = getMilliTime();
	trie = createSuffixTrie(lines, minSuffixLength=0);
	t1 = getMilliTime();
	//println(" Building trie took <t1 - t0> ms");
	return trie;
}

/** prune out all nodes without duplicates */
Trie pruneTrie(Trie trie){

	// 1 bottom-up visit with all 3 cases would have the same effect, but is slower.
	trie = top-down visit(trie){
		case \leaf(_, _, _) => \emptyleaf()
		case \node(_, {v}, _) => \emptyleaf()
	}
	trie = bottom-up visit(trie){
		case \node(cs, vs, d) => \node((k: cs[k] | k <- cs, !(\emptyleaf() := cs[k])), vs, d)
	}
	return trie;
}


Trie fixLineNumbers(Trie trie){
	return bottom-up visit(trie){
		case \node(cs, vs, d) => \node(cs, {<l, n + d>| <loc l, int n> <- vs} , d)
	}
}

map[set[value], int] getAllDuplications(Trie trie){
	if(\node(cs, vs, d) := trie){
		map[set[value], int] childCounts = ();
		for(k <- cs){
			childCounts = childCounts + getAllDuplications(cs[k]); 	
		}
		if(size(cs) == 0){
			childCounts = childCounts + (vs: d | v <- vs, d >= 6);
		}			
		return childCounts;
	}
	else{
		throw IllegalArgument("Non-\\node type trie nodes must be pruned before applying getAllDuplications.");
	}
}

map[value, int] getUniqueDuplications(Trie trie){
	dupes = getAllDuplications(trie);
	flatDupes = (l: dupes[ls] | ls <- dupes, l <- ls);
	for(l <- sort({s | s <- flatDupes})){ println(l);}
	blacklist = {};
	for(<loc file, int offset> <- flatDupes){
		count = flatDupes[<file, offset>];
		blacklist = blacklist + {<file, offset - i> | int i <- [1..count]};
	}
	return (k: flatDupes[k] | k <- flatDupes, k notin blacklist);
}




/* Finds all duplications of size >= 6, and returns a set of the lines 
 * where these locations were found.
 */
public lrel[rel[loc, int], int] getDuplicationsForAsts(set[Declaration] asts){
	rel[list[Line], loc] lines = cleanLines(asts);
	map[loc, list[loc]] lineLocs = ();
	for(<list[Line] ls, loc file> <- lines){
		int i = 0;
		list[loc] locs = [];
		for(Line line <- ls, clean(str _) := line){
			locs += line.src;
		} 
		lineLocs[file] = locs;
	}
	
	Trie trie = createLinesTrie({<[line | clean(line) <- ls], src> | <list[Line] ls, loc src> <- lines});
	Trie duplicateTrie = pruneTrie(trie);
	duplicateTrie = fixLineNumbers(duplicateTrie);
	set[rel[loc, int]] duplicateLines = {};
	visit(duplicateTrie){
		case \node(cs, vs, d): {
			rel[loc, int] newSet = {};
			for(<loc f, int l> <- vs, d >= 6){
				loc from = lineLocs[f][l - d];
				loc to = lineLocs[f][l - 1];
				loc src = |undefined:///|(0,0);
				src.uri = from.uri;
				src.offset = from.offset;
				src.length = to.offset + to.length - from.offset;
				newSet += {<src, d>}; 
			}
			duplicateLines += {newSet};
		}
	}
	dups = sort([<-takeOneFrom(dups)[0][1], dups> | dups <- duplicateLines, size(dups) > 0]);
	return [<dup,-w> | <w, dup> <- dups];
}


public lrel[rel[loc, int], int]  getDuplicationsForProject(loc project){
	set[Declaration] asts = createAstsFromEclipseProject(project, true);
	return getDuplicationsForAsts(asts);
}

public tuple[int, int] countDuplicationsForProject(loc project){
	set[Declaration] asts = createAstsFromEclipseProject(project, true);
	return countDuplicationsForAsts(asts);
}

/** returns the ratio of number of duplications to the total lines considered as a tuple */
public tuple[int, int] countDuplicationsForAsts(set[Declaration] asts){
	rel[loc, int] dups = getDuplicationsForAsts(asts);
	int totalLines = (0 | it + size([l | clean(l) <- lines]) | <list[Line] lines, _> <- cleanLines(asts));
	int duplicateCount = size(dups);
	return <duplicateCount, totalLines>;
}

public str getDuplicationScore(real duplicatepct){
	scores = [s | <int n, str s> <- [
		<5, "++">,
		<10, "+">,
		<15, "o">,
		<25, "-">,
		<-1, "--">
	], n >= duplicatepct || n < 0];
	return scores[0];
} 
