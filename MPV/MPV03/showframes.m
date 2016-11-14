function showframes(A, props, opts);
% visualises frames, with and optional display of unit vectors and dominant orientation
   
   if nargin<2, props.color='y'; end;
   if nargin<3, opts.show_unit_vectors=1; opts.ext=3; end;
      
   % someone provided us with pts?  convert them to frames
   if (isstruct(A)), A=getframes(A); end;
   
   for a=1:size(A,3)      
      X=[-1 -1 1 1 -1 0 1 0; -1 1 1 -1 -1 0 0 1]; 
      X(3,:)=1; X(1:2,1:5)=X(1:2,1:5)*opts.ext;
      Xt=A(:,:,a)*X+1;
      line(Xt(1,1:5),Xt(2,1:5),'color','y', props); 
      if (isfield(opts, 'show_unit_vectors') & opts.show_unit_vectors==1)
         line(Xt(1,[6,7]), Xt(2,[6,7]), props, 'color', 'r'); 
         line(Xt(1,[6,8]), Xt(2,[6,8]), props, 'color', 'g');
      end;
      if (isfield(opts, 'show_orientation'))
         angle=opts.show_orientation(a); if iscell(angle) angle = angle{1}; end;
         for i=1:numel(angle)
             % draw 2*unit vector in orientation angle
             Xt=A(:,:,a)*[2*cos(angle(i)) ; 2*sin(angle(i)); 1]+1;
             line([A(1,3,a)+1 Xt(1,:)],[A(2,3,a) Xt(2,:)], props, 'color', 'm');
         end;
      end;
   end;