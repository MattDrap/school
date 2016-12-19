close all;
clear;

Config;
%% Prepare Week files
[tempList, tempNames] = findSubDir(par.data_dir);
par.file_list = tempList;
par.file_dirs = tempNames;

% for i = 1:size(par.file_list, 2)
%    files = par.file_list{i};
%    for j = 1:size(files, 2)
%        [im, mask]= Sat2Im(files{ j }, par );
%        
%        imshow(im(:, :, [3,2,1]));
%    end
% end

files = par.file_list{1};
%[GT, GTmask] = Sat2Im(files{40}, par); %[1, 16] [1, 40], [4, 16], [4, 19], [4, 31]
[GT, GTmask] = ReadSat(files{40}, par);
GT = GT ./ 1e+4;
GT = uint8(GT .* 255);

files = par.file_list{1};
name = files{25};
%[IM, IMmask] = Sat2Im(name, par); %25, 26, 27 .. [2, 30], i[3, 5],i[3,6], i[4, 20], i[4, 22], vi[4, 24], b[4, 25, 26, 36, 37], i[4, 29,30, 35], lb[4, 32], cb[4, 33]
[IM, IMmask] = ReadSat(name, par);
IM = IM./1e+4;
IM = uint8(IM .* 255);

mGT = GT;
GTmask = GTmask;
mIM = IM;
IMmask = IMmask;

[par.sun_elevation, par.sun_azimuth] = FindMetadataByFilename(name, par);

if ~par.parallel
    [ metaClouds, metaErrs, GrayGT, lowClouds ] = ApproxClouds( mGT, ...
            GTmask, mIM, IMmask, par);
else
    sc = sum(IMmask, 2);
    sr = sum(IMmask);
    allsum = sum(sc);
    cmsc = cumsum(sc);
    cmsr = cumsum(sr);
    
    half = allsum / 2;
    
    cind = find(cmsc < half, 1, 'last');
    rind = find(cmsr < half, 1, 'last');
    
    [H,W,C] = size(mGT);
    
    startx = [1, cind+1, 1, cind +1];
    endx = [cind, W, cind,  W];
    starty = [1, 1, rind + 1, rind + 1];
    endy = [rind, rind, H, H];
    
    mGTslice = cell(4, 1);
    mGTmaskslice = cell(4, 1);
    mIMslice = cell(4, 1);
    mIMmaskslice = cell(4, 1);
    parpool(4);
    for i = 1:4
        mGTslice{i} = mGT(starty(i):endy(i), startx(i):endx(i), :);
        mGTmaskslice{i} = GTmask(starty(i):endy(i), startx(i):endx(i));
        mIMslice{i} = mIM(starty(i):endy(i), startx(i):endx(i), :);
        mIMmaskslice{i} = IMmask(starty(i):endy(i), startx(i):endx(i));
    end
    parfor i = 1:4
        [ metaClouds, metaErrs, GrayGT{i}, lowClouds{i} ] = ApproxClouds( mGTslice{i}, ...
            mGTmaskslice{i}, ...
            mIMslice{i}, ...
            mIMmaskslice{i}, par);
    end
end
%%
figure;
subplot(1, 3, 1);
imshow(GrayGT(:, :, [3 2 1]));
title('MetaBalls');
subplot(1, 3, 2);
bitmapped = GrayGT + lowClouds;
imshow(bitmapped(:, :, [3, 2 1]));
title('MetaBalls and residual 2D bitmap');
subplot(1, 3, 3);
imshow(mIM(:, :, [3 2 1]));
title('Original image');
%%
% figure;
% subplot(1, 3, 1);
% imshow(GrayGT(:, :, :));
% subplot(1, 3, 2)
% faked = GrayGT + lowClouds;
% imshow(faked(:, :, :));
% subplot(1, 3, 3);
% imshow(mIM(:, :, [3 2 1]));