# general cmake stuff
cmake_minimum_required (VERSION 2.6)
project (LLVM-Handbook)

# support cpp 11
set(CMAKE_CXX_FLAGS "-std=c++17 -Wno-register")

# LLVM stuff
find_package(LLVM PATHS "${LLVM_ROOT}/lib/cmake/llvm" "$ENV{ProgramFiles}/lib/cmake/llvm")

if( LLVM_FOUND )
    set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${LLVM_DIR}")
else()
    message(FATAL_ERROR "LLVM installation not found. Set LLVM_ROOT to the installation root path.")
endif()

include(LLVMConfig)
message(STATUS "Found LLVM Package Version:${LLVM_PACKAGE_VERSION}")
message(STATUS "LLVM Built type : ${LLVM_BUILD_TYPE}")
string(REGEX MATCH "[0-9]+\\.[0-9]+" LLVM_VER ${LLVM_PACKAGE_VERSION} )
if(${LLVM_VER} VERSION_LESS "3.8" )
    message(FATAL_ERROR "LLVM version before 3.8 are not supported. Abort!")
endif()
if(NOT ${LLVM_VER} VERSION_EQUAL "6.0" )
    message(WARNING "LLVM version before ${LLVM_VER} is not tested.")
endif()

llvm_map_components_to_libnames(REQ_LLVM_LIBRARIES mcjit interpreter native ipo)

# sources
set(SOURCES
  # cpp
  main.cpp
  ast/ast.cpp
  ast/Number/ast.cpp
  ast/BinOp/ast.cpp

  # Parser / Lexer
  lexer/tokens.l
  parser/parser.y
  ${CMAKE_CURRENT_BINARY_DIR}/parser.cpp
  ${CMAKE_CURRENT_BINARY_DIR}/tokens.cpp
)

set(HEADERS
  main.h  

  ast/ast.h
  ast/Number/ast.h
  ast/BinOp/ast.h
)


# Bison / flex
FIND_PACKAGE(FLEX)
FIND_PACKAGE(BISON)

ADD_CUSTOM_TARGET(Parser echo "Creating parser")

# BISON_TARGET(MyParser ${CMAKE_CURRENT_SOURCE_DIR}/parser/parser.y ${CMAKE_CURRENT_BINARY_DIR}/parser.cpp)
# FLEX_TARGET(MyScanner ${CMAKE_CURRENT_SOURCE_DIR}/lexer/tokens.l ${CMAKE_CURRENT_BINARY_DIR}/tokens.cpp)
# ADD_FLEX_BISON_DEPENDENCY(MyScanner MyParser)

ADD_CUSTOM_COMMAND(
  SOURCE  ${CMAKE_CURRENT_SOURCE_DIR}/lexer/tokens.l
  COMMAND ${FLEX_EXECUTABLE}
  ARGS -o ${CMAKE_CURRENT_BINARY_DIR}/tokens.cpp
          ${PROJECT_SOURCE_DIR}/lexer/tokens.l 
  TARGET  Parser
  OUTPUTS ${CMAKE_CURRENT_BINARY_DIR}/tokens.cpp
)

ADD_CUSTOM_COMMAND(
  SOURCE  ${CMAKE_CURRENT_SOURCE_DIR}/parser/parser.y
  COMMAND ${BISON_EXECUTABLE}
  ARGS -y ${CMAKE_CURRENT_SOURCE_DIR}/parser/parser.y
       -o ${CMAKE_CURRENT_BINARY_DIR}/parser.cpp
       --defines=parser.h
  TARGET Parser
  DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/tokens.cpp
  OUTPUTS ${CMAKE_CURRENT_BINARY_DIR}/parser.cpp
)


# BISON_TARGET(Parser parser/parser.y ${CMAKE_CURRENT_BINARY_DIR}/parser.c)
# FLEX_TARGET(Lexer lexer/tokens.l ${CMAKE_CURRENT_BINARY_DIR}/tokens.c)
# ADD_FLEX_BISON_DEPENDENCY(Lexer Parser)

# parser isnt generated so we need to set its property
SET_SOURCE_FILES_PROPERTIES(${CMAKE_CURRENT_BINARY_DIR}/parser.cpp GENERATED)
include_directories(${CMAKE_CURRENT_BINARY_DIR})


# versions
set(VER_MAJ 0)
set(VER_MIN 0)
set(VER_REV 0)

# build
add_executable(main ${SOURCES} ${HEADERS}  ${BISON_Parser_OUTPUTS} ${FLEX_Scanner_OUTPUTS}) # compile

target_compile_definitions(main PRIVATE YY_NO_UNISTD_H)
target_compile_definitions(main PRIVATE _SCL_SECURE_NO_WARNINGS)
target_compile_definitions(main PRIVATE _CRT_SECURE_NO_WARNINGS)
target_compile_definitions(main PRIVATE _SILENCE_ALL_CXX17_DEPRECATION_WARNINGS)
set_source_files_properties(${CMAKE_CURRENT_BINARY_DIR}/tokens.c PROPERTIES COMPILE_DEFINITIONS __STDC_VERSION__=199901L)

target_include_directories(main PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
target_link_libraries(main ${REQ_LLVM_LIBRARIES}) # link with llvm
