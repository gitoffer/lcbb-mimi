function f = lsq_linear(param,x)

slope = param(1);
intercept = param(2);

f = slope*x+intercept;