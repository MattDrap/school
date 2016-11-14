im = imread('jay.jpg'); 
im_red = double(im(:,:,1))/256; 
im_blue = double(im(:,:,3))/256;

im_mod = 4*mod(im_blue, .25); 

% target image:
im = im_red; 

% sample subimage: 
% first, create the sampling grid: 
[x, y] = meshgrid(1:420, 1:400); 
% rotate: 
angle = 3.75/180*pi; 
[x, y] = t_rot(x, y, angle); 
% translate: 
xshift = 520.5; 
yshift = 201.2; 
[x, y] = t_trans(x, y, xshift, yshift);

% template image: 
template = interp2(im_mod, x, y, 'cubic'); 

% define search space boundaries:
init_ranges = struct('rot',   [-10, 10]/180*pi, ...
                     'xshift', [500, 590], ...
                     'yshift', [150, 240] ); 

init_samples_per_shorter_side = 30; 

%fnc_min = @sum_of_squares; 
fnc_min = @mutual_information; 

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
