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

all_clouds_names = {'1_25', '1_26', '1_27','2_30','3_5_E','3_6_E','4_25', ...
    '4_26', '4_29', '4_36', '4_37'};

for clouds_name_index = 1:length(all_clouds_names)
    clouds_name = all_clouds_names{clouds_name_index};
    load(sprintf('MetaClouds/%s.mat', clouds_name));

    files = par.file_list{1};
    [GT, GTmask] = ReadSat(files{40}, par);
    GT = GT ./ 1e+4;
    GT = uint8(GT .* 255);

    [sceneID,acquisitionDate,sunElevation,sunAzimuth] = importfile(par.metadata_path);
    min_sun_elevation = min(sunElevation);
    max_sun_elevation = max(sunElevation);
    min_sun_azimuth = min(sunAzimuth);
    max_sun_azimuth = max(sunAzimuth);

    par.sun_elevation = (max_sun_elevation - min_sun_elevation) * rand(1,1) + min_sun_elevation;
    par.sun_azimuth = (max_sun_azimuth - min_sun_azimuth) * rand(1,1) + min_sun_azimuth;

    generation_method = 2;

    if generation_method == 1
        xvals = [metaClouds{:, 1}];
        yvals = [metaClouds{:, 2}];
        k = floor( size(metaClouds, 1) / 45 );
        fprintf('Performing kmeans with %i centers\n', k);
        [idx, C] = kmeans([xvals', yvals'], k);
        %K means generated
        for test = 1:20
            fprintf('Creating %i. image\n', test);
            txvals = xvals;
            tyvals = yvals;
            picks = 1:k;
            for i = picks
                apx = randi([-500, 500], 1);
                txvals(idx == i) = txvals(idx == i) + apx;
                apy = randi([-500, 500], 1);
                tyvals(idx == i) = tyvals(idx == i) + apy;
            end
            Clouds = metaClouds;
            Clouds(:, 1) = num2cell(txvals');
            Clouds(:, 2) = num2cell(tyvals');

            [Nimg, cloud_map, shadow_map] = GenCloudImagePatchedBitmap(GT, Clouds, par);

            fprintf('Saving %i. image\n', test);

            mask = GTmask;
            mask(mask == 1) = 0;
            mask(mask == 2) = 0;
            s_mask = shadow_map(:, :, 1) > 0;
            mask(s_mask) = 1;
            c_mask = cloud_map(:, :, 1) > 0;
            mask(c_mask) = 2;
            imwrite(mask, sprintf('Generated/%s_kmeansN2%i_mask.tif', clouds_name, test))

            WriteTiff(sprintf('Generated/%s_kmeansN2%i.tif', clouds_name, test), Nimg)

            imwrite(Nimg(:,:, [3 2 1]), sprintf('Thumbnail/%s_kmeansN2%i.tif',clouds_name, test));
        end
    elseif generation_method == 2
    %Another option
        for xmove = -500:100:500
            for ymove = -500:100:500
                Clouds = metaClouds;
                Clouds(:, 1) = cellfun(@(x) x + xmove, Clouds(:, 1),'un',0);
                Clouds(:, 2) = cellfun(@(x) x + ymove, Clouds(:, 2),'un',0);

                [Nimg, cloud_map, shadow_map] = GenCloudImagePatchedBitmap(GT, Clouds, par);
                %%
                %Write Thumbnail
                imwrite(Nimg(:,:, [3 2 1]), sprintf('Thumbnail/%s_X%i_Y%i.tif',clouds_name, xmove, ymove));
                %%
                %Write multi(6)-channel Tiff
                WriteTiff(sprintf('Generated/%s_X%i_Y%i.tif',clouds_name, xmove, ymove), Nimg);
                %%
                %Mask
                mask = GTmask;
                mask(mask == 1) = 0;
                mask(mask == 2) = 0;
                s_mask = shadow_map(:, :, 1) > 0;
                mask(s_mask) = 1;
                c_mask = cloud_map(:, :, 1) > 0;
                mask(c_mask) = 2;
                imwrite(mask, sprintf('Generated/%s_X%i_Y%i_mask.tif',clouds_name, xmove, ymove))
            end
        end
    end
end