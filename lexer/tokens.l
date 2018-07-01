/* scanner for a toy Pascal-like language */

%{
/* need this for the call to atof() below */
#include <math.h>
#include <unistd.h>
#include <string>
#include <iostream>
#include "parser.h"

#include "../ast/Number/ast.h"

extern "C" int yywrap() { return 1; }
extern "C" void yyerror (const char *error) { std::cerr << error << std::endl; }

#define SAVE_TOKEN yylval.string = new std::string(yytext, yyleng)
#define TOKEN(t) (yylval.token = t)

%}

DIGIT    [0-9]
ID       [a-z][a-z0-9]*

%%

{DIGIT}+ {
              SAVE_TOKEN; return TINT;
}

{DIGIT}+"."{DIGIT}* {
              SAVE_TOKEN; return TINT; // TFP;
}

"(" {
  SAVE_TOKEN; return TOPENPAREN;
}

")" {
  SAVE_TOKEN; return TCLOSEPAREN;
}

if|then|begin|end|procedure|function        {
            printf( "A keyword: %s\n", yytext );
            }

{ID}        SAVE_TOKEN; return TIDENTIFIER; // printf( "An identifier: %s\n", yytext );

"+"|"-"|"*"|"/" {
  SAVE_TOKEN; return TBINOP;
} 

#.* {/* one-line comment */}

[ \t\n]+          /* eat up whitespace */

.           printf( "Unrecognized character: %s\n", yytext );

%%