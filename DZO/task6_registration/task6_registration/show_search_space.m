function show_search_space(template_size, search_space)

lw = 2; 

ang1 = search_space.rot(1); 
ang2 = search_space.rot(end);

x1 = search_space.xshift(1); 
x2 = search_space.xshift(end); 

y1 = search_space.yshift(1); 
y2 = search_space.yshift(end); 

t_pars = struct(); 

to_show = {[ang1, x1, y1], 'r',
           [ang2, x2, y1], 'g', 
           [ang1, x1, y2], [.8, .8, 0], 
           [ang2, x2, y2], 'm'}; 

for k = 1:4
    pars = to_show{k, 1}; 
    color_spec = to_show{k, 2}; 
    
    t_pars.rot = pars(1); 
    t_pars.xshift = pars(2); 
    t_pars.yshift = pars(3); 

    show_t_bbox(template_size, t_pars, color_spec, 'linew', lw);
end

