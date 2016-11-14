function dist=adist(A,pts1,pts2)
   pts = A*pts1;
   dist = sum((pts(1:2,:)-pts2(1:2,:)).^2);