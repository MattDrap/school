img = im2double(imread('grad.png'));
img = rgb2gray(img);
%%
angle = dom_orientation(img);

x = [100, 200];
y = [100, 200];
opt.ps = 10;
opt.ext = 5;
pts=transnorm(img,x,y,5,opt);
ptsn = photonorm(pts);
desc = dctdesc(ptsn(1).patch, 10);