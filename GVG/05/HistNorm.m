function [Hadj] = HistNorm( Rim, Him, chan )
  if nargin > 2
    R = histc(reshape(Rim(:,:,chan),1,[]), 0:255);
    H = histc(reshape(Him(:,:,chan),1,[]), 0:255);
    Rc = cumsum(R);
    Hc = cumsum(H);      
    Hmap = arrayfun( @(val) find(Rc >= val, 1), Hc , 'UniformOutput', 'false');
    Hadj = uint8(Hmap(Him(:,:,chan)+1)-1);
  else
    Hadj = uint8(zeros(size(Him)));
    for c = 1:3
      Hadj(:,:,c) = HistNorm( Rim, Him, c );
    end
  end
end
