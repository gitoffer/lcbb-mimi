% function h = quiverclr(x,y,u,v,z,zlim)
% plots the values of u and v, with z colour coded
% at the positions specified by x and y.
% A colourbar is added on the right side of the figure.
% x, y, u, v, z : vector of same lengths 
%
% The colorbar strectches from the minimum value of v to its
% maximum.
%
% 'zlim' is optional, to define the limits of the colourbar.
% z values outside zlim are not plotted
%
% Stephanie Contardo, August 2009, CSIRO

function h = quiverclr(x,y,u,v,z,zlim)

map=colormap;
if nargin >5
    miz = zlim(1) ;
    maz = zlim(2) ;
else
    miz=min(z);
    maz=max(z);
end
clrstep = (maz-miz)/size(map,1) ;
% Plot the points
hold on
for nc=1:size(map,1)
    iz = find(z>miz+(nc-1)*clrstep & z<=miz+nc*clrstep...
    & ~isnan(u) & ~isnan(v)) ;
    if ~isempty(iz)
        quiver(x(iz),y(iz),u(iz),v(iz),0,'color',map(nc,:)) ;
    end
end
hold off

% Re-format the colorbar
h=colorbar;
%set(h,'ylim',[1 length(map)]);
ylim = get(h,'ylim') ;
yal = linspace(ylim(1),ylim(2),10) ;
set(h,'ytick',yal);
% Create the yticklabels
ytl=linspace(miz,maz,10);
%set(h,'ytick',ytl);
s=char(10,4);
for i=1:10
    if min(abs(ytl)) >= 0.001
        B=sprintf('%-4.3f',ytl(i));
    else
        B=sprintf('%-3.1E',ytl(i));
    end
    s(i,1:length(B))=B;
end
set(h,'yticklabel',s);
grid on

