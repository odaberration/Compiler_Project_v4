/* Nicholas Wingfield
 Compiler Theory and Design
 10/7/2025
 */

/* This file contains flex input file. Adjusted to include additional operators, token funtionality and underscore error checking 
additional update to place id at bottom order and update identifier rules with respective TYPE*/

%{
#include <cstdio>
#include <string>
#include <vector>


using namespace std;

#include "types.h"
#include "listing.h"
#include "tokens.h"
#include "parser.tab.h"

%}

%option noyywrap


digit		[0-9]
hex     	[0-9A-Fa-f]+
real		{digit}*\.{digit}+
dec			{digit}+
exp			([eE][+-]?{digit}+)?
charEsc		(\\[btnrf'\\])
char		\'({charEsc}|[^\\'\n])\'
punc		[\(\),:;]
ws			[ \t\r]+
comment		\/\/.*\n
commentIn	\-\-.*\n
line		[\n]
id			[A-Za-z]([A-Za-z0-9_]*[A-Za-z0-9])?
%%

{ws}		{ ECHO; }
{comment}	{ ECHO; nextLine(); }
{commentIn} { ECHO; nextLine(); }
{line}		{ ECHO; nextLine(); }
"+"			{ ECHO; return(ADDOP); }
"-"			{ ECHO; return(ADDOP); }
"*"			{ ECHO; return(MULOP); }
"/"			{ ECHO; return(MULOP); }
"%"			{ ECHO; return(REMOP); }
"^"			{ ECHO; return(EXPOP); }
"~"			{ ECHO; return(NEGOP); }
"&"			{ ECHO; return(ANDOP); }
"|"			{ ECHO; return(OROP); }
"!"			{ ECHO; return(NOTOP); }
"<"			{ ECHO; return(RELOP); }
">"			{ ECHO; return(RELOP); }
"<="		{ ECHO; return(RELOP); }
">="		{ ECHO; return(RELOP); }
"="			{ ECHO; return(RELOP); }
"<>"		{ ECHO; return(RELOP); }
"=>"		{ ECHO; return(ARROW); }
begin		{ ECHO; return(BEGIN_); }
case		{ ECHO; return(CASE); }
character	{ ECHO; return(CHARACTER); }
end			{ ECHO; return(END); }
endif		{ ECHO; return(ENDIF); }
endswitch	{ ECHO; return(ENDSWITCH); }
function	{ ECHO; return(FUNCTION); }
integer		{ ECHO; return(INTEGER); }
is			{ ECHO; return(IS); }
list		{ ECHO; return(LIST); }
of			{ ECHO; return(OF); }
others		{ ECHO; return(OTHERS); }
returns		{ ECHO; return(RETURNS); }
switch		{ ECHO; return(SWITCH); }
when		{ ECHO; return(WHEN); }
if			{ ECHO; return(IF); }
then		{ ECHO; return(THEN); }
elsif		{ ECHO; return(ELSIF); }
else		{ ECHO; return(ELSE); }
fold		{ ECHO; return(FOLD); }
endfold		{ ECHO; return(ENDFOLD); }
left		{ ECHO; return(LEFT); }
right		{ ECHO; return(RIGHT); }
real		{ ECHO; return(REAL); }

{id}		{ ECHO; 
				yylval.iden = (char*)malloc(yyleng + 1); 
				memcpy(yylval.iden, yytext, yyleng + 1);
				 return(IDENTIFIER);

				const char* a = yytext;
				int underscoreCheck = 0;          
				int foundError = 0;

				for (const char* b = a; *b; ++b) {
					if (*b == '_') {
						if (++underscoreCheck > 2) {
							appendError(LEXICAL, "_");
							foundError = 1;
						}
					} 
					else {
							underscoreCheck = 0;
					}
				}

				if (!foundError) {
					return IDENTIFIER;
				}
			}
{real}{exp}	{ ECHO;  
				yylval.type = REAL_TYPE; return REAL_LITERAL;}		
{dec}		{ ECHO;  
				yylval.type = INT_TYPE;  return INT_LITERAL;}
{char}		{ ECHO;  
				yylval.type = CHAR_TYPE; return CHAR_LITERAL;}
{punc}		{ ECHO; return(yytext[0]); }
"#"{hex}	{ ECHO; 
				yylval.type = INT_TYPE;  return INT_LITERAL; }
.			{ ECHO; appendError(LEXICAL, std::string(1, yytext[0])); }

%%
