for obj=1:3
   try
      for view=1:5
         fname = sprintf('obj%d_view%d.mat', obj-student_obj_offset, view-student_view_offset);
         im_fname = sprintf('%s_obj%d_view%d.jpg', username, obj-1, view-1);
	 im = imread(im_fname);
	 if (size(im,3)>1)
	         imgs{obj,view} = rgb2gray(im);
	 else
	         imgs{obj,view} = im;
         end;
         dets{obj,view} = load(fname);
      end;
      tc{obj} = load(sprintf('obj%d_tc.mat', obj-student_obj_offset));
      res{obj} = load(sprintf('obj%d_results.mat', obj-student_obj_offset));
   catch
      fprintf('Missing results?\n');
      fprintf('ERR: %s\n', lasterr);
   end;
end;