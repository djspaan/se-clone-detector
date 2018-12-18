module clonedet::tests::util::GenerateCompilationUnit

import util::Math;
import List;
import String;
import IO;
import lang::java::jdt::m3::AST;

str arbIdentifier(){
	list[str] alpha = split("", "abcdefghijklmnopqrstuvwxyz");
	return (""| it + getOneFrom(alpha) | _ <- [0..10]);
}

str arbPackage(){
	return intercalate(".", ["pkg_<arbIdentifier()>" | i <- [0..1 + arbInt(3)]]);
}

str arbImports(){
	return (""| it + "import <arbPackage()>.<getOneFrom(["Cls_<arbIdentifier()>", "*"])>;\n" | i <- [0..arbInt(5)]);
}

str arbType(){
	list[str] types = ["int", "double", "String", "Cls_<arbIdentifier()>"];
	return getOneFrom(types);
}

str arbExpr() = arbExpr(3);

str arbExpr(0) = "1.1f";

str arbExpr(int n){
	return getOneFrom([
		"new Cls_<arbIdentifier()>(<arbType()> <arbIdentifier()>)",
		"new arbType()[]{<intercalate(",", ["\"<arbInt()>\"" | i <- [0..5]])>}",
		"<arbExpr(n - 1)> + <arbExpr(n - 1)>",
		"<arbExpr(n - 1)> - <arbExpr(n - 1)>", 
		"1.1f",
		"\"A string <arbIdentifier()>\"",
		"\'c\'",
		"5"]);
} 

str arbStatement() = getOneFrom([
	"qualified.name.method.body = <arbExpr()>;",
	"<arbType()> <arbIdentifier()> = <arbExpr()>;",
	"<arbIdentifier()> += <arbExpr()>;",
	"for(<arbIdentifier()> = <arbExpr()>; <arbIdentifier()> \< <arbExpr()>; <arbIdentifier()>++){\n<arbInt(4) == 0 ? arbBody() : "">\n}"
]);

str arbBody() = intercalate("\n", [arbStatement() | i <- [0..arbInt(5) + 1]]);

str arbMethod(){
	return "public <arbType()> mthd_<arbIdentifier()>(){\n<arbBody()>\n}";
}

str arbMethods(){
	return intercalate("\n\n", [arbMethod() | i <- [0..arbInt(5)]]);;
}

tuple[str, str] arbClass(){
	str name = "Cls_<arbIdentifier()>";
	return <name, 
"public class <name>{
<name>(){
<arbBody()>
}
	
<arbMethods()>
}">;
}


tuple[str, str] arbCompilationUnit(){
	str name = arbPackage();
	<clsName, clsSrc> = arbClass();
	return <"<name>.<clsName>", 
"package <name>;

<arbImports()>

<clsSrc>
">;
}

Declaration arbAst(){
	<name, src> = arbCompilationUnit();
	
	path = |undefined:///|;
	path.uri = "testsrc://<intercalate("/", split(".", name))>.java";
	return createAstFromString(path, src, true);
}




