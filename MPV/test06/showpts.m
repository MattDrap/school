function h = showpts(pts, props, opts)
% SHOWPTS(PTS) - draws points into image, PTS can be either 2xN [x;y] or 3xN [x;y;s] matrix. S is used as a scale of
% the point and circles with radius 3*S are drawn by default.
% SHOWPTS(PTS, PROPS) - draws points using properties in PROPS 
% SHOWPTS(PTS, PROPS, CUTOFF) - draws points using properties in PROPS and uses multiplier CUTOFF (default =3.0) to get
% radius of the circle.
%
   if (nargin<2)
      props.color = 'r';      
   end;
   
   if (nargin<3)
      opts.cutoff = 3;
   else
      if ~isstruct(opts)
         opts.cutoff=opts;
      end;
   end;
   marker = 'x';
   
   unit = linspace(0,2*pi,36);
   % show 3*\sigma neighbourhood
   
   ux = opts.cutoff*cos(unit);
   uy = opts.cutoff*sin(unit);
         
   if (isstruct(pts))
      mx = [pts.x];
      my = [pts.y];
      if (isfield(pts, 'a11'));
         % affine covariant points
         h=zeros(length(pts));
         for i=1:length(pts)
            p = pts(i);
            h(i)=line(p.x+ux*p.a11+uy*p.a12+1, p.y+ux*p.a21+uy*p.a22+1, props);
         end;         
      else 
         if (isfield(pts, 's'));
            % scale covariant points
            h=zeros(length(pts));
            for i=1:length(pts)
               p = pts(i);
               h(i)=line(p.x+ux*p.s+1, p.y+uy*p.s+1, props);
            end;
         else
            if (isfield(pts, 'x'))
               % translation covariant points
               h=line(x+1,y+1, 'linestyle','none', 'marker', marker, props);
            end;
         end;
      end;
   else
      mx=pts(1,:);
      my=pts(2,:);
      switch size(pts,1)
         case 6
           % affine covariant points x;y;a11;a12;a21;a22
           h=zeros(size(pts,2));
           for p=1:size(pts,2)
              h(p)=line(pts(1,p)+ux*pts(3,p)+uy*pts(4,p)+1, pts(2,p)+ux*pts(5,p)+uy*pts(6,p)+1, props);
           end;
         case 3
           % scale covariant points x;y;s
           h=zeros(size(pts,2));
           for p=1:size(pts,2)
              h(p)=line(pts(1,p)+ux*pts(3,p)+1, pts(2,p)+uy*pts(3,p)+1, props);
           end;
        case 2
          h=line(pts(1,:)+1, pts(2,:)+1, 'linestyle','none', 'marker', marker, props);
      end;
   end;
   
   if (isfield(opts, 'showids') & opts.showids==1)
      text(mx+1, my+1, {num2str([1:length(mx)]')}', props);
   end;