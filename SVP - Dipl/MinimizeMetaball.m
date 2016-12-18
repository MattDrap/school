function [ best_radius, best_density ] = MinimizeMetaball( probGT, probIm, center, initDensity, par  )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

best_radius = [];
best_density = initDensity;

d = initDensity;

r = par.init_radius;
r_step = 1;
previous = 0;
[base_err, best_density] = MinimizeMetaball2( probGT, probIm, center, d, r, par );
added_momentum = false;
for i  = 1:par.max_iter_opt
    errs = Inf * ones(2, 1);
    op_d = zeros(6, 2, 1);
    [errs(1), op_d(:, 1)] = MinimizeMetaball2( probGT, probIm, center, d, r + r_step, par );
    if r - r_step > 1
        [errs(2), op_d(:, 2)] = MinimizeMetaball2( probGT, probIm, center, d, r - r_step, par );
    end
    [val, ind] = min(errs);
    
    if val >= base_err
        if added_momentum
            if previous > 0
               r_step = r_step / 2; 
            end
            added_momentum = false;
        else
            %%Ending conditions
            if r <= 1
               best_density = 0;
               best_radius = Inf;
               break;
            end
            
            best_radius = r;
            best_density = op_d(:, ind);
            break;
        end
    else
        switch(ind)
            case 1
                r = r + r_step;
                d = op_d(:, 1);
            case 2
                r = r - r_step;
                d = op_d(:, 2);
        end
        
         %%Momentum
        if previous == ind
           r_step = r_step * 2; 
           added_momentum = true;
        elseif previous ~= 0 && added_momentum
           r_step = r_step / 2; 
           added_momentum = false;
        end
        %
        
        %%Ending conditions
        if r <= 1
           best_density = 0;
           best_radius = Inf;
           break;
        end
        
        previous = ind;
        base_err = val;
    end
end
if i >= par.max_iter_opt
    'Stopped prematurely'
end
if isempty(best_radius)
    best_radius = r;
    best_density = d;
end

end