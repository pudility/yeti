#pragma once

#include <vector>

#include "llvm/IR/Value.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/IRBuilder.h"

using namespace llvm;

class AST {
  public:
    virtual ~AST() { }
    virtual Value *codeGen() = 0;
    virtual std::string out() = 0;
};

class BlockAST: public AST {
  public:
    std::vector<AST *> statements;

    virtual ~BlockAST () {
      statements.clear();
    }

    Value *codeGen() override;
    std::string out() override;
};

class WrapperAST: public AST {
  Value *val;

  public:
    WrapperAST(Value *val): val(val) { }
    Value *codeGen() override;
    std::string out() override;
};
