#pragma once

#include "llvm/IR/Value.h"

#include "../ast.h"

using namespace llvm;

class FunctionAST: public AST {
  std::string name;
  BlockAST *statments;
  std::vector<std::pair<std::string, Type *>> args;

  public:
    FunctionAST(
      std::string name, 
      std::vector<std::pair<std::string, Type *>> args,
      BlockAST *statments
    ): name(name), statments(statments), args(args) { }
    Value *codeGen() override;
    std::string out() override;
};
