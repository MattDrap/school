function [optim_pars, results] = ...
        do_registration(im, template, ...
                        init_ranges, ...
                        init_samples_per_shorter_side, ...
                        fnc_min, ...
                        termination_delta_search_space)

% structure for logging the progress of optimization:
results = struct('optim_pars', cell(1), ...
                 'optim_subimage', cell(1), ...
                 'ranges', cell(1)); 

ranges = init_ranges; 

% keep original images:
orig = struct('im', im, ...
              'template', template); 

shorter_side = min(size(template)); 

% compute delta:
% (delta is equivalent to step size in pixel units)
delta_ = shorter_side/init_samples_per_shorter_side; 

delta = struct('search_space', delta_, ...
               'sampling', delta_); 

template_size = size(template); 

iteration = 0; 

% IMPLEMENT: change the termination condition
while delta.search_space > termination_delta_search_space
    
    iteration = iteration+1; 
    
    sigma = delta_sampling_to_sigma(delta.sampling); 

    % apply low pass filter:
    im = lowpass(orig.im, sigma); 
    template = lowpass(orig.template, sigma); 

    % compute sampling grid: 
    [xgrid, ygrid] = compute_sampling_grid(delta.sampling, template_size);

    % compute search space: 
    search_space = compute_search_space(delta.search_space, ...
                                        template_size, ...
                                        ranges); 
    
    [optim_par_idcs, optim_pars, optim_subimage, optim_val] = ...
        find_best(im, template, search_space, xgrid, ygrid, fnc_min); 
    
    % log the progress to results: 
    results.optim_pars{iteration} = optim_pars; 
    results.optim_subimage{iteration} = optim_subimage; 
    results.ranges{iteration} = ranges; 
    
    % IMPLEMENT: define new ranges to shrink the search space 
%     hdiag = sqrt(sum(template_size.^2))/2; 
%     deltarot = atan2(delta.sampling/2, hdiag)*2;
%     ranges.rot = [optim_pars.rot - deltarot, optim_pars.rot + deltarot];
%     ranges.xshift = [optim_pars.xshift - delta.sampling, optim_pars.xshift + delta.sampling];
%     ranges.yshift = [optim_pars.yshift - delta.sampling, optim_pars.yshift + delta.sampling]; 

    ranges.rot = [search_space.rot(optim_par_idcs.rot - 1), search_space.rot(optim_par_idcs.rot + 1)];
    ranges.xshift = [search_space.xshift(optim_par_idcs.xshift - 1), search_space.xshift(optim_par_idcs.xshift + 1)];
    ranges.yshift = [search_space.yshift(optim_par_idcs.yshift - 1), search_space.yshift(optim_par_idcs.yshift + 1)];
    % halve delta for search space: 
    delta.search_space = delta.search_space/2;
    
    % do the same with delta for sampling but keep 
    % it higher than a constant (here 1.5) to be faster: 
    delta.sampling = max( delta.sampling/2, 1.5); 

end

% done!
