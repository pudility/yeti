#pragma once

#include "llvm/IR/Value.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/IRBuilder.h"

using namespace llvm;

// Global variables for use throughout all ASTs
extern LLVMContext mContext;
extern IRBuilder<> mBuilder;
extern std::unique_ptr<Module> mModule;
extern std::map<std::string, AllocaInst *> namedVariables;
extern Function *currentFunc;

// types
extern Type *i32;
extern Type *pi32;
extern Type *i8;
extern Type *pi8;
extern Type *dType;
extern Type *pdType;
