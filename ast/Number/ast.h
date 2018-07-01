#pragma once

#include "llvm/IR/Value.h"

#include "../ast.h"

using namespace llvm;

// template <typename T>
class NumberAST: public AST {
  int val; //T val;

  public:
    NumberAST(int val): val(val) { }
    Value *codeGen() override;
    std::string out() override;
};
