#ifndef MESSAGE_H
#define MESSAGE_H

void yyerror(const char* const s);
void error_argument(int expected, int got);
void error_undefined(const std::string& s);
void error_type();

#endif