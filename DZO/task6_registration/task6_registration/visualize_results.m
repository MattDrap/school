function visualize_results(results, k, im, template, gt)

% illustrate ranges by showing 4 representative transformations
% (see show_search_space for details) 
template_size = size(template); 

ranges = results.ranges{k}; 
figure(1); 
imagesc(im); axis equal 
hold on
show_search_space(template_size, ranges)
hold off
title(sprintf('search space illustration (it. %i)', k))

% show the best transformation: 
optim_pars = results.optim_pars{k};
figure(2)
imagesc(im); axis equal; 
hold on; 
h1 = show_t_bbox(template_size, gt, 'g', 'linew', 2); 
h2 = show_t_bbox(template_size, optim_pars, 'r', 'linew', 2, 'linest', '--'); 
legend([h1, h2], 'ground truth', sprintf('optimal (it. %i)', k) );
hold off; 

% show the subimage 
% obtained by the algorithm (at resolution given by k)
optim_subimage = results.optim_subimage{k}; 
figure(3)
imagesc(optim_subimage); axis equal; 
title(['optimal subimage at sampling resolution of iteration ', num2str(k)]);

% sample the subimage directly from the target image 
% at its native resolution
target_subimage = sample_from_im(im, template_size, optim_pars);
figure(4); 
im_comparison = im2rg(target_subimage, template); 
imagesc(im_comparison); axis equal; 
title(['template (red) and optimal subimage (green) at iteration ', ...
      num2str(k)])
