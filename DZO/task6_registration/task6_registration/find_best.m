function [optim_par_idcs, optim_pars, optim_subimage, optim_val] ...
        = find_best(im, template, search_space, xgrid, ygrid, fnc_min)

% subsample template:
[x, y] = meshgrid(xgrid, ygrid); 
template = interp2(template, x, y, 'cubic'); 


optim_val = Inf; 
optim_par_idcs = struct('rot',   [], ...
                        'xshift', [], ...
                        'yshift', [] ); 

optim_pars = struct('rot',   [], ...
                    'xshift', [], ...
                    'yshift', [] ); 

for i_rot = 2:length(search_space.rot)-1
    for i_xshift = 2:length(search_space.xshift)-1
        for i_yshift = 2:length(search_space.yshift)-1

            [x, y] = meshgrid(xgrid, ygrid); 
            [x, y] = t_rot(x, y, search_space.rot(i_rot)); 
            [x, y] = t_trans(x, y, search_space.xshift(i_xshift), ...
                             search_space.yshift(i_yshift));
            
            im_out = interp2(im, x, y, 'cubic'); 
            
            % compute value of optimization criterion 
            % using the provided function handle: 
            val = fnc_min(im_out, template); 
            
            %val
            if optim_val > val 
                optim_val = val; 
                optim_par_idcs.rot = i_rot; 
                optim_par_idcs.xshift = i_xshift; 
                optim_par_idcs.yshift = i_yshift; 
          
                optim_pars.rot = search_space.rot(i_rot); 
                optim_pars.xshift = search_space.xshift(i_xshift); 
                optim_pars.yshift = search_space.yshift(i_yshift); 
                
                optim_subimage = im_out; 
            end        
        end
    end
end
