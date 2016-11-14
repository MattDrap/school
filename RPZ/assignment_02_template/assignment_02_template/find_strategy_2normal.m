function q = find_strategy_2normal(distribution1, distribution2)

% same function as in the previous assignment, only extreme
% values of priors are handled now

if distribution1.Prior == 1
    q.decision = [1, 1, 1];
    q.t1 = -Inf;
    q.t2 = Inf;
    return
elseif distribution2.Prior == 1
    q.decision = [2, 2, 2];
    q.t1 = -Inf;
    q.t2 = Inf;
    return
end

% quadratic discriminative function
Coef = zeros(1,3);
Coef(1) = 0.5 * 1/distribution2.Cov - 0.5 * 1/distribution1.Cov;
Coef(2) = distribution1.Mean/distribution1.Cov - distribution2.Mean/distribution2.Cov;
Coef(3) = log(distribution1.Prior/distribution2.Prior)...
    + log(distribution2.Sigma/distribution1.Sigma) ...
    + 0.5 * (distribution2.Mean^2)/distribution2.Cov - 0.5 * (distribution1.Mean^2)/distribution1.Cov;

% computing the polinomial roots
Ts = roots(Coef); % thresholds

is_convex = Coef(1) > 0;

% assign thresholds and decisions
if isreal(Ts)
    if Ts(1) ~= Ts(2)
          q.t1 = min(Ts);
          q.t2 = max(Ts);
        if is_convex
          q.decision = [1,2,1]
        else
          q.decision = [2,1,2]
        end
    else
      q.t1 = -Inf;
      q.t2 = Inf;
      if is_convex
        q.decision = [1,1,1]
      else
        q.decision = [2,2,2]
      end
    end
else
  q.t1 = -Inf;
  q.t2 = Inf;
  if is_convex
    q.decision = [1,1,1]
  else
    q.decision = [2,2,2]
  end
end
