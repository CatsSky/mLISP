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
        function_body(function_body) {};

    node eval(const std::map<std::string, std::shared_ptr<node>>& = {}) const;
};

// short alias for member types
using variable_map = std::map<std::string, std::shared_ptr<node>>;
using operands_t = std::vector<std::shared_ptr<node>>;

#endif