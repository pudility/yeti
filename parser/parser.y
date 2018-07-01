%code requires { 
#include "../ast/Number/ast.h"
#include "../ast/BinOp/ast.h"
#include "../ast/ast.h"
}

%{

#include <iostream>
#include <cctype>
#include <cstring>
#include <vector>
#include <stack>
#include <string>

#include "../ast/ast.h"

// extern "C" int yylex(void) { return 1; };
// extern "C" void yyerror(char const * s) { return; }

#define YYERROR_VERBOSE

// Prototypes to keep the compiler happy
void yyerror (const char *error) { std::cerr << error << std::endl; }

extern int  yylex ();

BlockAST *res;

%}

%union {
  std::string *string;
  NumberAST *number;
  BlockAST *base;
  BinOpAST *binOp;
  AST *any;
}

%token <string> TIDENTIFIER TINT TBINOP TOPENPAREN TCLOSEPAREN

%type <any> constExpr
%type <base> program statments 

%start program

%%
  program   : /* empty - top level */ { res = new BlockAST(); } 
            | statments { res = $1; }
          ;
  statments : constExpr { $$ = new BlockAST(); $$->statements.push_back($<any>1); }
            | statments constExpr { $1->statements.push_back($<any>2); }
          ;
  constExpr : TINT {
              $$ = new NumberAST(std::stoi(*$1)); 
            }
            | TIDENTIFIER { std::cout << *$1 << std::endl; }
            | constExpr TBINOP constExpr { $$ = new BinOpAST($1, $3, $2->c_str()[0]); }
            | TOPENPAREN constExpr TCLOSEPAREN { $$ = $2; }
          ;
%%
