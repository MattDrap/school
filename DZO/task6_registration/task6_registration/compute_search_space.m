function search_space = compute_search_space(delta_search_space, ...
                                             template_size, ranges)

% ===========================
% Compute step sizes 
% ===========================
steps = struct('rot',   [], ...
               'xshift', [], ...
               'yshift', [] ); 

d = delta_search_space;

%  size of diagonal of the template (half of it): 
hdiag = sqrt(sum(template_size.^2))/2; 
% step in rotation (in radians):
steps.rot = atan2(d/2, hdiag)*2;

% translation: 
steps.xshift = d; 
steps.yshift = d; 

search_space = struct('rot',   [], ...
                      'xshift', [], ...
                      'yshift', [] ); 

% use steps and an additional constraint that there must be at
% least 5 points in each dimension. 

search_space.rot = linspace( ranges.rot(1), ranges.rot(2), ...
                             max(5, number_of_steps(ranges.rot, steps.rot)));

search_space.xshift = linspace( ranges.xshift(1), ranges.xshift(2), ...
                             max(5, number_of_steps(ranges.xshift, steps.xshift)));

search_space.yshift = linspace( ranges.yshift(1), ranges.yshift(2), ...
                             max(5, number_of_steps(ranges.yshift, steps.yshift)));



function n = number_of_steps(range, step) 

n = ceil( (range(2) - range(1))/step + 1 );


