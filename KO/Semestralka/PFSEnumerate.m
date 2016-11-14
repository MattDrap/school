function [ PERM, makespan ] = PFSEnumerate( proc_table )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
global ptable;
global M;
ptable = proc_table;
[J, Machines] = size(proc_table);
M = Machines;
J = 1:J;
spans = zeros(1, Machines);
[PERM, makespan] = recPFSEnumerate(J, [], spans);
end

function [Perm, makespan] = recPFSEnumerate(J, Fixed, spans)
 global ptable;
 global M;
 Perm = [];
 makespan = Inf;
 
 if length(J) == 1
    nspans = spans;
    nspans(1) = nspans(1) + ptable(J(1), 1);
    for j = 2:M
        nspans(j) = max(nspans(j), nspans(j-1)) + ptable(J(1), j);
    end
    makespan = max(nspans);
    Perm = Fixed;
    Perm = [Perm, J(1)];
    return;
 end
 
 for i = 1:length(J)
     nspans = spans;
     nspans(1) = nspans(1) + ptable(J(i), 1);
    for j = 2:M
        nspans(j) = max(nspans(j), nspans(j - 1)) + ptable(J(i), j);
    end
    nFixed = [Fixed, J(i)];
    nJ = J;
    nJ(nJ == J(i)) = [];
    [lperm, lmakespan] = recPFSEnumerate(nJ, nFixed, nspans);
    if lmakespan < makespan
        Perm = lperm;
        makespan = lmakespan;
    end
 end
end