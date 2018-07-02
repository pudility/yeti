#include <type_traits>
#include <iostream>

#include "ast.h"
#include "../../globals.h"

#include "llvm/IR/Constants.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/IR/Instructions.h"

using namespace llvm;

static AllocaInst *CreateBlockAlloca(Function *func, std::string name, Type* type) {
  IRBuilder<> tmpBuilder(&func->getEntryBlock(), func->getEntryBlock().begin());
  return tmpBuilder.CreateAlloca(type, nullptr, name);
}

Value *VariableAST::codeGen() {
  Function *func = currentFunc; // insert point for alloca

  // create value from malloc
  Function *mallocCall = mModule->getFunction("malloc");
  std::vector<Value *> mallocArgs = { ConstantInt::get(mContext, APInt(32, size)) };

  AllocaInst *alloca = CreateBlockAlloca(func, name, pi8);
  Value *mallocVal = mBuilder.CreateCall(mallocCall, mallocArgs);
  mBuilder.CreateStore(mallocVal, alloca);
  namedVariables[name] = alloca;
  return alloca;
}

Value *CastAST::codeGen() {
  Value *loadAlloca = mBuilder.CreateLoad(namedVariables[name]);
  Instruction *castInst = new BitCastInst (loadAlloca, to);
  mBuilder.Insert(castInst);

  AllocaInst *alloca = CreateBlockAlloca(currentFunc, name, castInst->getType());
  mBuilder.CreateStore(castInst, alloca);
  namedVariables[name] = alloca;
  return castInst;
}

std::string CastAST::out() {
  return std::string("Not Implemented");
}

std::string VariableAST::out() {
  return std::string("Not Implemented");
}
