clear all;
close all;
clc;
run('../stprtool/stprpath.m');
[Data, y] = generate_data(100, 100);
%%
%%create classifiers
for i = 1:length(Data)
    r = 3;
    angles = 0:5:179;
    NX = zeros(size(angles));
    NY = zeros(size(angles));
    run = 1;
    for j = angles
        rad = j*pi/180;
        NX(run) = r*cos(rad) + Data(1, i);
        NY(run) = r*sin(rad) + Data(2, i);
        run = run + 1;
    end
end

%%

num_steps = 30;
[strong_class wc_error upper_bound] = adaboost(Data, y, num_steps);

figure;
show_data(Data, y);

[Xtst, y] = generate_data(200, 200);

yab = adaboost_classify(strong_class, Xtst);

%showclassif(strong_class);

vis_boundary(Xtst, y, yab);