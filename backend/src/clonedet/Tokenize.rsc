module clonedet::Tokenize

import lang::java::jdt::m3::AST;

data Token 
	= methodHeader(Type \type, str name, list[Declaration] params, list[Expression] exprs, loc src)
	| statement(value statement, loc src)
	| blockStart()
	| blockEnd()
	| foobar();

list[Token] tokenize(value ast, list[Token](value) toTokens) {
	list[Token] tokens = [];
	top-down visit(ast){
		case \block(list[Statement] sts) => {
			tokens += blockStart();
			tokens += tokenize(sts, toTokens);
			tokens += blockEnd();			
			empty();
		} 
		case Statement s: tokens += toTokens(s);
		case Declaration s: tokens += toTokens(s);
		case Type t: tokens += toTokens(t);
	}
	return tokens;
}



list[Token] type1Tokens(\class(str \name, list[Type] extends, list[Type] implements, list[Declaration] body)) = [];
list[Token] type1Tokens(Declaration d) = [foobar()];
list[Token] type1Tokens(Statement s) = [foobar()];
list[Token] type1Tokens(Type t) = [foobar()];
list[Token] type1Tokens(value s) = [];



