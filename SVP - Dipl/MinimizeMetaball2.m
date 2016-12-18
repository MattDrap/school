function [ best_err, best_density ] = MinimizeMetaball2( probGT, probIm, center, initDensity, radius, par  )
best_density = 0;

d = initDensity;
DDim = size(d, 2);
d_step = 0.5;
previous = 0;
best_err = OptimizeMetaball( probGT, probIm, radius, d, center, par );
added_momentum = false;
for i  = 1:par.max_iter_opt
    errs = Inf * ones(2, 1);
    td = d;
    td = td + repmat(d_step, 1, DDim);
    errs(1) = OptimizeMetaball( probGT, probIm, radius, td, center, par );
    %
    td = d;
    td = td - repmat(d_step, 1, DDim);
    errs(2) = OptimizeMetaball( probGT, probIm, radius, td, center, par );

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
        p = mod(ind, 2); %plus - 1 / minus - 0
        if(p)
            d = d + repmat(d_step, 1, DDim);
        else
            d = d - repmat(d_step, 1, DDim);
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