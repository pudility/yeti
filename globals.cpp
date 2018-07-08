#include "globals.h"

#include "llvm/IR/Value.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/IRBuilder.h"

using namespace llvm;

// Global variables for use throughout all ASTs
LLVMContext mContext;
IRBuilder<> mBuilder(mContext);
std::unique_ptr<Module> mModule = llvm::make_unique<Module>("foo", mContext);
std::map<std::string, AllocaInst *> namedVariables;
Function *currentFunc;

Type *i32 = IntegerType::get(mContext, 32);
Type *pi32 = PointerType::getUnqual(i32);
Type *i8 = IntegerType::get(mContext, 8);
Type *pi8 = PointerType::getUnqual(i8);
Type *dType = Type::getDoubleTy(mContext);
Type *pdType = PointerType::getUnqual(dType);

AllocaInst *CreateBlockAlloca(Function *func, std::string name, Type* type) {
  IRBuilder<> tmpBuilder(&func->getEntryBlock(), func->getEntryBlock().begin());
  return tmpBuilder.CreateAlloca(type, nullptr, name);
}
