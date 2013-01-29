function z = shifted_gaussian(x,y,b)
    z = b(1)*exp(- ((x-b(4)).^2 + (y - b(5)).^2)./b(2).^2) + b(3) ;
end