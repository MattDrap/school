function res=dctdesc(img, num_coefs)  
res = zeros(num_coefs,1); sz = size(img);
coefs = dct2(img)/sz(1)+0.5; x=1;

% first half of coefficients
for i=1:sz(1),
   for j=1:i, 
      if mod(i,2)==0, res(x)=coefs(j, i-j+1); else j=i+1-j; res(x)=coefs(j, i-j+1); end;
      x=x+1; 
      if (x>num_coefs) return; end;
   end;
end;