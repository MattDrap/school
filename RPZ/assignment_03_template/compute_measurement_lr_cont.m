function x = compute_measurement_lr_cont(imgs)

width = size(imgs(:,:,1), 2);

sumRows = sum(double(imgs));
x = sum(sumRows(1,1:(width/2),:)) - sum(sumRows(1,(width/2+1):width,:));
x = reshape(x,1,size(imgs,3));
