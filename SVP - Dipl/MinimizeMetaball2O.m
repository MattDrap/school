function [ best_err, best_density ] = MinimizeMetaball2O( probGT, probIm, center, initDensity, radius, par  )
best_density = 0;

d = initDensity;
d_step = 0.5;
previous = 0;
best_err = OptimizeMetaball( probGT, probIm, radius, d, center, par );
added_momentum = false;
for i  = 1:par.max_iter_opt
    errs = Inf * ones(12, 1);
    for j = 1:6
        td = d;
        td(j) = td(j) + d_step;
        errs(2*j - 1) = OptimizeMetaball( probGT, probIm, radius, td, center, par );
        %
        td = d;
        td(j) = td(j) - d_step;
        errs(2*j) = OptimizeMetaball( probGT, probIm, radius, td, center, par );
    end

    [val, ind] = min(errs);
    
    if val >= best_err
        if added_momentum
            d_step = d_step / 2;
            added_momentum = false;
        else
            %%Ending conditions
            if radius < 1e-8
               break;
            end
            if any(d > initDensity)
                best_density = initDensity;
                break;
            end
            best_density = d;
            break;
        end
    else
        w_ind = floor((ind - 1) / 2) + 1;
        p = mod(ind, 2); %plus - 1 / minus - 0
        if(p)
            d( w_ind ) = d( w_ind ) + d_step;
        else
            d( w_ind ) = d( w_ind ) - d_step;
        end
         %%Momentum
        if previous == ind
           d_step = d_step * 2;
           added_momentum = true;
        elseif previous ~= 0 && added_momentum
           d_step = d_step / 2;
           added_momentum = false;
        end
        %
        
        %%Ending conditions
        if radius < 1e-8
           break;
        end
        if any(d > initDensity)
            best_density = initDensity;
            break;
        end
        if any(d < 0)
            best_density = initDensity;
            best_err = Inf;
            break;
        end
        previous = ind;
        best_err = val;
    end
end
if i >= par.max_iter_opt
    'Stopped prematurely'
end
end