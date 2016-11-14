function plot_csystem( Base, b, color, name )
%plot_csystem Summary of this function goes here
%   Detailed explanation goes here

texts = {'_x'; '_y'; '_z'};
for i = 1:size(Base, 2)
    plot3( [b(1), b(1) + Base(1, i) ], [ b(2), b(2) + Base(2,i)], [b(3), b(3) + Base(3, i)], 'color', color);
    text( b(1) + Base(1, i), b(2) + Base(2, i), b(3) + Base(3, i), [ name texts{i}], 'color', color );
end
end

