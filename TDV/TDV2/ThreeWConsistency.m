function [ pc1_, pc2_, pc3_] = ThreeWConsistency( m12, m13, m23, pc12, pc13, pc23)
%ThreeWConsistency Summary of this function goes here
%   Detailed explanation goes here

pc1_ = [];
pc2_ = [];
pc3_ = [];
for i = 1:size(m12, 2)
   im23 = ismember(m23(1, :), m12(2, i));
   if sum(im23) > 0
    im31 = ismember(m13(1, :), m12(1, i));
    if sum(im31) > 0
        if pc12(1:2, i) == pc13(1:2, im31)
            pc1_ = [pc1_, pc12(1:2, i)];
            pc2_ = [pc2_, pc23(1:2, im23)];
            pc3_ = [pc3_, pc13(3:4, im31)];
        end
    end
   end
end
end

