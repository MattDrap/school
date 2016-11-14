function h = show_t_bbox(template_size, t_pars, color_spec, varargin)

[x, y] = meshgrid(1:template_size(2), 1:template_size(1)); 
[x, y] = t_rot(x, y, t_pars.rot); 
[x, y] = t_trans(x, y, t_pars.xshift, t_pars.yshift);

rectangle_x = [x(1,1), x(1, end), x(end, end), x(end, 1), x(1, 1)]; 
rectangle_y = [y(1,1), y(1, end), y(end, end), y(end, 1), y(1, 1)]; 
h = plot(rectangle_x, rectangle_y, 'color', color_spec, varargin{:}); 
plot(x(1, 1), y(1, 1), 'o', 'color', color_spec, varargin{:}); 

