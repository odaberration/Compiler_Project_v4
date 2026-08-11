// Nicholas Wingfield
// Compiler Theory and Design
// 10/7/2025
//

// This file contains the bodies of the type checking functions. Includes updated assignment check for narrowing, 
// arithmetic for variances in numeric type, relational for char-char or num-num types, not and logical checks for boolean integers (0, 1),
// list (type declaration, index, and element) type checking, remainder is an int check, subscript as an integer, if-elsif-else type match check,
// and fold chekc that values are matched numeric types

#include <string>
#include <vector>

using namespace std;

#include "types.h"
#include "listing.h"

void checkAssignment(Types lValue, Types rValue, string message) {
	if (lValue == INT_TYPE && rValue == REAL_TYPE){
		appendError(GENERAL_SEMANTIC, "Illegal Narrowing " + message);	//narrowing from int to real illegal
		return;}
	if (lValue == REAL_TYPE && rValue == INT_TYPE){						//widening acceptable
		return;}
	if (lValue != MISMATCH && rValue != MISMATCH && lValue != rValue)
		appendError(GENERAL_SEMANTIC, "Type Mismatch on " + message);
}

Types checkWhen(Types true_, Types false_) {
	if (true_ == MISMATCH || false_ == MISMATCH)
		return MISMATCH;
	if (true_ != false_)
		appendError(GENERAL_SEMANTIC, "When Types Mismatch ");
	return true_;
}

Types checkSwitch(Types case_, Types when, Types other) {
	if (case_ != INT_TYPE)
		appendError(GENERAL_SEMANTIC, "Switch Expression Not Integer");
	return checkCases(when, other);
}

Types checkCases(Types left, Types right) {
	if (left == MISMATCH || right == MISMATCH)
		return MISMATCH;
	if (left == NONE || left == right)
		return right;
	appendError(GENERAL_SEMANTIC, "Case Types Mismatch");
	return MISMATCH;
}

Types checkArithmetic(Types left, Types right) {
	if (left == MISMATCH || right == MISMATCH){
		return MISMATCH;}
	
	if ( (left != INT_TYPE && left != REAL_TYPE) || (right != INT_TYPE && right != REAL_TYPE)){
		appendError(GENERAL_SEMANTIC, "Numeric Type Required");		//one side is not numeric
		return MISMATCH;}

	if (left == REAL_TYPE || right == REAL_TYPE){
		return REAL_TYPE;}								//explicitly, if left is numeric and right is not the same type

	return INT_TYPE;   									// otherwise both sides are int
}

Types checkNot(Types t){								//checks if type is an int, for a boolean representation
	if (t == MISMATCH){
		return MISMATCH;}
	if (!(t == INT_TYPE)){
		appendError(GENERAL_SEMANTIC, "Logical Not Requires Integer");
		return MISMATCH;}
	return INT_TYPE;
}

Types checkLogical(Types left, Types right){			//like above
	if (left == MISMATCH || right == MISMATCH)
		return MISMATCH;
	if(!(left == INT_TYPE) || !(right == INT_TYPE))
		appendError(GENERAL_SEMANTIC, "Logical Comparison Requires Integer");
		return MISMATCH;
	return INT_TYPE;
}

Types checkRelational(Types left, Types right){
	if (left == MISMATCH || right == MISMATCH){			//for immediate mismatched type failure
		return MISMATCH;}

	if ((left != CHAR_TYPE && right == CHAR_TYPE) || 
		(left == CHAR_TYPE && right != CHAR_TYPE)){
		appendError(GENERAL_SEMANTIC, "Can't Compare Characters to Numeric Expression");
		return MISMATCH;}

	if (left == CHAR_TYPE && right == CHAR_TYPE){		//char matches
		return INT_TYPE;}

	if ((left == INT_TYPE || left == REAL_TYPE) &&		//Account for numeric matches
		(right == INT_TYPE || right == REAL_TYPE)){
		return INT_TYPE;}

	appendError(GENERAL_SEMANTIC, "Other type mismatch for relational comparison");
	return MISMATCH;
}

Types checkLists(Types previous, Types next) {
	if (previous == MISMATCH || next == MISMATCH){
		return MISMATCH;}
	if (previous == next){								//Compares previous type of the list so far to the next 
		return previous;}
	appendError(GENERAL_SEMANTIC, "List Types Mismatch");
	return MISMATCH;
}

void checkListDeclared(Types listType, Types elementType){
	if (listType == MISMATCH || elementType == MISMATCH){
		return;}
	if (listType != elementType){						//only creates an error when the list declared type mismatches list contents
		appendError(GENERAL_SEMANTIC, "List Type Mismatches List Elements");}
}

Types checkSubscript(Types indexType, Types elementType){
		if (indexType == MISMATCH){
			return MISMATCH;}
		if (indexType != INT_TYPE){						//only matters if is int
			appendError(GENERAL_SEMANTIC, "List Subscript Must Be Integer");}
		return elementType;								//returns element type since subscript is valid int
}

Types checkRemainder(Types left, Types right){			//remainder must be int
	if (left == MISMATCH || right == MISMATCH){
		return MISMATCH;}
	if(left == INT_TYPE && right == INT_TYPE){
		return INT_TYPE;}
	appendError(GENERAL_SEMANTIC, "Remainder Requires Integer");
	return MISMATCH;
}

Types checkIfOptions(Types option, Types alternative) {
	if (option == MISMATCH || alternative == MISMATCH){
		return MISMATCH;}
	if (option == NONE){								//necessary to process endif
		return alternative;}
	if (alternative == NONE){
		return option;}
	if (option != alternative){							//similar to check subscript except compared types are between the If-elsif-else statement
		appendError(GENERAL_SEMANTIC, "If-Elsif-Else Type Mismatch");
		return MISMATCH;}
	return option;
}

void checkFoldList(Types foldList){
	if (foldList == INT_TYPE || foldList == REAL_TYPE){		//if numeric, return unbothered, or if mismatch return, or its a type error
		return;}
	if(foldList == MISMATCH){
		return;}
	appendError(GENERAL_SEMANTIC, "Folded List Must Be Numeric Type");
}
