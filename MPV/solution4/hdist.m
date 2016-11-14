function dist=hdist(H,u)
   pts = H*u(1:3,:);
   pts(1,:) = pts(1,:)./pts(3,:);
   pts(2,:) = pts(2,:)./pts(3,:);   
   dist = sum((pts(1:2,:)-u(4:5,:)).^2);