// Nicholas Wingfield
// Compiler Theory and Design
// 10/7/2025
// 

// This file contains type definitions and the function
// prototypes for the type checking functions
// Updated to include new prototypes and check enums

typedef char* CharPtr;

enum Types {MISMATCH, INT_TYPE, CHAR_TYPE, REAL_TYPE, NONE};

void checkAssignment(Types lValue, Types rValue, string message);
Types checkWhen(Types true_, Types false_);
Types checkSwitch(Types case_, Types when, Types other);
Types checkCases(Types left, Types right);
Types checkArithmetic(Types left, Types right);
Types checkNot(Types t);                            //not checker
Types checkLogical(Types left, Types right);        //logical type checker
Types checkRelational(Types left, Types right);     //relational checker
Types checkLists(Types previous, Types next);       //list type checker
void checkListDeclared(Types listType, Types elementType); //list to elements check
Types checkSubscript(Types indexType, Types elementType);  //check subscript as int
Types checkRemainder(Types left, Types right);      //remainder type checker
Types checkIfOptions(Types option, Types alternative); //if-elsif-else checker for matched statements
void checkFoldList(Types foldList);                 //folded list checker
void checkNarrowing(Types left, Types right);       //checks type narrowing
