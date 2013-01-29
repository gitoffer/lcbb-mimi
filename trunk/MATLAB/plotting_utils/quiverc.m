function h = quiverc(X,Y,U,V,scale,c,clim)

map = colormap;
if nargin > 6
    min_c = clim(1);
    max_c = clim(2);
else
    min_c = min(c);
    max_c = max(c);
end

color_step = (max_c - min_c)/length(map);

clf;
hold on
for n = 1:length(map)
    this_color = find(c >= min_c + (n-1)*color_step & ...
        c < min_c + n*color_step & ...
        ~isnan(U) & ~isnan(V));
    
    if ~isempty(this_color)
        quiver(X(this_color),Y(this_color),...
            U(this_color),V(this_color),scale,'Color',map(n,:));
    end
end
hold off

% h = colorbar;
% ylim = get(h, 'ylim');
% yal = linspace(ylim(1),ylim(2),10);
% set(h,'ytick',yal);
% yt1 = linspace(min_c,max_c,10);
% s = char(10,4);
% for i = 1:10
%     if min(abs(yt1)) >= .001
%         B = sprintf('%-04.3f',yt1(i));
%     else
%         B = sprintf('%-3.1E',yt1(i));
%     end
%     s(i,1:length(B)) = B;
% end
% set(h,'yticklabel',s);
% grid on;
