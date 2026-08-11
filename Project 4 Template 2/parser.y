/* Nicholas Wingfield
 CMSC 430 6383 Compiler Theory and Design
 10/7/2025
 Project 4
 */
/* Updated productions to contain and pass typed data. Implemented scalar and list search/insert functions. Implemented type checkers into respective productions.*/

%{

#include <iostream>
#include <cmath>
#include <string>
#include <vector>
#include <map>

using namespace std;

#include "types.h"
#include "listing.h"
#include "symbols.h"

int yylex();
Types find(Symbols<Types>& table, CharPtr identifier, string tableName);
void yyerror(const char* message);

Symbols<Types> scalars;
Symbols<Types> lists;

void findScalarsInsert(char* id, Types t){
	if (scalars.find(id, t)){
		appendError(GENERAL_SEMANTIC, std::string("Duplicate Scalar") + id);}
	else{
		scalars.insert(id, t);}
}

void findListsInsert(char* id, Types t){
	if (lists.find(id, t)){
		appendError(GENERAL_SEMANTIC, std::string("Duplicate List") + id);}
	else{
		lists.insert(id, t);}
}

%}

%start function

%define parse.error verbose

%union {
	char* iden;
	Types type;
}

%token <iden> IDENTIFIER 

%token <type> INT_LITERAL CHAR_LITERAL REAL_LITERAL

%token ADDOP MULOP ANDOP RELOP ARROW OROP NOTOP NEGOP EXPOP REMOP
%token BEGIN_ CASE CHARACTER ELSE END ENDSWITCH FUNCTION INTEGER IS LIST OF 
%token OTHERS RETURNS SWITCH WHEN ELSIF IF ENDIF FOLD ENDFOLD LEFT RIGHT THEN REAL

%type <type> type list list_choice expressions expression body statement_ statement cases inner_statement_check optional_elsif
%type <type> case term unary power primary not_unary relation condition or_condition and_condition function_header

%%

function:	
	function_header optional_variable body {checkAssignment($1, $3, "Function Return");} ;

function_header:	
	FUNCTION IDENTIFIER optional_parameters RETURNS type ';' {$$ = $5;} |
	FUNCTION error ';' {$$ = MISMATCH; yyerrok;} ;

optional_parameters:
	parameters |
	%empty ;

parameters:
	parameters ',' parameter |
	parameter ;

parameter:
	IDENTIFIER ':' type ;

type:
	INTEGER {$$ = INT_TYPE;} |
	REAL {$$ = REAL_TYPE;} |
	CHARACTER {$$ = CHAR_TYPE;} ;
	
optional_variable:
	optional_variable variable |
	variable |
	%empty ;
    
variable:	
	IDENTIFIER ':' type IS statement ';' {checkAssignment($3, $5, "Variable Initialization"); findScalarsInsert($1, $3);}|
	IDENTIFIER ':' LIST OF type IS list ';' {checkListDeclared($5, $7); findListsInsert($1, $5);} |
	error_recovery ;

list:
	'(' expressions ')' {$$ = $2;} ;

expressions:
	expression {$$ = $1;} |
	expressions ',' expression {$$ = checkLists($1, $3);} ;

body:
	BEGIN_ statement_ END ';' {$$ = $2;} ;

statement_:
	%empty {$$ = NONE;} |
	statement_ statement ';' {$$ = $2;} |
	statement_ error_recovery  {$$ = MISMATCH;} ;

error_recovery:
	error ';' { yyerrok; } ;

inner_statement_check:
	statement ';' {$$ = $1;} |
	error_recovery {$$ = MISMATCH;} ;

statement:
	IF condition THEN inner_statement_check optional_elsif 
		ELSE inner_statement_check ENDIF 
		{Types elsifOption = ($5 == NONE) ? $4 : checkCases($4, $5);
		 $$ = checkIfOptions(elsifOption, $7);} |
	WHEN condition ',' expression ':' expression {$$ = checkWhen($4, $6);} |
	SWITCH expression IS cases OTHERS ARROW statement ';' ENDSWITCH {$$ = checkSwitch($2, $4, $7);} |
	FOLD direction operator list_choice ENDFOLD {checkFoldList($4); $$ = NONE;} |
	expression {$$ = $1;} ;

optional_elsif:
	optional_elsif ELSIF condition THEN inner_statement_check {$$ = ($1 == NONE) ? $5 : checkCases($1, $5); } |
	ELSIF condition THEN inner_statement_check {$$ = $4;} |
	%empty {$$ = NONE;} ;

cases:
	%empty {$$ = NONE;} |
	cases case {$$ = checkCases($1, $2);} ;
	
case:
	CASE INT_LITERAL ARROW statement ';' {$$ = $4;} |
	CASE INT_LITERAL ARROW error_recovery {$$ = MISMATCH;} |
	CASE error ARROW statement ';' { $$ = $4; yyerrok;} |
	CASE error ARROW error_recovery { $$ = MISMATCH; yyerrok;} ;

direction:
	LEFT | RIGHT ;

operator:
	ADDOP | MULOP | REMOP | EXPOP ;

list_choice: 
	list {$$ = $1;}|
	IDENTIFIER {$$ = find(lists, $1, "List"); free($1);} ;

condition:
	or_condition {$$ = $1;} ;

or_condition:
	or_condition OROP and_condition {$$ = checkLogical($1, $3);} |
	and_condition {$$ = $1;} ;

and_condition:
	and_condition ANDOP not_unary {$$ = checkLogical($1, $3);} |
	not_unary {$$ = $1;} ;

not_unary:
	NOTOP not_unary {$$ = checkNot($2);} |
	relation {$$ = $1;} ;

relation:
	'(' condition ')' {$$ = $2;} |
	expression RELOP expression {$$ = checkRelational($1, $3);} ;

expression:
	expression ADDOP term {$$ = checkArithmetic($1, $3);} |
	term {$$ = $1;} ;

term:
	term MULOP power {$$ = checkArithmetic($1, $3);} |
	term REMOP power {$$ = checkRemainder($1, $3);} |
	power {$$ = $1;} ;

power:
	unary EXPOP power {$$ = checkArithmetic($1, $3);} |
	unary {$$ = $1;} ;

unary:
	NEGOP unary {$$ = checkArithmetic(INT_TYPE, $2);} |
	primary {$$ = $1;} ;

primary:
	'(' expression ')' {$$ = $2;} |
	INT_LITERAL {$$ = INT_TYPE;} |
	CHAR_LITERAL {$$ = CHAR_TYPE;} |
	REAL_LITERAL {$$ = REAL_TYPE;} |
	IDENTIFIER '(' expression ')' {Types a = find(lists, $1, "List"); 
									$$ = checkSubscript($3, a);} |
	IDENTIFIER {$$ = find(scalars, $1, "Scalar");} ;

%%

Types find(Symbols<Types>& table, CharPtr identifier, string tableName) {
	Types type;
	if (!table.find(identifier, type)) {
		appendError(UNDECLARED, tableName + " " + identifier);
		return MISMATCH;
	}
	return type;
}

void yyerror(const char* message) {
	appendError(SYNTAX, message);
}

int main(int argc, char *argv[]) {
	firstLine();
	yyparse();
	lastLine();
	return 0;
} 
