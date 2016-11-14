function dist=hdist(H,u)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here


    ou = e2p(u(1:2, :));
    nu = e2p(u(3:4, :));
   
   nu2 = H*ou;
   
   nu2(1,:) = nu2(1,:)./nu2(3,:);
   nu2(2,:) = nu2(2,:)./nu2(3,:);   
   nu2(3,:) = nu2(3,:)./nu2(3,:);
   
   dist = sum((nu2-nu).^2);

end

