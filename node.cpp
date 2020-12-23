#include <iostream>
#include <memory>
#include <string>
#include <variant>
#include <numeric>
#include <sstream>
#include <algorithm>
#include <functional>
#include <map>
#include "node.h"
#include "mlisp.tab.hpp"

int math_op(op o, std::vector<std::shared_ptr<node>> operands, const variable_map& variables = {}) {
    switch(o) {
        case op::plus: 
            return series_operation<int, int>(operands, 0, std::plus<int>(), variables);
        case op::minus:
            return single_operation<int, int>(operands, std::minus<int>(), variables);

        case op::mul: 
            return series_operation<int, int>(operands, 1, std::multiplies<int>(), variables);
        case op::div:
            return single_operation<int, int>(operands, std::divides<int>(), variables);
        case op::mod:
            return single_operation<int, int>(operands, std::modulus<int>(), variables);
    }

    return {};
}

bool logical_op(op o, std::vector<std::shared_ptr<node>> operands, const variable_map& variables = {}) {
    switch(o) {
        case op::logical_and: 
            return series_operation<bool, bool>(operands, 1, std::logical_and<bool>(), variables);
        case op::logical_or: 
            return series_operation<bool, bool>(operands, 0, std::logical_or<bool>(), variables);
        case op::logical_not:
            return single_operation<bool, bool>(operands, std::logical_not<bool>(), variables);

        case op::greater:
            return single_operation<int, bool>(operands, std::greater<int>(), variables);
        case op::less:
            return single_operation<int, bool>(operands, std::less<int>(), variables);
        case op::equal: 
            return series_operation<int, bool>(operands, 1, std::equal_to<int>(), variables);
    }
    
    return {};
}

node eval_if(node& pred, node& expr1, node& expr2, const variable_map& variables = {}) {
    if(std::get<bool>(pred.eval(variables).val)) return expr1.eval(variables);
    else return expr2.eval(variables);
}

node node::eval(const variable_map& variables) const {
    switch(this->type) {
        // case node_type::integer:
        //     return std::get<int>(this->val);
        // case node_type::boolean:
        //     return std::get<bool>(this->val);
        case node_type::id:
            if(auto& id = std::get<std::string>(this->val); variables.count(id)) {
                node n = *(variables.at(id));
                if(n.type == node_type::func) {
                    n.type = node_type::func_call;
                    n.operands = this->operands;
                } 
                return n.eval(variables);
            } else
                error_undefined(id);

        case node_type::math_op:
            return node(node_type::integer, math_op(std::get<op>(this->val), this->operands, variables));
        case node_type::logical_op:
            return node(node_type::boolean, logical_op(std::get<op>(this->val), this->operands, variables));

        case node_type::if_: {
            const auto& predicate = std::get<std::shared_ptr<node>>(this->val);
            return eval_if(*predicate, *this->operands[0], *this->operands[1], variables);
        }
        
        case node_type::func: {
            auto n = *this;
            const auto& params = std::get<std::vector<std::string>>(n.val);
            for(const auto& [vname, vval]: variables)
                if(std::find(params.begin(), params.end(), vname) == params.end()) {
                    // variable is not in parameter, adding to the function frame
                    // TODO: consider substituting instead of extra storage
                    n.variable_frame[vname] = vval;
                }
            return n;
        }

        case node_type::func_call: {
            const auto& params = std::get<std::vector<std::string>>(this->val);
            auto param_count = params.size();
            auto operand_count = this->operands.size();
            if(param_count != operand_count) error_argument(param_count, operand_count);

            variable_map vf = variables;     // builds new function variable frame
            for(const auto& [vname, vval]: this->variable_frame)
                vf[vname] = vval;
            for(int i = 0; i < param_count; ++i)
                vf[params[i]] = std::make_shared<node>(this->operands[i]->eval(variables));
            
            return this->function_body->eval(vf);
        }

    }
    return *this;
}
