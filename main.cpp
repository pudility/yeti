#include "main.h"
#include "ast/ast.h"
#include "ast/Functions/ast.h"
#include "globals.h"

#include <utility>
#include <iostream>

extern FILE *yyin;
extern int yyparse();
extern BlockAST *res;

using namespace llvm;

std::string externMalloc () {
  std::vector<Type *> argTypes = { i32 };
  auto proto = std::make_unique<PrototypeAST>("malloc", std::move(argTypes), pi8);
  return proto->out();
}

int main (int argc, char **argv) {
  if (argc > 1) 
    yyin = fopen(argv[1], "r");
  else
    yyin = stdin;

  yyparse();
  std::cout << "output: "<< std::endl << externMalloc() << res->out() << std::endl;
}
