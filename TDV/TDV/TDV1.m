list = dir('./Data');
list_dirs = {list.isdir};
list_names = {list.name};
image_names = list_names(cellfun(@(p) p ~= true, list_dirs));
%Computing image descriptors
for i = 1:length(image_names)
    fprintf('Reading %d-th image %n', i);
    im = imread(['./Data/' image_names{i}]);
    imr = undistortImage(im,cameraParams);
    imshow(imr);
    filename = sprintf('%d.jpg', i);
    imwrite(imr, filename);
end