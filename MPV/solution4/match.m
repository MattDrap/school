function corr=match(pts1, pts2, par)

   if (~isfield(par,'threshold'))
      threshold = inf;
   else
      threshold = par.threshold*par.threshold;
   end;
   D=zeros(numel(pts1),numel(pts2));
   
   tmp = [pts2.desc];   
   for i=1:numel(pts1)
      D(i,:) = sum((repmat(pts1(i).desc, 1, numel(pts2)) - tmp).^2);
   end;
   
   switch (par.method)
     case 'mutual'
       [m1 p1] = min(D, [], 2); % minima and positions in each row
       [m2 p2] = min(D, [], 1); % minima and positions in each col
       corr = zeros(2, min(numel(pts1), numel(pts2)));
       num_corr = 0;
       for i=1:numel(pts1)
          if (p2(p1(i))==i && m1(i)<=threshold)
             corr(:,num_corr+1) = [i; p1(i)];
             num_corr=num_corr+1;             
          end;
       end;
       corr(:,num_corr+1:end)=[];
     case 'stable'
       max_corr=min(numel(pts1),numel(pts2));
       num_corr=0;
       for i=1:max_corr
          [val, idx]=min(D(:));
          [y, x]=ind2sub(size(D),idx);
          if (val>threshold)
             % we are already done, no more usable pairs             
             break;
          end;
          corr(:,num_corr+1)= [y;x];
          num_corr=num_corr+1;             
          D(y,:)=inf; D(:,x)=inf;
       end;
       corr(:,num_corr+1:end)=[];
     case 'sclosest'       
       num_corr=0;
       for i=1:numel(pts1)
          [d ord]=sort(D(i,:));
          if (d(1)/d(2) < 0.8*0.8)
             corr(:,num_corr+1) = [i;ord(1)];
             num_corr=num_corr+1;             
          end;
       end;
       corr(:,num_corr+1:end)=[];
   end;