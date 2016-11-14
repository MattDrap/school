function [ best_radius, best_density ] = MinimizeMetaball( probGT, probIm, center, initDensity, par  )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

best_radius = [];
best_density = [];

r = par.init_radius;
d = initDensity;
d_step = 0.05;

base_err = OptimizeMetaball( probGT, probIm, r, d, center, par );

for i  = 1:par.max_iter_opt
    err1 = OptimizeMetaball( probGT, probIm, r - 1, d, center, par );
    err2 = OptimizeMetaball( probGT, probIm, r + 1, d, center, par );
    
    err3 = OptimizeMetaball( probGT, probIm, r, d - d_step, center, par );
    err4 = OptimizeMetaball( probGT, probIm, r, d + d_step, center, par );
    
    err = [err1, err2, err3, err4];

    [val, ind] = min(err);

    if val >= base_err
        best_radius = r;
        best_density = d;
        break;
    else
        switch(ind)
            case 1
                r = r - 1;
            case 2
                r = r + 1;
            case 3
                d = d - d_step;
            case 4
                d = d + d_step;
        end
        if d < 1e-8
           best_density = 0;
           best_radius = Inf;
           break;
        end
        if d > initDensity
            best_radius = r;
            best_density = initDensity;
            break;
        end
        
        if r > par.max_radius
            best_radius = par.max_radius;
            best_density = d;
        end
        base_err = val;
    end
end

if isempty(best_radius)
    best_radius = r;
    best_density = d;
end

end