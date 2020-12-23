#include <iostream>
#include <sstream>
#include "messages.h"

void yyerror(const char* const s) {
    std::cerr << s << std::endl;
    exit(EXIT_FAILURE);
}

void error_argument(int expected, int got) {
    std::stringstream ss("");
    ss << "Need " << expected << " arguments, but got " << got << ".";
    yyerror(ss.str().c_str());
}

void error_undefined(const std::string& s) {
    std::stringstream ss("");
    ss << "Symbol not defined: " << s;
    yyerror(ss.str().c_str());
}

void error_type() {
    yyerror("Type error!");
}
