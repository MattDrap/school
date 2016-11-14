function pts=dd(im);

p.min_margin = 10;
p.min_size   = 30;
mser = extrema(im2uint8(im), p, [1 2]);

regs=[mser{1}{2,:} mser{2}{2,:}];
x=[regs.cx]; y=[regs.cy];
a11=sqrt([regs.sxx]); a12=zeros(size(a11));
a21=[regs.sxy]./a11;  a22=sqrt([regs.syy] - a21.*a21);
% imshow(img); showpts([x;y;a11;a12;a21;a22]);

opt.ps=41; opt.ext=2; pts=affnorm(im, x,y,a11,a12,a21,a22, opt);
