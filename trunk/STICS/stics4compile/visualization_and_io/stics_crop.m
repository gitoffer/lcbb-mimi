function [stics_img,Xf,Yf] = stics_crop(stics_img,Xf,Yf,crop)

x0 = crop.x0;
xf = crop.xf;
y0 = crop.y0;
yf = crop.yf;

x = Xf(1,:);
y = Yf(:,1);
imc = zeros(yf-y0+floor(x(1)/2),xf-x0+floor(x(1)/2),numel(stics_img));
x0 = x(x >= x0 & x < x0 + x(1));
xf = x(x >= xf & x < xf + x(1));
y0 = y(y >= y0 & y < y0 + y(1));
yf = y(y >= yf & y < yf + y(1));

x = x(:,find(x==x0):find(x==xf));
y = y(find(y==y0):find(y==yf),:);
[Xf,Yf] = meshgrid(x,y);

for i = 1:numel(stics_img)
    vector = stics_img{i};
    stics_img{i} = vector(find(y==y0):find(y==yf),find(x==x0):find(x==xf),:);
end