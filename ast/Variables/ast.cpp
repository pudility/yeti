#include <type_traits>
#include <iostream>

#include "ast.h"
#include "../../globals.h"

#include "llvm/IR/Constants.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/IR/Instructions.h"

using namespace llvm;

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

Value *VariableSetAST::codeGen() {
  Value *loadAlloca = mBuilder.CreateLoad(namedVariables[name]);
  Value *newValue = newVal->codeGen();

  mBuilder.CreateStore(newValue, loadAlloca);
  return newValue;
}

Value *PointerSetAST::codeGen() {
  return mBuilder.CreateStore(newVal->codeGen(), ptr->codeGen());
}

Value *VariableGetAST::codeGen() {
  Value *loadAlloca = mBuilder.CreateLoad(namedVariables[name]);
  Value *retValue = getPointer ? loadAlloca : mBuilder.CreateLoad(loadAlloca);

  if (ARC[ARCCurrentFunc][name] < 0) { // if we arent going to use the variable again, free it
    Instruction *castInst = new BitCastInst (loadAlloca, pi8);
    mBuilder.Insert(castInst);

    Function *freeCall = mModule->getFunction("free");
    std::vector<Value *> freeArgs = { castInst };
    mBuilder.CreateCall(freeCall, freeArgs);
  } else ARC[ARCCurrentFunc][name]--;

  return retValue;
}

Value *CastAST::codeGen() {
  Value *loadAlloca = mBuilder.CreateLoad(namedVariables[name]);
  Instruction *castInst = new BitCastInst (loadAlloca, PointerType::getUnqual(to));
  mBuilder.Insert(castInst);

  AllocaInst *alloca = CreateBlockAlloca(currentFunc, name, castInst->getType());
  mBuilder.CreateStore(castInst, alloca);
  namedVariables[name] = alloca;
  return castInst;
}

Value *ArrayGetAST::codeGen() {
  return mBuilder.CreateGEP(arrayPtr->codeGen(), index->codeGen());
}

Value *LoadVariableAST::codeGen() {
  return mBuilder.CreateLoad(ptr->codeGen());
}

std::string CastAST::out() {
  return std::string("Not Implemented");
}

std::string LoadVariableAST::out() {
  return std::string("Not Implemented");
}

std::string VariableAST::out() {
  return std::string("Not Implemented");
}

std::string VariableSetAST::out() {
  return std::string("Not Implemented");
}

std::string VariableGetAST::out() {
  return std::string("Not Implemented");
}

std::string ArrayGetAST::out() {
  return std::string("Not Implemented");
}

std::string PointerSetAST::out() {
  return std::string("Not Implemented");
}
