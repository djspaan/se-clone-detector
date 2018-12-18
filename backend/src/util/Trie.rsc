module util::Trie

import List;


data Trie 
	= \node(map[str, Trie] children, set[value] vs, int depth)
	| \leaf(list[str] path, value v, int depth)
	| \emptyleaf() // emptyleaf exists as a workaround for rascal not supporting pattern matching on empty maps
	;


Trie newTrie(int depth = 0) = \node((), {}, depth);


Trie insertTrie(\leaf([], value v, int depth), list[str] path, value newv){
	return insertTrie(\node((), {v}, depth), path, newv);
}

Trie insertTrie(\leaf([str t, *ts], value v, int depth), list[str] path, value newv){
	newleaf = \leaf(ts, v, depth + 1);
	return insertTrie(\node((t: newleaf), {v}, depth), path, newv);
}

Trie insertTrie(\node(cs, vs, depth), list[str] toks, value v){
	switch(toks) {
		case [token, *ts]: {
				Trie child;
	       		if(token notin cs) {
	        		child = leaf(ts, v, depth + 1);
	    		}
	    		else {
	        		child = insertTrie(cs[token], ts, v);;
	    		}
	    		return \node(cs + (token: child), vs + {v}, depth);
    		}
    	case []:
    		return \node(cs, vs + {v}, depth);
	}
}

list[list[str]] suffixes(list[str] toks){
	int n = size(toks);
	return [slice(toks, i, n - i) | i <- [0..n]];
}

Trie insertSuffixes(Trie trie, list[str] toks, value v, int minLength = 0){
	int i = 0;
	for(list[str] suffix <- suffixes(toks)){
		if(size(suffix) < minLength) continue;
		trie = insertTrie(trie, suffix, <v, i>);
		i = i + 1;
	}
	return trie;
}

Trie createSuffixTrie(rel[list[str], value] elems, int minSuffixLength = 0){
	Trie trie = newTrie();
	for(<toks, v> <- elems){
		trie = insertSuffixes(trie, toks, v, minLength=minSuffixLength);
	}
	return trie;
}
