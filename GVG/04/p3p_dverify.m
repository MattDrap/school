function e = p3p_dverify( n1, n2, n3, d12, d23, d31, c12, c23, c31 )
%P3P_DVERIFY  P3P problem - verification of points-to-camera distances.
%
% e = p3p_dverify( N1, N2, N3, d12, d23, d31, c12, c23, c31  )
%
%   Input: 
%     d12, d23, d31 .. distances between three points in the space (scalars)
%
%     c12, c23, c31 .. appropriate cosines (scalars)
%
%     N1, N2, N3 .. distances, row vectors 1 x number_of_solutions
%
%   Output:
%     e ..   3 x number_of_solutions, errs of distances for each
%            distance d_jk and each solution. Errors should be RELATIVE w.r.t. 
%            appropriate d_jk.
%
%            E.g.
e = zeros(3, 1);
e(1) = ( sqrt( n1^2 + n2^2 - 2* n1* n2 *c12) - d12 ) / d12;
e(2) = ( sqrt( n2^2 + n3^2 - 2* n2* n3 *c23) - d23 ) / d23;
e(3) = ( sqrt( n3^2 + n1^2 - 2* n3* n1 *c31) - d31 ) / d31; 
