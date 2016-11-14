im = imread('jay.jpg'); 
im = double(mean(im, 3))/255; 

% Create template. 
% first, create the grid: 
[x, y] = meshgrid(1:420, 1:400); 
% rotate: 
angle = 3.75/180*pi; 
[x, y] = t_rot(x, y, angle); 
% translate: 
xshift = 547.7; 
yshift = 201.2; 
[x, y] = t_trans(x, y, xshift, yshift);

template = interp2(im, x, y, 'cubic'); 

% define search space boundaries:
init_ranges = struct('rot',   [-10, 10]/180*pi, ...
                     'xshift', [500, 590], ...
                     'yshift', [150, 240] ); 

% store the ground truth transformation parameters for later
% reference:
gt = struct(); 
gt.rot = angle; 
gt.xshift = xshift; 
gt.yshift = yshift; 

% how many samples to use when evaluating the similarity:
init_samples_per_shorter_side = 30; 

% neg. similarity function to minimize: 
fnc_min = @sum_of_squares; 

% termination criterion (when lower than): 
termination_delta_search_space = 0.05; 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% registration itself
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[optim_pars, results] = do_registration(im, template, ...
                        init_ranges, ...
                        init_samples_per_shorter_side, ...
                        fnc_min, ...
                        termination_delta_search_space); 

template_size = size(template); 
target_subimage = sample_from_im(im, template_size, optim_pars);

% show results:
visualize_results(results, iteration, im, template, gt); 




