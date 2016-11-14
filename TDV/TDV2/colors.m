function c = colors( n )

cl = [ 1   0   0;
       0 0.8   0;
       1   1   0;
       0   0   0;
       0   0.5 0.5;
       0   0   1;
       1   0   1;
      .5   0   .5;
       1   .5  0;

     ];

i = rem( 0:(n-1), size( cl, 1 ) ) + 1;

c = cl( i, : );
