function [ best_radius, best_density ] = MinimizeMetaball( probGT, probIm, center, initDensity, par  )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

best_radius = [];
best_density = [];

r = par.init_radius;
d = initDensity;
d_step = 0.5;
r_step = 1;
previous = 0;
base_err = OptimizeMetaball( probGT, probIm, r, d, center, par );

for i  = 1:par.max_iter_opt
    %if previous ~= 2
    err1 = OptimizeMetaball( probGT, probIm, r + r_step, d, center, par );
    err2 = OptimizeMetaball( probGT, probIm, r - r_step, d, center, par );
    
    err3 = OptimizeMetaball( probGT, probIm, r, d + d_step, center, par );
    err4 = OptimizeMetaball( probGT, probIm, r, d - d_step, center, par );
    
    err = [err1, err2, err3, err4];

    [val, ind] = min(err);
    
    if val >= base_err
        best_radius = r;
        best_density = d;
        break;
    else
        switch(ind)
            case 1
                r = r + r_step;
            case 2
                r = r - r_step;
            case 3
                d = d + d_step;
            case 4
                d = d - d_step;
        end
        
%          %%Momentum
%         if previous == ind
%             if previous <= 2
%                r_step = r_step * 2; 
%             elseif previous > 2
%                d_step = d_step * 2;
%             end
%         elseif previous ~= 0
%             if previous <= 2
%                r_step = r_step / 2; 
%             elseif previous > 2
%                d_step = d_step / 2;
%             end
%         end
%         %
        
        %%Ending conditions
        if d < 1e-8 || r < 1e-8
           best_density = 0;
           best_radius = Inf;
           break;
        end
        if d > initDensity
            best_radius = r;
            best_density = initDensity;
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