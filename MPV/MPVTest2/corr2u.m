function u=corr2u(pts1,pts2,corr)
   
   u(1:2,:)=[[pts1(corr(1,:)).x] ; 
             [pts1(corr(1,:)).y]];
   u(3,:)=1;
   u(4:5,:)=[[pts2(corr(2,:)).x] ; 
             [pts2(corr(2,:)).y]];
   u(6,:)=1;
   