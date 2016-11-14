function R = bayes_risk_2normal(distribution1, distribution2, q)

distributionsPrior = [distribution1.Prior, distribution2.Prior];
distributionsMean = [distribution1.Mean, distribution2.Mean];
distributionsSigma = [distribution1.Sigma, distribution2.Sigma];
first = normcdf(q.t1, distributionsMean(q.decision(1)), distributionsSigma(q.decision(1)));
second = normcdf(q.t2, distributionsMean(q.decision(2)), distributionsSigma(q.decision(2))) ...
     - normcdf(q.t1, distributionsMean(q.decision(2)), distributionsSigma(q.decision(2)));
third = 1 - normcdf(q.t2, distributionsMean(q.decision(3)), distributionsSigma(q.decision(3)));
R = 1 - (distributionsPrior(q.decision(1)) * first ... 
    + distributionsPrior(q.decision(2)) * second ...
    + distributionsPrior(q.decision(3)) * third);
    
