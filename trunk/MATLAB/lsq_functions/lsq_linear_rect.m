function y = lsq_linear_rect(params,x)

slope = params(1);
intercept = params(2);

y = slope*x + intercept;
y(y<0) = 0;

y = y + params(3);

end