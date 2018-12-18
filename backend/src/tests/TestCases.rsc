module tests::TestCases

import IO;
import lang::java::jdt::m3::AST; 
import tests::CloneAssertion;



rel[loc, set[CloneAssertion]] getTestProjectTestCases(){
	asts = createAstsFromEclipseProject(|project://testproject/|, true);
	loc simpleClonesFile = [ast.src | ast <- asts, /SmallClass/ := ast.src.uri][0]; 
	loc type2ClonesFile = [ast.src | ast <- asts, /Type2Class/ := ast.src.uri][0]; 
	loc type2PartialBlockFile = [ast.src | ast <- asts, /Type2PartialBlock/ := ast.src.uri][0]; 
	loc emptyClassFile = [ast.src | ast <- asts, /EmptyClass/ := ast.src.uri][0]; 
	
 	return {<|project://testproject|, { 
 		// simpleClonesFile contains the same fragment 3 times, 
 		// and a superset of that fragment 2 times.
		atLeastInRange(1, simpleClonesFile, 2, 10),
		atLeastInRange(1, simpleClonesFile, 3, 8),
		
		
 		//type2ClonesFile contains no type 1 clones.
		atMostInRange(1, type2ClonesFile, 0),
		
 		// type2ClonesFile contains 4 different type 2 variations of the same function.
 		// simpleClonesFile contains this twice as well.
		atLeastInRange(2, type2ClonesFile, 4, 9),
		atLeastInRange(2, simpleClonesFile, 2, 9),
		
		// test comments. Neither type 1 or type 2 clones should be detected.
		atMostInRange(1, emptyClassFile, 0),
		atMostInRange(2, emptyClassFile, 0),
		
 		// type2PartialBlock contains 2 blocks of statements that aren't quite equivalent, 
 		// but both contain a block with a sublist of statements that are syntactically equivalent. 
		atLeastInRange(2, type2PartialBlockFile, 2, 8)
	}>};
}