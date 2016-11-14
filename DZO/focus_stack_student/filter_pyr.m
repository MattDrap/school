function pyr_out = filter_pyr(pyr, f)
% function pyr_out = filter_pyr(pyr, f)
%
% filter highpass components of pyr by filter f. 

pyr_out = pyr; 

for k = 1:numel(pyr.residuals) 
    pyr_out.residuals{k} = f(k) * pyr.residuals{k}; 
end

