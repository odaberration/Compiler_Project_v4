/*	Nicholas Wingfield 
	CMSC 430 Compiler Theory and Design
   Project 1 
   UMGC CITE
   8/25/2025 */

// This file contains the bodies of the functions that produces the 
// compilation listing. LAst line generates count for all types of errors
// appendError now creates error messages for each type to push tp a stack
// displayError now pops messages from stack after display

#include <cstdio>
#include <string>
#include <queue>

using namespace std;

#include "listing.h"

static int lineNumber;
static string error = "";
static int totalErrors = 0;

static int lexicalErrors = 0;
static int generalSemanticErrors = 0;
static int duplicateErrors = 0;
static int undeclaredErrors = 0;
static int syntacticErrors = 0;
static queue<string> errorList;


static void displayErrors();


void firstLine()
{
	lineNumber = 1;
	printf("\n%4d  ",lineNumber);
}


void nextLine()
{
	displayErrors();
	lineNumber++;
	printf("%4d  ",lineNumber);
}


int lastLine()
{
	/*original code
	printf("\r");
	displayErrors();
	printf("     \n");
	return totalErrors;
	*/

	int allSemanticErrors = generalSemanticErrors + duplicateErrors + undeclaredErrors;
	totalErrors = lexicalErrors + allSemanticErrors + syntacticErrors;
	
	printf("\n");
	displayErrors();

	//sum of and display of all error quantity
	if(totalErrors == 0){
		printf("Compiled Successfully\n");
	} else {
		printf("Lexical Errors %d\n", lexicalErrors);
		printf("Semantic Errors %d\n", allSemanticErrors);
		printf("Syntactic Errors %d\n", syntacticErrors);
	}
	return totalErrors;
}
    

void appendError(ErrorCategories errorCategory, string message)
{
	/*original code
	string messages[] = { "Lexical Error, Invalid Character ", "",
		"Semantic Error, ", "Semantic Error, Duplicate ",
		"Semantic Error, Undeclared " };

	error = messages[errorCategory] + message;
	totalErrors++;
	*/

	string messages[] = { "Lexical Error, Invalid Character ", "Syntax Error, ",
		"Semantic Error, ", "Semantic Error, Duplicate ",
		"Semantic Error, Undeclared " };

	error = messages[errorCategory] + message;
	//enqueue the determined message in global queue
	errorList.push(error);

	//determine error type, increment it for count
	switch (errorCategory) {
		case LEXICAL:
			lexicalErrors++;
			break;
		case SYNTAX:
			syntacticErrors++;
			break;
		case GENERAL_SEMANTIC:
			generalSemanticErrors++;
			break;
		case DUPLICATE_IDENTIFIER:
			duplicateErrors++;
			break;
		case UNDECLARED:
			undeclaredErrors++;
			break;
		default:
			break;
	}
}


void displayErrors()
{
	/*original code
	if (error != "")
		printf("%s\n", error.c_str());
	error = "";
	*/

	//print messgae from queue then discard
	while(!errorList.empty()){
		printf("%s\n", errorList.front().c_str());
		errorList.pop();
	}
}
