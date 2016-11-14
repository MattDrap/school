% Constructs a string representation of a dnf expression.
% Input:
% dnf is a cell array (for description of the format, see function dnf2dnf)
% variable_names is a cell array containing names of variables - strings
function [str] = dnf2str(dnf, variables_names)
str = '';
for i = 1:length(dnf)
    str = [str '('];
    clause = dnf{i};
    for j = 1:length(dnf{i})
        variable = clause(j);
        if variable < 0
            variable = -variable;
            str = [str '~'];
        end
        str = [str variables_names{variable}];
        if j < length(clause)
            str = [str ' & '];
        end
    end
    str = [str ')'];
    if i < length(dnf)
        str = [str ' | '];
    end
end