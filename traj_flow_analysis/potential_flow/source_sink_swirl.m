function [W,varargout] = source_sink_swirl(gamma,zA,x,y)
%SOURCE_SINK_SWIRL Generates the streamline function for a
% source/sink/swirl, with singularity at zA.
%
% SYNOPSIS: [W,X,Y] = source_sink_swirl(gamma,zA,x)
% INPUT: gamma - magnitude of the source/sink (c.f. charge). For a
%                source/sink, gamma is real and > 0 for a source, <0 for a
%                sink. For a swirl, gamma is imaginary.
%        zA - location in complex plane
%        x (optional) - grid on which to generate the field. Default is
%                       -10:.5:10
% OUTPUT: W - the flow potential
%         X,Y (optional) - the meshgrid coordinates of W
%
% xies@mit.edu. Nov 2011.

mask = 0;

if ~exist('x','var'), x = -10:.5:10; end
if ~exist('y','var'), y = x; end
[X,Y] = meshgrid(x,y);

num_singularities = numel(zA);
if numel(gamma) > 1
    if numel(gamma) ~= num_singularities, error('Please provide gammas');end
else
    gamma = gamma(ones(1,num_singularities));
end

Gamma = zeros([size(X),num_singularities]);
ZA = zeros([size(X),num_singularities]);
for i = 1:num_singularities
    ZA(:,:,i) = zA(ones(size(X))*i);
    Gamma(:,:,i) = gamma(ones(size(X))*i);
end

z = X + Y*1i;
z = z(:,:,ones(1,num_singularities));

W = Gamma./(2*pi).*log(z-ZA);
W = sum(W,3);

if mask
    zA_left = zA + 1;
    zA_right = zA - 1;
    zA_up = zA + 1i;
    zA_down = zA - 1i;
    W(zA_left) = NaN;
end
if nargout > 1
    varargout{1} = X;
    varargout{2} = Y;
end