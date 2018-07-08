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
  FunctionAST *func;
  std::vector<std::pair<std::string, llvm::Type *>> *args;
  std::vector<Type *> *typeArgs;
  std::vector<AST *> *valueArgs;
  llvm::Type *type;
}

%token <string> TIDENTIFIER TINT TBINOP TOPENPAREN TCLOSEPAREN TOPENBRACE TCLOSEBRACE TFUNC TVAR TCAST TWDOUBLE TWINT TEQUALS TEXTERN
%token <args> arg

%type <any> constExpr func var cast extern call
%type <base> program statments 
%type <args> funcArgs
%type <typeArgs> typeArgs
%type <type> type
%type <valueArgs> valueArgs

%start program

%%
  program   : /* empty - top level */ { res = new BlockAST(); } 
            | statments { res = $1; }
          ;
  statments : constExpr { $$ = new BlockAST(); $$->statements.push_back($<any>1); }
            | statments constExpr { $1->statements.push_back($<any>2); }
          ;
  constExpr : TINT { $$ = new NumberAST(std::stoi(*$1)); }
            | func { $$ = $<any>1; }
            | var { $$ = $<any>1; }
            | cast { $$ = $<any>1; }
            | extern { $$ = $<any>1; }
            | call { $$ = $<any>1; }
            | TIDENTIFIER { $$ = new VariableGetAST(*$<string>1); } 
            | constExpr TBINOP constExpr { $$ = new BinOpAST($1, $3, $2->c_str()[0]); }
            | TIDENTIFIER TEQUALS constExpr { $$ = new VariableSetAST(*$<string>1, $<any>3); }
            | TOPENPAREN constExpr TCLOSEPAREN { $$ = $2; }
          ;
  var       : TVAR TIDENTIFIER TOPENPAREN TINT TCLOSEPAREN {
    $$ = new VariableAST(*$2, std::stoi(*$4));
  }
          ;
  call      : TIDENTIFIER TOPENPAREN valueArgs TCLOSEPAREN {
    $$ = new CallAST(*$<string>1, *$<valueArgs>3);
  }
          ;
  func      : TFUNC TIDENTIFIER TOPENPAREN funcArgs TCLOSEPAREN TOPENBRACE statments TCLOSEBRACE {
    $$ = new FunctionAST(*$<string>2, *$<args>4, $<base>7); 
  }
          ;
  funcArgs  : { 
    auto tmpArgs = std::vector<std::pair<std::string, llvm::Type *>>();
    $$ = &tmpArgs;
  }
            | funcArgs type TIDENTIFIER { 
    $1->push_back(std::make_pair(*$<string>3, $<type>2)); 
  }
          ;
  typeArgs  : { 
    auto tmpArgs = std::vector<Type *>();
    $$ = &tmpArgs;
  }
            | typeArgs type { 
              $1->push_back($<type>2); 
            }
          ;
  valueArgs  : { 
    auto tmpArgs = std::vector<AST *>();
    $$ = &tmpArgs;
  }
            | valueArgs constExpr { 
              $1->push_back($<any>2); 
            }
          ;
  cast      : TIDENTIFIER TCAST type { $$ = new CastAST(*$<string>1, $<type>3); }
          ;
  type      : TWDOUBLE { $$ = dType; }
            | TWINT { $$ = i32; }
          ;
  extern    : TEXTERN TIDENTIFIER TOPENPAREN typeArgs TCLOSEPAREN TCAST type { 
    $$ = new PrototypeAST(*$<string>2, *$<typeArgs>4, $<type>7);
  }
          ;
%%
