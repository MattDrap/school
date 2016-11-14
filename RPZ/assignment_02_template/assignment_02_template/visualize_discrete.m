function visualize_discrete( discrete1, discrete2, q )

range = -10:10;
posterior1 = discrete1.Prob*discrete1.Prior;
posterior2 = discrete2.Prob*discrete2.Prior;

max_prob = max( [posterior1, posterior2] );

h = bar(range,[posterior1; posterior2]'); 
set(h(1),'facecolor','r')
set(h(2),'facecolor','g')
legend('p_{XK}(x,A)','p_{XK}(x,C)')
title('posterior probabilities and strategy q')
xlim([-10.5 10.5])

for x = 1:length(range)
    if q(x) == 1
        col = 'r';
    else
        col = 'g';
    end
    rectangle('Position',[range(x)-0.5,-max_prob/8,1,max_prob/10], ...
              'FaceColor',col, 'EdgeColor','none')
end
text(0, -max_prob/16, 'strategy q')
