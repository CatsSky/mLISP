#ifndef NODE_H_INCLUDED
#define NODE_H_INCLUDED

#include <memory>
#include <string>
#include <variant>
#include <vector>
#include <optional>
#include <map>
#include "messages.h"

// short alias for std::holds_alternative<T>
template <typename T, typename... Args>
auto holds(Args&&... args) -> decltype(std::holds_alternative<T>(std::forward<Args>(args)...)) {
    return std::holds_alternative<T>(std::forward<Args>(args)...);
}

enum class op {
    plus, minus, mul, div, mod, greater, less, equal, logical_and, logical_or, logical_not
};

enum class node_type {
    integer, boolean, id, math_op, logical_op, if_, func, func_call, list
};

struct node {
    using node_val_t = std::variant<int, bool, std::string, op, std::shared_ptr<node>, std::vector<std::string>>;
    node_type type;
    node_val_t val;
    std::vector<std::shared_ptr<node>> operands{};
    std::shared_ptr<node> function_body;
    std::map<std::string, std::shared_ptr<node>> variable_frame{};

    node(node_type type, node_val_t val, std::vector<std::shared_ptr<node>> operands = {}, std::shared_ptr<node> function_body = nullptr):
        type(type),
        val(val),
        operands(operands),
        function_body(function_body){};

    node eval(const std::map<std::string, std::shared_ptr<node>>& = {}) const;
};

using variable_map = std::map<std::string, std::shared_ptr<node>>;

// series operations like plus and mul
template <typename T, typename U, typename binaryFunction>
U series_operation(std::vector<std::shared_ptr<node>> operands, T init, binaryFunction b, const variable_map& variables) {
    if(operands.size() < 2) error_argument(2, operands.size());
    for(const auto& operand : operands) {
        if(auto res = operand->eval(variables); holds<T>(res.val))
            init = b(init, std::get<T>(res.val));
        else error_type();
    }
    return init;
}

// single operations like minus and div
template <typename T, typename U, typename binaryFunction>
U single_operation(std::vector<std::shared_ptr<node>> operands, binaryFunction b, const variable_map& variables) {
    if(operands.size() != 2) error_argument(2, operands.size());
    auto op1 = operands[0]->eval(variables);
    auto op2 = operands[1]->eval(variables);
    if(holds<T>(op1.val) && holds<T>(op2.val))
        return b(std::get<T>(op1.val), std::get<T>(op2.val));
    else error_type();
}

// overload for std::logical_not<bool> operation
template <typename T, typename U>
U single_operation(std::vector<std::shared_ptr<node>> operands, std::logical_not<bool> b, const variable_map& variables) {
    if(operands.size() != 1) error_argument(1, operands.size());
    auto op1 = operands[0]->eval(variables);
    if(holds<T>(op1.val))
        return b(std::get<T>(op1.val));
    else error_type();
}

#endif