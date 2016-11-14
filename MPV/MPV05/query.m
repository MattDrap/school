function [img_ids, score]=query(DB, q, idf)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

occ = hist(q, 1:size(DB,2));
occ = occ .* idf;
mc = unique(q);
tf = occ(mc);
n_tf = tf/sqrt(sum(tf.^2));
ims2 = (DB(:,mc) * n_tf(:))';
[score, img_ids] = sort(ims2, 'descend');
end

