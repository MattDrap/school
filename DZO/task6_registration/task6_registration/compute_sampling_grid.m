function [xgrid, ygrid] = compute_sampling_grid(delta_sampling, template_size)


will_fit = floor( (template_size-1)/delta_sampling ); 
start_at = 1+(template_size-1 - will_fit*delta_sampling)/2; 
xgrid = start_at(2):delta_sampling:template_size(2); 
ygrid = start_at(1):delta_sampling:template_size(1);


