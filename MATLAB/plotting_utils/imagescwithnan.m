function [h hcb] = imagescwithnan(x,y,a,cm,nanclr)
% IMAGESC with NaNs assigning a specific color to NaNs
% yuk@StackOverflow
%
% http://stackoverflow.com/questions/8481324/contrasting-color-for-nans-in-imagesc

%# find minimum and maximum
amin=min(a(:));
amax=max(a(:));
%# size of colormap
n = size(cm,1);
%# color step
dmap=(amax-amin)/n;

%# standard imagesc
him = imagesc(x,y,a);
%# add nan color to colormap
colormap([nanclr; cm]);
%# changing color limits
caxis([amin-dmap amax]);
%# place a colorbar
hcb = colorbar;
%# change Y limit for colorbar to avoid showing NaN color
ylim(hcb,[amin amax])

if nargout > 0
    h = him;
end

end
