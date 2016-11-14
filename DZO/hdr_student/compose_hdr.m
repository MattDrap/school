function hdr = compose_hdr(im, t, w, finv)
%COMPOSE_HDR Compose HDR image
%
% hdr = compose_hdr(im, t, w, finv)
%
% Input:
%   im   [1xP cell] Cell array of images [MxNxC].
%   t    [1xP double] Exposure times.
%   w    [1xL double] Intensity weights, indexed as w(im{i}+1).
%   finv [1xL double] Inverse response function, indexed as finv(im{i}+1).
%
% Output:
%   hdr [MxNxC double] HDR image composed from the input images.
%

assert(numel(im) == numel(t));
assert(numel(w) == numel(finv));

hdr = zeros(size(im{1}));

%% TODO: Implement me!
P = size(im, 2);
weights = zeros(size(im{1}));
for j = 1:P
    hdr = hdr + (w(double(im{j}) + 1) .* finv(double(im{j}) + 1) ./ t(j));
    weights = weights + w(double(im{j}) + 1);
end
hdr = hdr./weights;

% hdr2 = zeros(size(im{1}));
% for i = 1:size(hdr2,1)
%     for j = 1:size(hdr2,2)
%         for k = 1:size(hdr2, 3)
%             wsum = 0;
%             wcit = 0;
%             for l = 1:P
%                 ww = w(im{l} + 1);
%                 finv2 = finv(im{l} + 1);
%                 wcit = wcit + ww(i,j,k) * finv2(i,j,k) / t(l);
%                 wsum = wsum + ww(i,j,k);
%             end
%             hdr2(i,j,k) = wcit/wsum;
%         end
%     end
% end
% 
% res = hdr - hdr2;
%%

end
