module clonedet::Trie

import List;

data Trie[&K, &T]
	= trieNode(map[&K, Trie[&K, &T]] children, set[&T] items)
	| trieLeaf(list[&K] remainderPath, set[&T] items);


public Trie[void, void] newTrie() = trieNode((), {});

public Trie[&K, &T] insertTrie(Trie[&K, &T] trie, list[&K] path, &T item) = insertTrie(trie, path, {item}); 

public Trie[&K, &T] insertTrie(trieLeaf(list[&K] path, set[&T] items), path, set[&T] newItems) 
	= trieLeaf(path, items + newItems);
	
	
public Trie[&K, &T] insertTrie(trieLeaf(list[&K] remainderPath, set[&T] items), list[&K] path, set[&T] newItems){
	Trie[&K, &T] trie = trieNode((), items + newItems);
	trie = insertTrie(trie, remainderPath, items);
	trie = insertTrie(trie, path, newItems);
	return trie;
}

public Trie[&K, &T] insertTrie(trieNode(map[&K, Trie[&K, &T]] children, set[&T] items), [], set[&T] newItems) 
	= trieNode(children, items + newItems);
	
public Trie[&K, &T] insertTrie(trieNode(map[&K, Trie[&K, &T]] children, set[&T] items), list[&K] path, set[&T] newItems){
	if([tok,*toks] := path){ 
		map[&K, Trie[&K, &T]] newChildren;
		if(tok in children){
			Trie[&K, &T] newChild = insertTrie(children[tok], toks, newItems);
			newChildren = children + (tok: newChild);
		}
		else {
			Trie[&K, &T] newChild = trieLeaf(toks, newItems);
			newChildren = children + (tok: newChild);
		}
		return trieNode(newChildren, items + newItems);	
	}
	else{
		throw IllegalArgument(path);
	}
}

private list[rel[list[&K], set[&T]]] suffixes(list[&K] path, rel[list[&K], set[&T]] (&TIn, int) suffixFn){
	return [suffixFn(path, i) | i <- [0..size(path)]]; 
}

public Trie[&K, &T] insertSuffixes(Trie[&K, &T] trie, &TIn path, rel[list[&K], set[&T]] (&TIn, int) suffixFn ){
	for(suffixSet <- suffixes(path, suffixFn), <list[&K] suffix, set[&T] newItems> <- suffixSet){
		trie = insertTrie(trie, suffix, newItems);
	}
	return trie;
}

