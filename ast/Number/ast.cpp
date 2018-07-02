#include <type_traits>

#include "ast.h"
#include "../../globals.h"

#include "llvm/IR/Constants.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

extern LLVMContext mContext;

Value *NumberAST::codeGen() {
  // if constexpr (std::is_same<T, float> || std::is_same<T, double>)
  //   return ConstantFP::get(mContext, APFloat((double) val));
  return ConstantInt::get(mContext, APInt(32, val));
}

std::string NumberAST::out() {
  std::string outString;
  llvm::raw_string_ostream rso(outString);
  this->codeGen()->print(rso);
  
  return outString;
}
