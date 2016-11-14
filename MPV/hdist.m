function dist=hdist(H,u)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here
   ou = u(1:3, :);
   nu = u(4:6, :);
   
   nu2 = H*ou;
   
   nu2(1,:) = nu2(1,:)./nu2(3,:);
   nu2(2,:) = nu2(2,:)./nu2(3,:);   
   nu2(3,:) = nu2(3,:)./nu2(3,:);
   
   dist = sum((nu2-nu).^2);

end

