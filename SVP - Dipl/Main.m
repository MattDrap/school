close all;
Config;
%% Prepare Week files
[sceneID,acquisitionDate,sunElevation,sunAzimuth] = ...
    importfile('C:\Users\Matt\Downloads\CVUT\SVP - Dipl\iti_urban_dynamic_landsat_praha_metadata.csv');
[tempList, tempNames] = findSubDir(par.data_dir);
par.file_list = tempList;
par.file_dirs = tempNames;

% for i = 1:size(par.file_list, 2)
%    files = par.file_list{i};
%    for j = 1:size(files, 2)
%        [im, mask]= Sat2Im(files{ j }, par );
%        
%        imshow(im);
%    end
% end
files = par.file_list{1};
[GT, GTmask] = Sat2Im(files{40}, par); %[1, 16] [1, 40], [4, 16], [4, 19], [4, 31]
files = par.file_list{4};
name = files{36};
[IM, IMmask] = Sat2Im(name, par); %25, 26, 27 .. [2, 30], i[3, 5],i[3,6], i[4, 20], i[4, 22], vi[4, 24], b[4, 25, 26, 36, 37], i[4, 29,30, 35], lb[4, 32], cb[4, 33]
mGT = rgb2gray(GT);
mIM = rgb2gray(IM);

mGT = mGT(1:end, 1251:end);
GTmask = GTmask(1:end, 1251:end);
mIM = mIM(1:end, 1251:end);
IMmask = IMmask(1:end, 1251:end);

[folder, name, ext] = fileparts(name);
dot_ind = strfind(name, '.');
dot_unds = strfind(name, '_');

name_orig = name(dot_ind + 1 : dot_unds(1) - 1);

idx = find(strcmp(sceneID, name_orig));

par.sun_elevation = sunElevation(idx(1));
par.sun_azimuth = sunAzimuth(idx(1));

[ metaClouds, metaErrs, GrayGT ] = ApproxClouds( mGT, GTmask, mIM, IMmask, par);
%%
subplot(1, 2, 1);
imshow(GrayGT);
subplot(1, 2, 2);
imshow(mIM);