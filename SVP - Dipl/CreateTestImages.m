clear;
close all;

Config;

% MatList = dir('MatFiles');
% for i = 1:size(MatList, 1)
%     tempn = MatList(i);
%     if(~tempn.isdir)
%         load(['MatFiles/' tempn.name]);
%         save(['MetaClouds/' tempn.name], 'metaClouds');
%     end
% end


[tempList, tempNames] = findSubDir(par.data_dir);
par.file_list = tempList;
par.file_dirs = tempNames;

load('MetaClouds/1_25.mat');

files = par.file_list{1};
[GT, GTmask] = ReadSat(files{40}, par);
GT = GT ./ 1e+4;
GT = uint8(GT .* 255);
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

                imwrite(Nimg(:,:, [3 2 1]), sprintf('Thumbnail/1_25_A%1i_H_%i_X%i_Y%i.tif', i, j, xmove, ymove));

                tiffhandle = Tiff(sprintf('Generated/1_25_A%1i_H_%i_X%i_Y%i.tif', i, j, xmove, ymove), 'w');

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
                cloud_map == 
                imwrite(, sprintf('Generated/1_25_A%1i_H_%i_X%i_Y%i_mask.tif', i, j, xmove, ymove))
            end
        end
    end
end