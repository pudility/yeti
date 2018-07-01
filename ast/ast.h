#pragma once

#include <vector>

#include "llvm/IR/Value.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/IRBuilder.h"

using namespace llvm;

// Global variables for use throughout all ASTs
static LLVMContext mContext;
static IRBuilder<> mBuilder(mContext);
static std::unique_ptr<Module> mModule = llvm::make_unique<Module>("foo", mContext);

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
