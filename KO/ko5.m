function [perm, cmax] = ko5(p,r,d)

J = 1:size(p, 2);
global UB;
UB = max(d);
[perm, cmax] = bratley(p,r,d, J, [], 0);
end
function [perm, span, optimal] = bratley(p,r,d,J, SEQ, cmax)
global UB;    
    perm = [];
    span = Inf;
    optimal = false;
    if length(J) == 1
        perm = [SEQ, J(1)];
        span = max(min(r(J)), cmax) + sum(p(J));%
        optimal = true;
        if span <= UB
            return;
        else
            perm = [];
            span = Inf;
        end
    end
    for i = 1:length(J)
        if optimal
            break;
        end
        nJ = J;
        nSEQ = [SEQ, J(i)];
        nJ(nJ == J(i)) = [];
        ncmax = max(cmax, r(J(i))) + p(J(i)); 
        %s.t. 1
        exceeded = false;
        for k = 1:length(nJ)
            if ncmax + p(nJ(k)) > d(nJ(k)) %s.t. 1)
                exceeded = true;
                break;
            end
        end
        if exceeded
            continue;
        end
        if(ncmax <= min(r(nJ)))
            optimal = true;
        end
        optimal = ncmax <= min(r(nJ));
        LB = max(min(r(nJ)), ncmax) + sum(p(nJ));
        if LB <= UB
            [mperm, mspan, moptim] = bratley(p,r,d,nJ, nSEQ, ncmax);
            perm = mperm;
            span = mspan;
            optimal = moptim;
        end
    end
end