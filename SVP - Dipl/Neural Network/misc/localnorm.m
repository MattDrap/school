function [lnim inmean instd] = localnorm(in, filtSize)
%
% given a set of feature maps, performs local normalization
% out = (in -mean(in))/std(in)
% mean and std are defined over local neighborhoods that span
% all feature maps and a local spatial neighborhood
%

if nargin<2
    filtSize = 9;
end
k = fspecial('gaussian',filtSize,1.591);

ker = zeros(size(in,1),size(k,1),size(k,2));
for i=1:size(in,1)
    ker(i,:) = k(:);
end
ker = ker / sum(ker(:));

if length(size(in))==3
    % mu = E(in)
    inmean = multiconv(in,ker);
    % in-mu
    inzmean = in - inmean;
    % (in - mu)^2
    inzmeansq = inzmean .* inzmean;
    % std = sqrt ( E (in - mu)^2 )
    instd = sqrt(multiconv(inzmeansq,ker));
    % threshold std with the mean
    mstd = mean(instd(:));
    instd(instd<mstd) = mstd;
    % scale the input by (in - mu) / std
    lnim = inzmean ./ instd;
elseif length(size(in))==4
    lnim = zeros(size(in));
    for i=1:size(in,4);
        % mu = E(in)
        inmean = multiconv(in(:,:,:,i),ker);
        % in-mu
        inzmean = in(:,:,:,i) - inmean;
        % (in - mu)^2
        inzmeansq = inzmean .* inzmean;
        % std = sqrt ( E (in - mu)^2 )
        instd = sqrt(multiconv(inzmeansq,ker));
        % threshold std with the mean
        mstd = mean(instd(:));
        instd(instd<mstd) = mstd;
        % scale the input by (in - mu) / std
        lnim(:,:,:,i) = inzmean ./ instd;
    end
end

function out = multiconv(in,ker)
%
% this is basically 3d convolution without zero padding in 3rd
% dimension
%
out = zeros(size(in));
for i=1:size(in,1)
    cin = squeeze(in(i,:,:));
    cker = squeeze(ker(i,:,:));
    out(i,:,:) = conv2(cin,cker,'same');
end
sout = squeeze(sum(out));
for i=1:size(out,1)
    out(i,:) = sout(:);
end
