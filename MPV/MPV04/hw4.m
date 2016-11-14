close all;

set_of_images = 1;
images = cell(5, 1);

detpar.type = 'sshessian';
detpar.threshold = 0.008;

%detpar.type='mser';
%detpar.min_margin = 20; % pozadovana stabilita
%detpar.min_size = 8;   % velikost nejmensi oblasti v pixlech
%detpar.max_area = 0.4;   % procento/100 plochy nejvetsi detekovane oblasti (v rozsahu 0 az 1).

descpar.type = 'dct';
descpar.ps = 10;
descpar.ext = 10;
descpar.num_coeffs = 10;

for i = 1:5
    im1 = im2double(imread(['obj' int2str(set_of_images) '_view' int2str(i-1) '.jpg']));
    im1 = rgb2gray(im1);
    images{i} = im1;
end

%%
spts = cell(5, 1);
for i = 1:numel(images)
    pts = detect_and_describe(images{i}, detpar, descpar);
    str = [];
    save(sprintf('obj%d_view%d.mat', set_of_images,i-1), 'pts', 'detpar', 'descpar');
    spts{i} = pts;
end
sprintf('features found');
par.threshold=inf;
par.method='mutual';

TC = cell(5,5);
for i = 1:5
    for j = i+1:5
        TC{ i , j } =match(spts{i}, spts{j}, par);
    end
end
save(sprintf('obj%d_tc.mat', set_of_images), 'par', 'TC');
sprintf('matches found');
%%
inlH = cell(5,5);
inlF = cell(5,5);
H = cell(5,5);
F = cell(5,5);
thresh_h = 5;
thresh_f = 5;
conf_h = 0.99;
conf_f = 0.99;
for i = 1:5
    for j = i+1:5
        u = corr2u(spts{i}, spts{j}, TC{i , j});
        
        [mH, minlH]=ransac_h(u, thresh_h, conf_h);
        mH = mH./mH(3,3);
        H{i,j} = mH;
        inlH{i,j} = minlH;
        
        [mF, minlF]=ransac_f(u, thresh_f, conf_f);
        mF = mF./mF(3,3);
        F{i,j} = mF;
        inlF{i,j} = minlF;
        
        showcorrs(images{i}, images{j}, u, minlH)
    end
end
save(sprintf('obj%d_results.mat', set_of_images), 'thresh_h', 'thresh_f', 'conf_h', 'conf_f', 'inlH', 'inlF', 'H', 'F');