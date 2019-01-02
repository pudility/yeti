/* scanner for a toy Pascal-like language */

%{
/* need this for the call to atof() below */
#include <math.h>
#include <unistd.h>
#include <string>
#include <iostream>
#include "preparser.h"

#include "../ast/Number/ast.h"

extern "C" int zzwrap() { return 1; }
extern "C" void zzerror (const char *error) { std::cerr << error << std::endl; }

#define SAVE_TOKEN zzlval.string = new std::string(zztext, zzleng)
#define TOKEN(t) (zzlval.token = t)

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

"->" {
  SAVE_TOKEN; return TCAST;
}

"func" {
  SAVE_TOKEN; return TFUNC;
}

"var" {
  SAVE_TOKEN; return TVAR;
}

"Double" {
  SAVE_TOKEN; return TWDOUBLE;
}

"Int" {
  SAVE_TOKEN; return TWINT;
}

"extern" {
  SAVE_TOKEN; return TEXTERN;
}

"{" {
  SAVE_TOKEN; return TOPENBRACE;
}

"}" {
  SAVE_TOKEN; return TCLOSEBRACE;
}

"[" {
  SAVE_TOKEN; return TOPENBRACKET;
}

"]" {
  SAVE_TOKEN; return TCLOSEBRACKET;
}

"+"|"-"|"*"|"/" {
  SAVE_TOKEN; return TBINOP;
} 

"=" {
  SAVE_TOKEN; return TEQUALS;
}

"*" {
  SAVE_TOKEN; return TSTAR;
}

{ID}        SAVE_TOKEN; return TIDENTIFIER; // printf( "An identifier: %s\n", yytext );

#.* {/* one-line comment */}

[ \t\n]+          /* eat up whitespace */

.           printf( "Unrecognized character: %s\n", yytext );

%%
