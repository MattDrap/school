%%
%Substitute of the Parallel Computing toolbox
%
%
%NUMLABS Return the total number of labs operating in parallel
%   n = numlabs returns the total number of labs currently operating. This
%   value is the maximum value that can be used with labSend and labReceive.
%
%   See also labSend, labReceive, labindex.

%   Copyright 2005-2011 The MathWorks, Inc.

function x = numlabs()
	x = 1;
end