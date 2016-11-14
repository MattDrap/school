function [ permutation, makespan ] = PFS(time_table)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
[J, Machines] = size(time_table);
J = 1:J;

help = struct();
help.last_branching = 0;
help.UB = Inf;
help.LB = Inf;

help.set_processing_time = sum(time_table);
pre_set_head = min(cumsum(time_table, 2));
help.set_head = [0, pre_set_head(1:end-1)];
pre_set_tail = fliplr(min(cumsum(fliplr(time_table), 2)));
help.set_tail = [pre_set_tail(2:end), 0];
global process_time_table;
process_time_table = time_table;
global M;
M = Machines;

[IN, OUT, res, mmakespan] =recPFS(J, [], [], help);
makespan = mmakespan;
permutation = [IN, OUT];
missing = setdiff(J,permutation);
permutation = [IN, missing, fliplr(OUT)];
end

function [INo, OUTo, res, makespan] = recPFS(J, IN, OUT, help)
INo = [];
OUTo = [];
res = Inf;
makespan = -Inf;
global process_time_table;
global M;

if length(J) == 1
    %feasible
    if help.last_branching == 1
        new_set_processing_time = zeros(1, M);
        new_set_tail = help.set_tail;
        new_set_head = zeros(1, M);
        new_set_head(1) = help.set_head(1) + process_time_table(J(1) , 1);
        for j = 2:M
            new_set_head(j) =max(help.set_head(j), new_set_head(j - 1)) + process_time_table(J(1), j);
        end
        for j = 1:M
            new_set_processing_time(j) = help.set_processing_time(j) - process_time_table(J(1), j);
        end
    else
        new_set_processing_time = zeros(1, M);
        new_set_head = help.set_head;
        new_set_tail = zeros(1, M);
        new_set_tail(M) = help.set_tail(M) + process_time_table(J(1) , M);
         for j = M-1:-1:1
            new_set_tail(j) =max(help.set_tail(j), new_set_tail(j + 1)) + process_time_table(J(1), j);
         end
        for j = 1:M
            new_set_processing_time(j) = help.set_processing_time(j) - process_time_table(J(1), j);
        end
    end
    LB = max(new_set_processing_time + new_set_tail + new_set_head);
    
    res = min(help.UB, LB - 1);
    INo = IN;
    OUTo = OUT;
    makespan = LB;
    return;
end

%input?
if help.last_branching == 1
    for i =1:length(J)
        new_set_processing_time = zeros(1, M);
        new_set_tail = help.set_tail;
        new_set_head = zeros(1, M);
        new_set_head(1) = help.set_head(1) + process_time_table(J(i) , 1);
        for j = 2:M
            new_set_head(j) =max(help.set_head(j), new_set_head(j - 1)) + process_time_table(J(i), j);
        end
        for j = 1:M
            new_set_processing_time(j) = help.set_processing_time(j) - process_time_table(J(i), j);
        end
        INk = [IN, J(i)];
        log1 = true(1, length(J));
        log1(i) = false; 
        Jk = J(log1);
        LB = max(new_set_processing_time + new_set_tail + new_set_head);
        %
        helpk = help;
        helpk.last_branching = 1 - help.last_branching;
        helpk.set_head = new_set_head;
        helpk.set_tail = new_set_tail;
        helpk.set_processing_time = new_set_processing_time;
        if LB <= help.UB
            [INos, OUTos, result, recLB] = recPFS(Jk, INk, OUT, helpk);
            if result < help.UB
                INo = INos;
                OUTo = OUTos;
                help.UB = result;
                res = result;
                makespan = recLB;
            end
        end
    end
else    

    for i = 1:length(J)
        new_set_processing_time = zeros(1, M);
        new_set_head = help.set_head;
        new_set_tail = zeros(1, M);
        new_set_tail(M) = help.set_tail(M) + process_time_table(J(i) , M);
         for j = M-1:-1:1
            new_set_tail(j) =max(help.set_tail(j), new_set_tail(j + 1)) + process_time_table(J(i), j);
         end
        for j = 1:M
            new_set_processing_time(j) = help.set_processing_time(j) - process_time_table(J(i), j);
        end
        OUTk = [OUT, J(i)];
        log1 = true(1, length(J));
        log1(i) = false; 
        Jk = J(log1);
        LB = max(new_set_processing_time + new_set_tail + new_set_head);

        helpk = help;
        helpk.last_branching = 1 - help.last_branching;
        helpk.set_head = new_set_head;
        helpk.set_tail = new_set_tail;
        helpk.set_processing_time = new_set_processing_time;
        if LB <= help.UB
            [INos, OUTos, result, recLB] = recPFS(Jk, IN, OUTk, helpk);
            if result < help.UB
                INo = INos;
                OUTo = OUTos;
                help.UB = result;
                res = result;
                makespan = recLB;
            end
        end
    end
end

end
