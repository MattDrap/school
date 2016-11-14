function im_out = sample_from_im(im, template_size, t_pars)

[x, y] = meshgrid(1:template_size(2), 1:template_size(1)); 
[x, y] = t_rot(x, y, t_pars.rot); 
[x, y] = t_trans(x, y, t_pars.xshift, t_pars.yshift);

im_out = interp2(im, x, y, 'cubic'); 
