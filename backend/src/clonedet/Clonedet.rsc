module clonedet::Clonedet

import clonedet::Canonize;
import lang::java::jdt::m3::AST;
import Node;
import List;
import Set;
import IO;
import Exception;
import util::Math;

data Duplicate = duplicate(int \type, int weight, set[loc] locs);

map[tuple[int, loc], map[value, set[loc]]] CACHE = ();


map[value, set[loc]] type1LocationMapForProject(loc project){
	tuple[int, loc] cacheKey = <1, project>;
	if(cacheKey in CACHE) return CACHE[cacheKey];
	set[value] asts = createAstsFromEclipseProject(project, true);
	CACHE += (cacheKey: locationMap(asts));
	return CACHE[cacheKey];
}

bool contains(set[loc] outers, loc inner){
	return any(outer <- outers, (outer.uri == inner.uri 
					   		&& outer.offset <= inner.offset 
					   		&& outer.length + outer.offset >= inner.length + inner.offset)
			  );
}


list[Duplicate] uniqClones(list[Duplicate] clones){
	map[str, set[set[loc]]] contained = ();
	list[Duplicate] uniqclns = [];
	for(duplicate(\type, weight, locs) <- clones){
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
		uniqclns += duplicate(\type, weight, locs);
	}
	return uniqclns;
}


list[Duplicate] type2OrderedClones(loc project){
	m = type2LocationMapForProject(project);
	locs = sort({<-treesize(k), m[k]> | k <- m, size(m[k]) > 1});
	return [duplicate(2, -x, y) | <x, y> <- locs, -x > 1];
}


map[value, set[loc]] type2LocationMapForProject(loc project){
	tuple[int, loc] cacheKey = <2, project>;
	if(cacheKey in CACHE) return CACHE[cacheKey];
	set[value] asts = createAstsFromEclipseProject(project, true);
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

