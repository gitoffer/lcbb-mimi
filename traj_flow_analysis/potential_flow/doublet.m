function [W,varargout] = doublet(gamma,zA,theta,x)

if ~exist('theta','var'), theta = 0; end
if ~exist('x','var'), x= -10:1:10; end
[x,y] = meshgrid(x);

num_singularities = numel(zA);
ZA = zeros([size(x),num_singularities]);

for i = 1:num_singularities
    ZA(:,:,i) = zA(ones(size(x))*i);
end

z = x + y*1i;
z = z(:,:,ones(1,num_singularities));

W = exp(-1i*theta).*gamma.*(2*pi)./(z-ZA);
W = sum(W,3);

if nargout > 1
    varargout{1} = x;
    varargout{2} = y;
end

% pcolor(Xf,Yf,imag(W));
