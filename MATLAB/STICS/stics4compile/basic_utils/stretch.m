function x = stretch(x)
x = x-min(x(:));
x = x./max(x(:));
end
