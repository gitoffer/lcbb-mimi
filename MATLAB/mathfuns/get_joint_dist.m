function [pXY,binsX,binsY] = get_joint_dist(X,Y,nX,nY)
%GET_JOINT_DIST Calculates the joint distribution of two random continuous
% variables X,Y, by 2D-binning.
%
%	SYNOPSIS:
% [joint_dist,binsX,binsY] = get_joint_dist(X,Y);
% [joint_dist,binsX,binsY] = get_joint_dist(X,Y,nX,nY);
%
% xies@mit.edu June 2012.

switch nargin
	case 2
		nX = 10; nY = 10;
	case 4
	otherwise
		error('Wrong number of inputs.');
end

binsX = linspace(nanmin(X)-eps,nanmax(X)+eps,nX);
binsY = linspace(nanmin(Y)-eps,nanmax(Y)+eps,nY);

pXY = hist2(X,Y,binsX,binsY);
pXY = pXY/nansum(pXY(:));

end
