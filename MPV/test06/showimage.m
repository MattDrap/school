function showimage(id, NAMES, opt)
% show image
   
   fname = fullfile(opt.root_dir, NAMES{id});
   im = imread(fname);
   imshow(im);
   