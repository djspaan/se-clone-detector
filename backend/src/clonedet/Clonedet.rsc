module clonedet::Clonedet

import clonedet::Canonize;
import lang::java::jdt::m3::AST;
import Node;
import List;
import Set;
import IO;
import Exception;
import util::Math;

data Clone = clone(int \type, int weight, set[loc] locs);

map[tuple[int, loc], map[value, set[loc]]] CACHE = ();

list[Clone] type1OrderedClones(loc project, set[Declaration] asts = {}) = [];

list[Clone] type2OrderedClones(loc project, set[Declaration] asts = {}){
	m = type2LocationMapForProject(project, asts = asts);
	locs = sort({<-treesize(k), m[k]> | k <- m, size(m[k]) > 1});
	return [clone(2, -x, y) | <x, y> <- locs, -x > 1];
}


map[value, set[loc]] type2LocationMapForProject(loc project, set[Declaration] asts = {}){
	tuple[int, loc] cacheKey = <2, project>;
	
	if(cacheKey in CACHE) 
		return CACHE[cacheKey];
	
	if(asts == {})
		asts = createAstsFromEclipseProject(project, true);
	
	canonized = {canonize(ast) | ast <- asts};
	CACHE += (cacheKey: astLocationMap(canonized));
	return CACHE[cacheKey];
}


// why is this not in the prelude?
&T getdefault(map[&K, &T] m, &K k, &T def) = k in m ? m[k] : def; 


map[value, set[loc]] astLocationMap(asts){
	map[value, set[loc]] lmap = ();
	top-down visit(asts){
		case Statement d:{
			clean = unsetRec(d);
			lmap += (clean: getdefault(lmap, clean, {}) + {d.src});
		}
		case Declaration d:{
			clean = unsetRec(d);
			lmap += (clean: getdefault(lmap, clean, {}) + {d.src});
		}
	}
	return lmap;
}


int treesize(value v){
	int size = 0;
	top-down visit(v){
		case declarationExpression(_) => null() 
		case declarationStatement(_): ; // don't count this twice
		case block(_): ;
		case parameter(_, _, _): ;
		case vararg(_, _): ;
		case Statement d: size += 1;
		case Declaration d: size += 1;
	}
	return size;
}

/**
 * A set of locations `contains` a location if the set contains a location with an equal URI and 
 * its offset and length entirely contain the given location's offset and length. 
 */ 
bool contains(set[loc] outers, loc inner){
	return any(outer <- outers, (outer.uri == inner.uri 
					   		&& outer.offset <= inner.offset 
					   		&& outer.length + outer.offset >= inner.length + inner.offset)
			  );
}

/**
 * Removes any clones that are contained in previous clones in the list.
 * If the list is partially ordered such that clones occurring later in the list cannot be contained by clones earlier in the list,
 * this will result in a list of unique clones.
 */
list[Clone] uniqClones(list[Clone] clones){
	map[str, set[set[loc]]] contained = ();
	list[Clone] uniqclns = [];
	for(clone(\type, weight, locs) <- clones){
		if(all(l <- locs, l.uri in contained)){
			loc someLoc = getOneFrom(locs);
			set[set[loc]] locsets = contained[someLoc.uri];
			
			if(any(locset <- locsets, all(l <- locs, contains(locset, l)))) 
				continue;
		}
		for(loc l <- locs){
			if(l.uri in contained) contained[l.uri] += {locs};
			else contained += (l.uri: {locs});
		}
		uniqclns += clone(\type, weight, locs);
	}
	return uniqclns;
}

