clear;
close all;

N = 200; % divisible by 2

mu1 = 152;
sig1 = 9;
mu2 = 178;
sig2 = 10;

girls = mu1 + sig1 .* randn(N/2, 1);
boys = mu2 + sig2 .*randn(N/2, 1);

orig_data = [boys; girls];
labels = [1 * ones(N/2, 1); 2 * ones(N/2, 1)];

[bins, centers] = hist(orig_data);
bins = bins ./ sum(bins);
d = mean( centers(2:end) - centers(1:end-1) );

binsdensity = bins ./ d;
[all, ind] = sort(orig_data);
%1]
figure;
hold on;
bar(centers, binsdensity);
pdf = normpdf(all, mean(all), std(all));
% f = p_1 * x1 + p_2 * x2;
% var = E<x^2> - (E<x>)^2;
% E<x_i^2> = var_i + (E<x_i>)^2
% var = p_1 * var_1 + p_2 * var2 + p_1 * mu1^2 + p_2 * mu2^2 -( p_1 *
% mu1)^2 - (p_2 * mu2^2)
gvar = 0.5* sig1^2 + 0.5 * sig2^2 + 0.5*mu1^2 + 0.5*mu2^2 - (0.5*mu1 + 0.5*mu2)^2;
gstd = sqrt(gvar);

pdf2 = normpdf(all, 0.5 * (mu1 + mu2), gstd);
estpdf = plot(all, pdf, 'g');
thpdf = plot(all, pdf2, 'r');
legend([estpdf, thpdf],'Estimated PDF', 'Theoretical PDF');

%%
%2]
[emean, estd, epg] = EM(all, 2);
figure;
hold on;
bar(centers, binsdensity);
eg1 = normpdf(all, emean(1), estd(1));
eg2 = normpdf(all, emean(2), estd(2));

tg1 = normpdf(all, mu1, sig1);
tg2 = normpdf(all, mu2, sig2);

plot(all, epg(1).*eg1 + epg(2).*eg2, 'g');
plot(all, 0.5 .* tg1 + 0.5 .* tg2, 'r');
%2b]
figure;
hold on;
bar(centers, binsdensity);
plot(all, epg(1).*eg1, 'g');
plot(all, epg(2).*eg2, 'g');
plot(all, 0.5 .* tg1, 'r');
plot(all, 0.5 .* tg2, 'r');

%2ca]
percentage = [0.1, 0.2, 0.5];
for i = 1:3    
    
    stratified = 0;
    
    if ~stratified
        p = randperm(N);
        permuted = orig_data(p, :);
        plabels = labels(p);
        
        train_dataN = floor(percentage(i) * N);
        train_data = permuted(1:train_dataN, :);
        train_labels = plabels(1:train_dataN, :);

        test_data = permuted(train_dataN+1:end, :);
        test_labels = plabels(train_dataN+1:end, :);
    else
        p1 = randperm(N/2);
        permutedboys = boys(p1, :);
        permutedgirls = girls(p1, :);
        
        pboyslabels = ones(N/2, 1);
        pgirlslabels = 2 * ones(N/2, 1);
        
        train_dataN = floor(percentage(i) * N/2);
        train_data = [permutedboys(1:train_dataN, :); permutedgirls(1:train_dataN)];
        train_labels = [pboyslabels(1:train_dataN, :); pgirlslabels( 1:train_dataN, :)];
        test_data = [permutedboys(train_dataN+1:end, :); permutedgirls(train_dataN+1:end)];
        test_labels = [pboyslabels(train_dataN+1:end, :); pgirlslabels(train_dataN+1:end, :)];
    end
   
    nmu1 = mean(train_data(train_labels == 1));
    nmu2 = mean(train_data(train_labels == 2));
    nstd1 = std(train_data(train_labels == 1));
    nstd2 = std(train_data(train_labels == 2));
    
    estpdf1 = normpdf(all, nmu1, nstd1);
    estpdf2 = normpdf(all, nmu2, nstd2);
    
    estclassifier = zeros(size(test_data, 1), 1);
    testpdf1 = normpdf(test_data, nmu1, nstd1);
    testpdf2 = normpdf(test_data, nmu2, nstd2);
    estclassifier(testpdf1 > testpdf2) = 1;
    estclassifier(testpdf1 < testpdf2) = 2;
    %%
    emdata = [train_data; test_data];
    emlabels = [train_labels; test_labels == Inf];
    [nemmean, nemstd, nempg] = EM(emdata, 2, emlabels);
    
    nempdf1 = normpdf(all, nemmean(1), nemstd(1));
    nempdf2 = normpdf(all, nemmean(2), nemstd(2));
    
    emclassifier = zeros(size(test_data, 1), 1);
    testpdf1 = normpdf(test_data, nemmean(1), nemstd(1));
    testpdf2 = normpdf(test_data, nemmean(2), nemstd(2));
    emclassifier(testpdf1 > testpdf2) = 1;
    emclassifier(testpdf1 < testpdf2) = 2;
    %%
    %preplot 1
    figure;
    hold on;
    title(sprintf('Estimated train %.1f percentage data set', percentage(i)));
    bar(centers, binsdensity);
    plot(all, epg(1).*eg1, 'g');
    plot(all, epg(2).*eg2, 'g');
    plot(all, 0.5 .* tg1, 'r');
    plot(all, 0.5 .* tg2, 'r');
    %%
    %Estimated
    plot(all, 0.5 * estpdf1, 'y');
    plot(all, 0.5 * estpdf2, 'y');
    %%
    %EM
    plot(all, 0.5 * nempdf1, 'b');
    plot(all, 0.5 * nempdf2, 'b');
    
    %%
    %preplot2
    figure;
    hold on;
    title(sprintf('Estimated train %.1f percentage data set', percentage(i)));
    bar(centers, binsdensity);
    plot(all, epg(1).*eg1 + epg(2).*eg2, 'g');
    plot(all, 0.5 .* tg1 + 0.5 .* tg2, 'r');
    %%
    %Estimated
    plot(all, 0.5 * estpdf1 + 0.5 * estpdf2, 'y');
    %%
    %EM
    plot(all, 0.5 * nempdf1 + 0.5 * nempdf2, 'b');
    %%
    estacc = sum(estclassifier == test_labels) / size(test_labels, 1);
    fprintf('%1.3f - dataset Estimated GMM classifier accuracy %0.3f \n', percentage(i), estacc);
    emacc = sum(emclassifier == test_labels) / size(test_labels, 1);
    fprintf('%1.3f - dataset EM GMM classifier accuracy %0.3f \n', percentage(i), emacc);
end