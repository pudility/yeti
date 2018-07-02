#include <type_traits>
#include <iostream>

#include "ast.h"
#include "../../globals.h"

#include "llvm/IR/Constants.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

Value *FunctionAST::codeGen() {
  Type *returnType = IntegerType::get(mContext, 32);
	std::vector<Type *> argTypes(args.size(), IntegerType::get(mContext, 32)); //TODO: reflect arg vector

	FunctionType *FT = FunctionType::get(returnType, argTypes, false);
	Function *func = Function::Create(FT, Function::ExternalLinkage, name, mModule.get());
  currentFunc = func;

  auto i = 0;
  for (auto &a: func->args()) {
    a.setName(args[i].first);
    i++;
  }

	// Create the function
	BasicBlock *bb = BasicBlock::Create(mContext, "entry", func);
	mBuilder.SetInsertPoint(bb);

  // Body of the function
  Value *lastLine;
  for (auto *line: statments->statements) {
    lastLine = line->codeGen();
    delete line;
  }

  // memory management
  statments->statements.clear();

	Value *returnValue = lastLine;
	mBuilder.CreateRet(returnValue);

  return func;
}

std::string FunctionAST::out() {
  return std::string("Not Implemented");
}

Value *PrototypeAST::codeGen() {
	FunctionType *FT = FunctionType::get(returnType, argTypes, false);
	Function *func = Function::Create(FT, Function::ExternalLinkage, name, mModule.get());
  currentFunc = func;  
  return func;
}

std::string PrototypeAST::out() {
  std::string outString;
  llvm::raw_string_ostream rso(outString);
  this->codeGen()->print(rso);
  
  return outString;
}
