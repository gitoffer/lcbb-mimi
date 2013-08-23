function [mx,my] = center_of_image(img)

[M,N] = size(img);
[X,Y] = meshgrid(1:N,1:M);

cell_mass = sum(img(img > 0));
mx = sum(sum( img.*X ))/cell_mass;
my = sum(sum( img.*Y ))/cell_mass;

end