function [ u_p ] = e2p( u_e )
%e2p Summary of this function goes here
%   Detailed explanation goes here
u_p  = [u_e; ones(1, size(u_e, 2))];

end

