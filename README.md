Primarily built compiler from a skeleton through the following files:

listing.cc
parser.y
scanner.l
tokens.h
types.cc
types.h
 
Front-end in C++/Flex/Bison, implementing lexical analysis, recursive-descent parsing, and a semantic analyzer. 

Enforces 18+ static type-checking rules (scope resolution, type coercion, narrowing detection)

Designed a templated symbol table supporting scoped variable/list declarations, with checks for undeclared and duplicate identifiers 
across nested scopes.

Implemented type inference and coercion logic for mixed integer/real arithmetic expressions, and strict type-matching rules for lists, 
switch/case statements, and conditional branches.

Extended the grammar to support new language features (real types, hexadecimal literals, exponentiation/negation/remainder operators), 
integrating each into the type-checking pipeline.

Validated correctness against a 19-case regression test suite covering type mismatches, narrowing errors, and list/subscript violations, 
achieving accurate line-level error reporting in the compilation listing.
