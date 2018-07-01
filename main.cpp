#include "main.h"
#include "ast/ast.h"

#include <iostream>

extern FILE *yyin;
extern int yyparse();
extern BlockAST *res;

int main (int argc, char **argv) {
  if (argc > 1) 
    yyin = fopen(argv[1], "r");
  else
    yyin = stdin;

  yyparse();
  std::cout << "output: "<< std::endl << res->out() << std::endl;
}
