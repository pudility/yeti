#include <type_traits>

#include "ast.h"

#include "llvm/IR/Constants.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

Value *BinOpAST::codeGen() {
  auto *left = L->codeGen();
  auto *right = R->codeGen();
  if (!left || !right) return nullptr;

  switch (op) {
    case '+':
      return mBuilder.CreateAdd(left, right, "addtmp");
    case '-':
      return mBuilder.CreateSub(left, right, "subtmp");
    case '*':
      return mBuilder.CreateMul(left, right, "multmp");
    case '/':
      return mBuilder.CreateSDiv(left, right, "divtmp");
    default:
      return ConstantInt::get(mContext, APInt(32, 0));
  }
}

std::string BinOpAST::out() {
  return std::string("Not Implemented");
}
