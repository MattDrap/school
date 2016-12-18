function [ R_best, t_best, inl ] = ransac_p3p( X, u, K, thr, confidence )%ransac_p3p( K, X, u, confidence )
%RANSAC_P3P Summary of this function goes here
%   Detailed explanation goes here
% u = K\e2p(u);
% X = e2p(X);
support = 0;
num_samples = inf;
count = 0;
max_samples = 3;
N = size(u, 2);

R_best = [];
t_best = [];
thr = 25; % 5^2 pixel difference

% RANSAC
while count < num_samples 
    sam_3p = sample(max_samples, N);
    
    % p3p solution
    res = p3p_grunert( X(1:3,sam_3p), u(1:2,sam_3p) );
    
    for r = res
        Xc = r{1};
        [R, t] = XX2Rt_simple( X(:,sam_3p), Xc );

        P = [K*R K*t];
        z = getDepth(P, X);
        in_front = z > 0;
        in_front_ind = find(in_front);
        
        test_X = X(:,in_front);
        test_u = u(:,in_front);
        reproj_u = p2e(P*test_X);
        u_e = p2e(K*test_u);
        err = (reproj_u(1,:) - u_e(1,:)).^2 + (reproj_u(2,:) - u_e(2,:)).^2;
%         dist = reproj_u - u_e;
%         err = dist'*dist;
        
%         count_inl = sum(1 - err./thr)/N;
        count_inl = sum(err < thr);
        if count_inl > support
            R_best = R;
            t_best = t;
            support = count_inl;
%             support = count_inl;
%             zero_ind = find(~(err < thr));
            zero_ind_in_front = in_front_ind(~(err < thr));
            in_front(zero_ind_in_front) = 0;
            inl = in_front;
            num_samples = nsamples(count_inl, N, max_samples, confidence);
        end
    end
    
    count = count + 1;
    fprintf('Iteration: %d / %d\n',count,num_samples);
end


end

