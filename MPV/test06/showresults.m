function showresults(relevant, scores, A, bbx, opt, NAMES)
% visualise results of querysp
   if (nargin<6)
      NAMES = evalin('base', 'NAMES');
   end; 
   
   len = numel(relevant);

   if isfield(opt, 'subplot')
      % screen proportions (assumes maximized figure)
      size_cols = 1200;
      size_rows = 1920;
      cols = round(sqrt(len*size_cols/size_rows));
      rows = ceil(len/cols);
      figure;
   end;
   
   for i=1:len
      fname = fullfile(opt.root_dir, sprintf('%s.jpg', NAMES{relevant(i)}));
      im = imread(fname);
      if (isfield(opt, 'subplot') & opt.subplot) subplot(rows,cols,i); else figure; end;
      imagesc(im); axis image; axis off;
      showbbx(bbx, A(:,:,i));
      title(sprintf('Score: %f', scores(i)));
   end;
   