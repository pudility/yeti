#include "main.h"
#include "ast/ast.h"
#include "ast/Functions/ast.h"
#include "globals.h"

#include <utility>
#include <iostream>

extern FILE *yyin;
extern FILE *zzin;
extern int yyparse();
extern int zzparse();
extern BlockAST *res;
extern std::map<std::string, std::map<std::string, int>> ARC;

using namespace llvm;

std::string externMalloc () {
  std::vector<Type *> argTypes = { i32 };
  auto proto = std::make_unique<PrototypeAST>("malloc", std::move(argTypes), pi8);
  return proto->out();
}

std::string externFree () {
  std::vector<Type *> argTypes = { pi8 };
  auto proto = std::make_unique<PrototypeAST>("free", std::move(argTypes), i8);
  return proto->out();
}

int main (int argc, char **argv) {
  if (argc > 1) {
    zzin = fopen(argv[1], "r");
    yyin = fopen(argv[1], "r");
  } else {
    throw std::invalid_argument("Did not recive file as second argument!");
  }

  zzparse(); // set arc so that we can use it to free memory after variables have been created
  yyparse();
  std::cout << externMalloc() << externFree() << res->out() << std::endl;
}
