%{
#include <memory>
#include "node.h"
#include "mlisp.tab.hpp"
%}

%option noyywrap

%%
"+" return PLUS;
"-" return MINUS;
"*" return MUL;
"/" return DIV;
"mod" return MOD;

">" return GREATER;
"<" return LESS;
"=" return EQUAL;

"and" return AND;
"or" return OR;
"not" return NOT;

"print-num" return PRINT_NUMBER;
"print-bool" return PRINT_BOOLEAN;
"define" return DEFINE;
"if" return IF;
"fun" return FUN;

"0"|([1-9][0-9]*)|(-[1-9][0-9]*) {
    yylval = std::make_shared<node>(node_type::integer, std::stoi(yytext));
    return NUMBER;
}

"#"[tf] {
    yylval = std::make_shared<node>(node_type::boolean, yytext[1] == 't');
    return BOOLEAN;
}

[a-z]([a-z0-9\-])* {
    yylval = std::make_shared<node>(node_type::id, std::string{yytext});
    return ID;
}

[()] return yytext[0];

[ \t\n\r] ;

. return yytext[0];

%%
