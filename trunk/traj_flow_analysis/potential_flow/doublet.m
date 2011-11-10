function [W,varargout] = doublet(gamma,zA,x)

if ~exist('x','var'), x= -10:1:10; end
[Xf,Yf] = meshgrid(x);
z = Xf + 1i*Yf;

W = gamma.*(2*pi)./(z-zA);

if nargout > 1
    varargout{1} = Xf;
    varargout{2} = Yf;
end

% pcolor(Xf,Yf,imag(W));
