%SampleCnt calculates number of samples needed to be done

function SampleCnt = nsamples(ni, ptNum, pf, conf)

if conf > 1
  error('Conf must be less then or equal to 1');
end

q  = prod ([(ni-pf+1) : ni] ./ [(ptNum-pf+1) : ptNum]);

if q < eps
   SampleCnt = Inf;
else  
   SampleCnt  = log(1 - conf) / log(1 - q);
end

if SampleCnt < 1
   SampleCnt = 1;
end
