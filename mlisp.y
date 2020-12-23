%{
#include <iostream>
#include <map>
#include <memory>
#include <sstream>
#include "node.h"
#include "messages.h"

extern int yyparse(void);
extern int yylex(void);  

extern int yydebug;

std::map<std::string, std::shared_ptr<node>> globals {};

%}

%define api.value.type { std::shared_ptr<node> }
%define parse.error verbose

%code requires {    // inserts to header
    
}

%token BOOLEAN NUMBER ID
%token PLUS  MINUS MUL DIV MOD
%token GREATER LESS EQUAL
%token AND OR NOT;
%token IF DEFINE FUN
%token PRINT_NUMBER PRINT_BOOLEAN

%%

stmts:
    stmt stmts {} |
     {}
    ;

stmt:
    expr { $$ = $1; $$->eval(globals); } |
    def_stmt {
        auto& v = $1;
        auto& id = std::get<std::string>(v->val);
        globals[id] = v->operands[0];
    } |
    print_stmt {}
    ;

def_stmt:
    '(' DEFINE ID expr ')' {    // id type, expr in operands[0]
        auto& expr = $4;
        auto& id = std::get<std::string>($3->val);
        if(expr->type != node_type::func)
            $$ = std::make_shared<node>(node_type::id, id, operands_t{std::make_shared<node>(expr->eval(globals))});
        else
            $$ = std::make_shared<node>(node_type::id, id, operands_t{expr});
    }
    ;

print_stmt:
    '(' PRINT_NUMBER expr ')' {     // no return value
        auto& e = $3;
        if(auto res = $3->eval(globals); res.type == node_type::integer)
            std::cout << std::get<int>(res.val) << std::endl;
        else error_type();
    } |
    '(' PRINT_BOOLEAN expr ')' {    // no return value
        if(auto res = $3->eval(globals); res.type == node_type::boolean)
            std::cout << (std::get<bool>(res.val) ? "#t" : "#f") << std::endl;
        else error_type();
    }
    ;

expr:
    BOOLEAN { $$ = $1; } |
    NUMBER { $$ = $1; } |
    ID { $$ = $1; } |
    number_op { $$ = $1; } |
    logical_op { $$ = $1; } |
    func_expr { $$ = $1; } |
    func_call { $$ = $1; } |
    if_expr { $$ = $1; }
    ;

number_op:
    '(' PLUS exprs ')' { 
        $$ = std::make_shared<node>(node_type::math_op, op::plus);
        $$->operands = $3->operands;
    } |
    '(' MINUS exprs ')' { 
        $$ = std::make_shared<node>(node_type::math_op, op::minus);
        $$->operands = $3->operands;
    } |
    '(' MUL exprs ')' { 
        $$ = std::make_shared<node>(node_type::math_op, op::mul);
        $$->operands = $3->operands;
    } |
    '(' DIV exprs ')' { 
        $$ = std::make_shared<node>(node_type::math_op, op::div);
        $$->operands = $3->operands;
    } |
    '(' MOD exprs ')' { 
        $$ = std::make_shared<node>(node_type::math_op, op::mod);
        $$->operands = $3->operands;
    }
    ;

logical_op:
    '(' EQUAL exprs ')' { 
        $$ = std::make_shared<node>(node_type::logical_op, op::equal);
        $$->operands = $3->operands;
    } |
    '(' GREATER exprs ')' { 
        $$ = std::make_shared<node>(node_type::logical_op, op::greater);
        $$->operands = $3->operands;
    } |
    '(' LESS exprs ')' { 
        $$ = std::make_shared<node>(node_type::logical_op, op::less);
        $$->operands = $3->operands;
    } |
    '(' AND exprs ')' { 
        $$ = std::make_shared<node>(node_type::logical_op, op::logical_and);
        $$->operands = $3->operands;
    } |
    '(' OR exprs ')' { 
        $$ = std::make_shared<node>(node_type::logical_op, op::logical_or);
        $$->operands = $3->operands;
    } |
    '(' NOT exprs ')' { 
        $$ = std::make_shared<node>(node_type::logical_op, op::logical_not);
        $$->operands = $3->operands;
    }
    ;

if_expr:
    '(' IF expr expr expr ')' {
        $$ = std::make_shared<node>(node_type::if_, $3, operands_t{$4, $5});
    }
    ;

func_expr:
    '(' FUN '(' params ')' defs expr ')' {
        std::vector<std::string> params{};
        const auto& pnode = *$4;  // pnode is type list, getting params from pnode's operands
        for(const auto& p: pnode.operands)
            params.push_back(std::move(std::get<std::string>(p->val)));

        auto res = std::make_shared<node>(node_type::func, std::move(params), operands_t{}, $7);

        auto& list = $6->operands;
        for(const auto& v: list) {
            auto& id = std::get<std::string>(v->val);
            res->variable_frame[id] = v->operands[0];
        }
        $$ = res;
    }
    ;

defs:
    defs def_stmt { $$ = $1; $$->operands.push_back($2); } |
     { $$ = std::make_shared<node>(node_type::list, 0); }
    ;

params:
    params ID { $$ = $1; $$->operands.push_back($2); } |
     { $$ = std::make_shared<node>(node_type::list, 0); }
    ;

func_call:
    '(' ID exprs ')' {      // pass func node as id node with operands
        node func = *$2;    // eval() will try to get the corresponding function
        func.operands = $3->operands;
        func.type = node_type::id;
        $$ = std::make_shared<node>(std::move(func));
    } |
    '(' func_expr exprs ')' {
        node func = *$2;
        func.operands = $3->operands;
        func.type = node_type::func_call;
        $$ = std::make_shared<node>(std::move(func));
    }
    ;

exprs:
    exprs expr { $$ = $1; $$->operands.push_back($2); } |
     { $$ = std::make_shared<node>(node_type::list, 0); }
    ;
%%

int main(void) {
    // yydebug = 1;
    yyparse();
    return 0;
}
