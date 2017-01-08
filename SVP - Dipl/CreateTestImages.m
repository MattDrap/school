clear;
close all;

Config;

% metaClouds = {};
% MatList = dir('MetaClouds');
%  for i = 1:size(MatList, 1)
%      tempn = MatList(i);
%      if(~tempn.isdir)
%          m = load(['MetaClouds/' tempn.name]);
%          %metaClouds = [metaClouds; m.metaClouds];
%          %save(['MetaClouds/' tempn.name], 'metaClouds');
%      end
%  end
% save('AllClouds.mat', 'metaClouds');


[tempList, tempNames] = findSubDir(par.data_dir);
par.file_list = tempList;
par.file_dirs = tempNames;

clouds_name = '4_25';
load(sprintf('MetaClouds/%s.mat', clouds_name));

files = par.file_list{1};
[GT, GTmask] = ReadSat(files{40}, par);
GT = GT ./ 1e+4;
GT = uint8(GT .* 255);

%load('AllClouds.mat');

xvals = [metaClouds{:, 1}];
yvals = [metaClouds{:, 2}];
k = floor( size(metaClouds, 1) / 35 );
fprintf('Performing kmeans with %i centers\n', k);
[idx, C] = kmeans([xvals', yvals'], k);
%load('AllCloudsIdx.mat');
%K means generated
for test = 1:1
    fprintf('Creating %i. image\n', test);
    txvals = xvals;
    tyvals = yvals;
    picks = 1:k;
    %picks = randi([1,k], 1, 400);
    for i = picks
        apx = randi([-500, 500], 1);
        txvals(idx == i) = txvals(idx == i) + apx;
        apy = randi([-500, 500], 1);
        tyvals(idx == i) = tyvals(idx == i) + apy;
    end
    Clouds = metaClouds;
    Clouds(:, 1) = num2cell(txvals');
    Clouds(:, 2) = num2cell(tyvals');
    
    %Clouds2 = {};
    %for i = picks
    %    Clouds2 = [Clouds2; Clouds(idx == i, :)];
    %end
    [Nimg, cloud_map, shadow_map] = GenCloudImagePatchedBitmap(GT, Clouds, par);
    fprintf('Saving %i. image\n', test);
    imwrite(Nimg(:,:, [3 2 1]), sprintf('Thumbnail/%s_kmeans%i.tif',clouds_name, test));
end
%Another option
for xmove = -100:100:100
    for ymove = -100:100:100
        Clouds = metaClouds;
        Clouds(:, 1) = cellfun(@(x) x + xmove, Clouds(:, 1),'un',0);
        Clouds(:, 2) = cellfun(@(x) x + ymove, Clouds(:, 2),'un',0);
        for i = 0:30:359
            for j=15:10:35
                par.sun_azimuth = i;
                par.cloud_height_min = j;
                par.cloud_height_max = j + 10;
                [Nimg, cloud_map, shadow_map] = GenCloudImagePatchedBitmap(GT, Clouds, par);
                %%
                %Write Thumbnail
                imwrite(Nimg(:,:, [3 2 1]), sprintf('Thumbnail/%s_A%1i_H_%i_X%i_Y%i.tif',clouds_name, i, j, xmove, ymove));
                %%
                %Write multi(6)-channel Tiff
                tiffhandle = Tiff(sprintf('Generated/%s_A%1i_H_%i_X%i_Y%i.tif',clouds_name, i, j, xmove, ymove), 'w');

                tagstruct.BitsPerSample = 8;
                tagstruct.Compression = Tiff.Compression.LZW;
                tagstruct.Orientation = 1;
                tagstruct.Photometric = Tiff.Photometric.MinIsBlack;

                tagstruct.ImageLength = size(Nimg,1);
                tagstruct.ImageWidth = size(Nimg,2);
                tagstruct.SamplesPerPixel = size(Nimg, 3);
                tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
                tiffhandle.setTag(tagstruct);

                tiffhandle.write(Nimg);
                tiffhandle.close();
                %%
                %Mask
                mask = GTmask;
                s_mask = shadow_map(:, :, 1) > 0;
                mask(s_mask) = 1;
                c_mask = cloud_map(:, :, 1) > 0;
                mask(c_mask) = 2;
                imwrite(mask, sprintf('Generated/%s_A%1i_H_%i_X%i_Y%i_mask.tif',clouds_name, i, j, xmove, ymove))
            end
        end
    end
end