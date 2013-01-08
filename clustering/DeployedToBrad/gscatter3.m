function h = gscatter3(x,y,z,g)
%   GSCATTER3       3-D Scatterplot with Group Colors
%
%   GSCATTER3(X,Y,Z,G)
%   X,Y,Z are input vectors. They must be of the same length. 
%   G is a vector of class/group labels - of the same lenght as the data
%   vectors.
%
%   EDA Toolbox, June, 2005

if length(x) ~= length(g)
    error('Vectors must be of the same length.')
    return
end

% this does a 3-D scatterplot with observations colored by groups.
% Get the color scheme
clr = {'b','g','r','c','m','y','k'};
if length(unique(g)) > 7
    errordlg('Can only handle up to 7 groups.')
    return
end
tmp = unique(g);
h = [];
for i = 1:length(tmp)
    inds = find(g == tmp(i));
    ht = plot3(x(inds),y(inds),z(inds),'o');
    hold on
    set(ht,'color',clr{i})
    h = [h(:); ht(:)];
end
box on
grid on
hold off