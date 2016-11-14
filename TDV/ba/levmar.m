function [x,f,iter,Xs,Fs,Ms] = levmar( x0, fun, gHfun, opt, varargin )
%LEVMAR  Second order minimization by Levenberg-Maquardt method.
%
%   [x,f] = levmar( x0, fun, gfun, Hfun, opts ... ) 
%   minimizes objective function by 
%   Levenberq-Maquardt algorithm (a damped Newton method).
%
%   [x,f,iter,Xs,Fs,Ms] = levmar( ... ) returns also some log of minimization.
%
%   Input:
%     x0    .. initial estimate.
%
%     fun   .. function returning objective function value. Called as
%              f = feval( fun, x, ... ) where '...' are additional arguments 
%              to LEVMAR.
%
%     gHfun .. function returning objective function value, gradient vector
%              and Hessian matrix. Called as [f, g, H] = feval( gHfun, x, ... )
%              where '...' are additional arguments to LEVMAR.
%
%              Alternatively, cell { gfun, Hfun } can be used, then similarly
%              g = feval( gfun, ... ) and H = feval( Hfun, ... ).
%
%     opt   .. structure with minimization options in following fields (defaults
%              are in brackets):
%
%        .dfmin   .. stopping criterion [sqrt(eps)] - minimum change
%                    of objective function value in each iteration.
%
%        .gmin    .. stopping criterion [sqrt(eps)] - minimum gradient length.
%
%        .maxiter .. maximum number of iterations (1e6).
%        .maxfeval .. maximum number of fun evaluation (1e7).
%
%        .mi      .. [1] initial ratio between Newton and gradient step
%
%        .mimax   .. stopping criterion [1/eps] maximum value of mi
%
%
%        .cfun, .Cfun .. constraint and its derivation ([])
%
%        .xfun  .. function modifying x, x = feval( xfun, x ) is called after
%                  each update ([])
%
%        .verbose .. [0] to be or not to be verbose (0|1|2|3).
%
%   Output:
%     x     .. found optimum
%     f     .. objective function (fun) value at x

% (c) 2008-11-14, Martin Matousek
% Last change: $Date::                            $
%              $Revision$

% ------------------------------------------------------------------------------
% prepare options

if( nargin < 4 || isempty( opt ) ), opt = struct(); end
if( iscell( opt ) ), opt = struct( opt{:} ); end

if( ~isfield( opt, 'maxiter' ) ), opt.maxiter = 1e6; end
if( ~isfield( opt, 'maxfeval' ) ), opt.maxfeval = 1e7; end
if( ~isfield( opt, 'dfmin' ) ), opt.dfmin = sqrt(eps); end
if( ~isfield( opt, 'gmin' ) ), opt.gmin = sqrt(eps); end
if( ~isfield( opt, 'mi' ) ), opt.mi = 1.1; end
if( ~isfield( opt, 'mimax' ) ), opt.mimax = 1/eps; end
if( ~isfield( opt, 'verbose' ) ), opt.verbose = 0; end
if( ~isfield( opt, 'cfun' ) ), opt.cfun = []; end
if( ~isfield( opt, 'Cfun' ) ), opt.Cfun = []; end
if( ~isfield( opt, 'xfun' ) ), opt.xfun = []; end


mi = opt.mi;
opt.gmin = opt.gmin^2; % we compute gradient length squared


if( opt.verbose )
  fprintf( 'LEVMAR ...\n' );
  t = tic;
end

% ------------------------------------------------------------------------------
% prepare variables

x = x0;
n = length(x0);
iter = 0; fiter = 0;  % iteration counters

if( iscell( gHfun ) )
  Hpure = feval( gHfun{2}, x, varargin{:} );
else
  [g Hpure] = feval( gHfun, x, varargin{:} );
end

if( issparse( Hpure ) )
  I = speye( n, n );
else
  I = eye( n, n );
end

if( nargout > 3 ), LOG = 1; else LOG = 0; end   % saving of trajectories
f = feval( fun, x, varargin{:} );

if( numel( f ) ~= 1 )
  error( 'Criterion (fun) must be scalar function' );
end
  
if( LOG )
  Xs = x;
  Fs = f;
  Ms = mi;
end

if( opt.verbose > 1 )
  fprintf( '  [ ]          f=%10.4g\n', f );
end

% ------------------------------------------------------------------------------
% iteration

