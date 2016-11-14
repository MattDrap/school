% Constructs a string representation of a cnf expression.
% Input:
% cnf is a cell array (for description of the format, see function cnf2dnf)
% variable_names is a cell array containing names of variables - strings
function [str] = cnf2str(cnf, variables_names)
str = '';
for i = 1:length(cnf)
    str = [str '('];
    clause = cnf{i};
    for j = 1:length(cnf{i})
        variable = clause(j);
        if variable < 0
            variable = -variable;
            str = [str '~'];
        end
        str = [str variables_names{variable}];
        if j < length(clause)
            str = [str ' | '];
        end
    end
    str = [str ')'];
    if i < length(cnf)
        str = [str ' & '];
    end
end