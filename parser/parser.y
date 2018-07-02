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
  llvm::Type *type;
}

%token <string> TIDENTIFIER TINT TBINOP TOPENPAREN TCLOSEPAREN TOPENBRACE TCLOSEBRACE TFUNC TVAR TCAST TWDOUBLE TWINT
%token <args> arg

%type <any> constExpr func var cast
%type <base> program statments 
%type <args> funcArgs
%type <type> type

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
            | TIDENTIFIER { std::cout << *$1; } // dont use this
            | constExpr TBINOP constExpr { $$ = new BinOpAST($1, $3, $2->c_str()[0]); }
            | TOPENPAREN constExpr TCLOSEPAREN { $$ = $2; }
          ;
  var       : TVAR TIDENTIFIER TOPENPAREN TINT TCLOSEPAREN {
    $$ = new VariableAST(*$2, std::stoi(*$4));
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
            | TIDENTIFIER { 
    auto tmpArgs = std::vector<std::pair<std::string, llvm::Type *>>();
    tmpArgs.push_back(std::make_pair(*$<string>1, IntegerType::get(mContext, 32)));
    $$ = &tmpArgs;
  }
            | funcArgs TIDENTIFIER { $1->push_back(std::make_pair(*$<string>2, IntegerType::get(mContext, 32))); }
          ;
  cast      : TIDENTIFIER TCAST type { $$ = new CastAST(*$<string>1, $<type>3); }
          ;
  type    : TWDOUBLE { $$ = pdType; }
          | TWINT { $$ = pi32; }
        ;
%%
