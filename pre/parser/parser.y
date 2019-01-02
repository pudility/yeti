%code requires { 
#include "../ast/Number/ast.h"
#include "../ast/BinOp/ast.h"
#include "../ast/Functions/ast.h"
#include "../ast/Variables/ast.h"
#include "../ast/ast.h"
#include "../globals.h"

#include "llvm/IR/Constants.h"
}

%{

#include <iostream>
#include <cctype>
#include <cstring>
#include <vector>
#include <stack>
#include <string>
#include <utility>

#include "../ast/ast.h"

#define YYERROR_VERBOSE

// Prototypes to keep the compiler happy
void zzerror (const char *error) { std::cerr << error << std::endl; }

extern int  zzlex ();

std::map<std::string, std::map<std::string, int>> ARC;
std::string ARCCurrentFunc;

%}

%union {
  std::string *string;
  int number;
}

%token <string> TIDENTIFIER TINT TBINOP TOPENPAREN TCLOSEPAREN TOPENBRACE TCLOSEBRACE TFUNC TVAR TCAST TWDOUBLE TWINT TEQUALS TEXTERN TOPENBRACKET TCLOSEBRACKET TSTAR

%type <number> constExpr cast extern call program statments 
%type <string> func var 

%start program

%%
  program   : /* empty - top level */ {  } 
            | statments {  }
          ;
  statments : constExpr {  }
            | statments constExpr {  }
          ;
  constExpr : func { ARCCurrentFunc = *$1; }
            | var { ARC[ARCCurrentFunc][*$1] = 0; }
            | TIDENTIFIER { ARC[ARCCurrentFunc][*$1]++; } 
            // If its not one of the things above we dont care about it
            | call
            | cast
            | extern
            | constExpr TBINOP constExpr { }
            | TIDENTIFIER TEQUALS constExpr { }
            | TOPENPAREN constExpr TCLOSEPAREN { }
            | TINT
            | TBINOP
            | TOPENBRACKET
            | TCLOSEBRACKET
            | TSTAR
           // | TOPENPAREN
           // | TCLOSEPAREN
           // | TEQUALS
           // | TCAST
           // | TOPENPAREN
           // | TCLOSEBRACE 
           // | TFUNC
           // | TVAR
           // | TWDOUBLE
           // | TWINT
           // | TEXTERN
          ;
  var       : TVAR TIDENTIFIER TOPENPAREN TINT TCLOSEPAREN {
    $$ = $2;
  }
          ;
  call      : TIDENTIFIER TOPENPAREN valueArgs TCLOSEPAREN {}
          ;
  func      : TFUNC TIDENTIFIER TOPENPAREN funcArgs TCLOSEPAREN TOPENBRACE statments TCLOSEBRACE {
    $$ = $2;
  }
          ;
  funcArgs  : { }
            | funcArgs type TIDENTIFIER { }
          ;
  typeArgs  : { }
            | typeArgs type { }
          ;
  valueArgs  : { }
            | valueArgs constExpr { }
          ;
  cast      : TIDENTIFIER TCAST type { }
          ;
  type      : TWDOUBLE { }
            | TWINT { }
          ;
  extern    : TEXTERN TIDENTIFIER TOPENPAREN typeArgs TCLOSEPAREN TCAST type { }
          ;
%%