%warning off MATLAB:nearlySingularMatrix;

do_break = 0;
while(1)
  if( iscell( gHfun ) )
    g = feval( gHfun{1}, x, varargin{:} );
    Hpure = feval( gHfun{2}, x, varargin{:} );
  else
    [g Hpure] = feval( gHfun, x, varargin{:} );
  end

  % constraints
  if( ~isempty( opt.cfun ) )
    c = feval( opt.cfun, x, varargin{:} );
    C = feval( opt.Cfun, x, varargin{:} );
    N = zeros( size( c, 1 ) );
  else
    c = [];
  end
  
  % Stopping criteria
  if( iter > opt.maxiter )
    warning( 'LEVMAR:MaxIterReached', 'Maximum iteration count reached' );
    break
  end
  
  glenq = g' * g;
  if( glenq < opt.gmin )
    if( opt.verbose )
      fprintf( '  Finish: Gradient below termination threshold (%g < %g).\n', ...
               sqrt( glenq ), sqrt( opt.gmin ) );
    end
    break
  end

  iter = iter + 1;

  % Do a step, change mi until objective function not increases
  while( 1 )
    if( mi > opt.mimax )
      warning( 'LEVMAR:MaxMiReached', 'Maximum mi reached' );
      do_break = 1;
      break
    end

    H = Hpure + mi * I;
    % Solve eqn: H*dx = -g
    if( isempty(c) )
      dx = -H\g;
    else % some constraints, use Sequential Quadratic Programming
      HH = ( [H C';C N] );
      dxl = -HH\[g;c];
      dx = dxl(1:n);
    end    

    x_new = x + dx;
    if( ~isempty( opt.xfun ) ), x_new = feval( opt.xfun,  x_new ); end

    f_new = feval( fun, x_new, varargin{:} );
    fiter = fiter + 1;

    if( fiter > opt.maxfeval )
      warning( 'LEVMAR:MaxFevalReached', 'Maximum feval count reached' );
      do_break = 1;
      break;
    end
    
    % f
    % f_new
    % keyboard
    if( f_new <= f ) % must be <=, not <. There are cases where |g| > 0 
                     % and f = f_new due to numeric accuracy
      break;
    end

    % bad turn - strenghten gradient step, shorten the step
    mi = mi * 2; 
    if( opt.verbose > 2 ), fprintf( '  (^) mi=2^%3.0f\n', log2(mi) ); end
  end

  if( do_break )
    break
  end
  % now f_new <= f

  % check local accuracy of second order approximation - compare estimated and 
  % real decrease of objective function
  
  df_est = g' * dx + 0.5 * dx' * H * dx;
  df = f_new - f;
  
%  %$debug-start:check$
%  if( df_est > 0 )
%    vw_warning( 'LEVMAR:EstIncrease', ...
%             'Unexpected objective function estimate increase.' ); 
%  end
%  if( df > 0 ),   error( 'Unexpected objective function increase.' ); end
%  %$debug-stop:check$
  
  ratio = df/df_est;

  f = f_new;
  x = x_new;

  %  if( ratio < 0.25 )
  %mi = mi * 2; if( opt.verbose ), fprintf( '[^] mi=2^%3.0f ', log2(mi) ); end;
    %  elseif( ratio > 0.75 )%&& ratio < 1.25 )
        mi = mi / 2; if( opt.verbose > 1 ), fprintf( '  [v] mi=2^%3.0f ', log2(mi) ); end;
    %  else
    %    if( opt.verbose ), fprintf( '  [ ]          ' ); end;
    %  end

  if( opt.verbose > 1 )
    fprintf( '  f=%10.4g df=%10.4g |g|=%10.4g |dx|=%10.4g\n', ...
             f, df, sqrt( glenq ), sqrt( dx' * dx ) ); 
  end

  if( LOG )
    Xs = [Xs x]; %#ok
    Fs = [Fs f]; %#ok
    Ms = [Ms mi]; %#ok
  end
  
  if( ( abs(df) < opt.dfmin ) )
    if( opt.verbose )
      fprintf( '  Finish: Criterion change below termination threshold.\n' );
    end
    
    break;
  end
  
end

if( opt.verbose )
  fprintf( 'LEVMAR: Number of iterations: %i (%i funcalls) in %g sec.\n', ...
           iter, fiter, toc(t) );
end
  