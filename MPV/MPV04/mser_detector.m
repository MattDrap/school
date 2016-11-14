function [x,y,a11,a12,a21,a22]=mser_detector(img, p);

   if nargin<2
      % provide reasonable defaults
      p.min_margin = 10;
      p.min_size   = 30;
      p.max_area   = 0.1;
   end;
   
   mser = extrema(im2uint8(img), p, [1 2]);
   
   regs=[mser{1}{2,:} mser{2}{2,:}];
   x=[regs.cx]; y=[regs.cy];
   a11=sqrt([regs.sxx]); a12=zeros(size(a11));
   a21=[regs.sxy]./a11;  a22=sqrt([regs.syy] - a21.*a21);
   
   if nargout==1
      % user wants a structure
      x=struct('x',num2cell(x),'y',num2cell(y),'a11',num2cell(a11),'a12',num2cell(a12),'a21',num2cell(a21),'a22', ...
               num2cell(a22));
   end;