#pragma once

#include "llvm/IR/Value.h"

#include "../ast.h"

using namespace llvm;

class VariableAST: public AST {
  std::string name;
  int size;

  public:
    VariableAST(
      std::string name, 
      int size
    ): name(name), size(size) { }
    Value *codeGen() override;
    std::string out() override;
};

class VariableSetAST: public AST {
  std::string name;
  AST *newVal;

  public:
    VariableSetAST(
      std::string name,
      AST *newVal
    ): name(name), newVal(newVal) { }
    Value *codeGen() override;
    std::string out() override;
};

class PointerSetAST: public AST {
  AST *ptr;
  AST *newVal;

  public:
    PointerSetAST(
      AST *ptr,
      AST *newVal
    ): ptr(ptr), newVal(newVal) { }
    Value *codeGen() override;
    std::string out() override;
};

class VariableGetAST: public AST {
  std::string name;
  bool getPointer;

  public:
    VariableGetAST(
      std::string name,
      bool getPointer = false
    ): name(name), getPointer(getPointer) { }
    Value *codeGen() override;
    std::string out() override;
};

class CastAST: public AST {
  std::string name;
  Type *to;

  public:
    CastAST(std::string name, Type *to): name(name), to(to) { }
    Value *codeGen() override;
    std::string out() override;
};

class ArrayGetAST: public AST {
  AST *arrayPtr;
  AST *index;

  public:
    ArrayGetAST(AST *arrayPtr, AST *index): 
      arrayPtr(arrayPtr), index(index) { }
    Value *codeGen() override;
    std::string out() override;
};

class LoadVariableAST: public AST {
  AST *ptr;

  public:
    LoadVariableAST(AST *ptr): ptr(ptr) { }
    Value *codeGen() override;
    std::string out() override;
};
