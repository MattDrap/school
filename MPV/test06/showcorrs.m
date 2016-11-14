function showcorrs(im1, qgeom, im2, dgeom, corrs, inl)
   
   u = qgeom(1:2,corrs(1,:));
   u(3,:)=1;
   u(4:5,:)= dgeom(1:2,corrs(2,:));
   u(6,:)=1;
   
   maxrow=max(size(im1,1), size(im2,1));   
   composite=zeros(maxrow, size(im1,2) + 10 + size(im2,2));
   
   composite(1:size(im1,1), 1:size(im1,2)) = im1;
   composite(1:size(im2,1), 11+size(im1,2):10+size(im1,2)+size(im2,2)) = im2;
   figure('position',[0 1920 1200 450]); set(gca,'position', [0 0 1 1]); imagesc(composite,[0 1]); colormap gray; axis('image','off');
   
   p.color=[.75 .0 0];
   p.markersize=20;
   p.marker='.';
   
   line([u(1,inl);u(4,inl)+10+size(im1,2)]+1, [u(2,inl);u(5,inl)]+1);
   showpts(qgeom(1:2,corrs(1,:)), p);
   showpts([dgeom(1,corrs(2,:))+size(im1,2)+10 ; dgeom(2,corrs(2,:))], p);

   p.color='y';
   p.markersize=20;
   p.marker='.';
   
   showpts(u(1:2,inl),p);
   showpts([u(4,inl)+size(im1,2)+10; u(5,inl)],p);