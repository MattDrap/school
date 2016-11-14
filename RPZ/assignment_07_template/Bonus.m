clear all;
close all;
clc;
run('../stprtool/stprpath.m');
load('data_mnist_trn.mat');
classes = unique(y);
N = max(classes) + 1;
svns = {};
[y, idc] = sort(y);
X = X(:, idc);
classessNum = zeros(N,1);
for i = 1:N
    classessNum(i) = sum(y == i-1);
end
NX = [];
tX = [];
ny = [];
ty = [];
portion = 10;
for i=1:N
    in = find(y == i-1);
    ny = [ny; y(in(1:classessNum(i)/portion))];
    NX = [NX , X(:, in(1:classessNum(i)/portion))];
    
    tt = in(int16(classessNum(i)/portion) + 1):in(2*int16(classessNum(i)/portion));
    ty = [ty; y(tt)];
    tX = [tX, X(:, tt)];
end
ny = ny';
for i = 1:N
    options.tmax = 100000;
    my = double(ny == i-1);
    my(my == 0) = -1;
    [w,b,sv_idx] = my_svm(NX,my,5, options);
    model.w = w;
    model.b = b;
    model.sv_idx = sv_idx;
    svns{i} = model;
end
classified = zeros(N, size(tX, 2));
for j = 1:N
    model = svns{j};
    classified(j, :) = model.w' * tX + model.b;
end
[m, ind] = max(classified);
%%
for j = 1:N
    figure;
    title('classified');
    VX = tX(:, ind == j);
    VN = reshape(VX, [imsize, size(VX, 2)]);
    for k = 1:size(VN, 3)
        VN(:,:, k) = VN(:,:,k)';
    end
    montage(permute(VN, [1 2 4 3])), title(classes(j));
end