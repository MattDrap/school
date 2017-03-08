%%
list = dir('../IMG_D');
cfg  = wbs_default_cfg;
list_dirs = {list.isdir};
list_names = {list.name};
image_names = list_names(cellfun(@(p) p ~= true, list_dirs));

UAll = cell(length(image_names), 1);
for i = 1:length(image_names)
    pts1 = load([image_names{i}(1:end - 3) 'mat']);
    x = cell2mat( {pts1.pts.x} );
    y = cell2mat( {pts1.pts.y} );
        UAll{i} = [x;y];
       save('UAll.mat', 'UAll');
end