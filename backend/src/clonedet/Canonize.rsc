module clonedet::Canonize

import lang::java::m3::AST;


@doc{
Resolve some ambiguity in lang::java::m3::AST :

	declarationStatement(decl)
	expressionStatement(declarationExpression(decl))

This function normalizes replaces the first variant with the latter.

}
Declaration normalizeDeclarations(Declaration d){
	return visit(d){
		case declarationStatement(decl)
			=> expressionStatement(declarationExpression(decl))
	}
}


Declaration anonymize(Declaration d){
	return bottom-up visit(d){
		case str s => ""
		case \arrayInitializer(_) => \arrayInitializer([])
		
		// all built in types -> int
		// (void stays void: no return value)
    	case \int() => \int()
    	case short() => \int()
    	case long() => \int()
    	case float() => \int()
    	case double() => \int()
    	case char() => \int()
    	case string() => \int()
    	case byte() => \int()
    	case \boolean() => \int()
    	
    	
	}
}


Declaration canonize(Declaration d){
	d = normalizeDeclarations(d);
	d = anonymize(d);
	return d;
}


