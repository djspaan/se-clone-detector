module clonedet::tests::TestCanonize

import clonedet::tests::util::GenerateCompilationUnit;
import clonedet::Canonize;
import Node;
import IO;


tuple[Declaration, Declaration] arbType2Variation(){
	<name, src> = arbCompilationUnit();
	
	srcvar = visit(src){
		// change identifiers
		case /^\b<id:Cls_[a-z]+>\b/ => "var<id>" 
		case /^\b<id:mthd_[a-z]+>\b/ => "var<id>" 
		case /^\b<id:pkg_[a-z]+>\b/ => "var<id>"
		
		// modify literals
		//case /^\b\{<body:[a-zA-Z",0-9]+>\}\b/ => "{<reverse(body)>}"
		case /^\b<n:\d+>\b/ => "<toInt(n) + 1>"
		
		case /^\b<n:\d+>.<d:\d+>d\b/ => "<d>.<n>d"
		case /^\b<n:\d+>.<d:\d+>f\b/ => "<d>"
		
		// change operators
		case /^ - / => " + "
		case /^ \+ / => " - "
		case /^\+\+/ => "--" 
		 		
		// modify builtin types 
		case /^\bint\b/ => "double"
	}
	namevar = split(".", name);
	namevar[size(namevar) - 1] = "var<namevar[size(namevar) - 1]>";
	
	
	path = |undefined:///|;
	path.uri = "testsrc://<intercalate("/", split(".", name))>.java";
	
	pathvar = |undefined:///|;
	pathvar.uri = "testsrc://<intercalate("/", namevar)>.java";
	return <createAstFromString(path, src, true), createAstFromString(pathvar, srcvar, true)>;
}



test bool testCanonize(){
	for(_ <- [0..10]){
		<varA, varB> = arbType2Variation();
		canonicalA = canonize(varA);
		canonicalB = canonize(varB);
		return unsetRec(canonicalA) == unsetRec(canonicalB);
	}
}