searchExpression = 'fmask.tif';
addpath('../../');
files = dir();
for i = 3:length(files)
    if files(i).isdir
        inner_files = dir(files(i).name);
        inner_names = {inner_files.name};
        
        for j = 3:size(inner_files, 1)
            if ~isempty(regexp(inner_names{j},searchExpression,'match'))
                
                mask = uint8(imread([files(i).name ,'/' ,inner_names{j} ]));
                
                key_name = strsplit(inner_names{j}, '_');
                key_name = char(key_name(2));
                
                ind1 = find(mask(:) == 255, 1, 'first');
                ind2 = find(mask(:) == 255, 1, 'last');

                [indr1, indc1] = ind2sub(size(mask), ind1);
                [indr2, indc2] = ind2sub(size(mask), ind2);

                new_mask = mask(indr1:indr2, indc1:indc2);                
                iter = 1;    
                nmap = uint16([]);
                fprintf('%s\n',inner_names{j});
                for k = 3:size(inner_files, 1)  
                    if k ~= j && ~isempty(regexp(inner_names{k}, [key_name '.*.tif'],'match'))
                        
                        fprintf('%s\n',inner_names{k});
                        map = imread([files(i).name ,'/' ,inner_names{k} ]);
                        map = map(indr1:indr2, indc1:indc2);
                        
                        nmap(:, :, iter) = uint16(map);
                        iter = iter + 1;
                    end
                end
                fprintf('saving \n');
                savename = sprintf('../sensorsProcessed/%s/czdata.%s.tif', files(i).name, key_name);
                savenamemask = sprintf('../sensorsProcessed/%s/fmask.%s.tif', files(i).name, key_name);
                WriteTiff(savename, nmap, 16);
                imwrite(new_mask, savenamemask);
            end
        end
    end
end