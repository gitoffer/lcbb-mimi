function x = nonans(x)

x = x(~isnan(x));

end