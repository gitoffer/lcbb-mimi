function imf = hysteresis_thresholding(image,weak,strong,neighborhood)
%HYSTERESIS_THRESHOLDING Performs hysteresis thresholding on an input
% image, given strong and weak thresholding conditions. Optionally, can use
% a custum neighborhood. (C/f Canny filter)
%
% SYNOPSIS: imf = hysteresis_thresholding(im,weak,strong,nhood)
%
% INPUT: im - image
%        weak - weak threshold
%        strong - strong threshold
%        nhood - structuring element for dilating the strongly thresholded
%                image
%
% OUTPUT: imf - thresholded image
%
% xies@mit March 2012.

if nargin < 4, neighborhood = true(3); end

strongly_thresh = image >= strong;
weakly_thresh = image >= weak;

old_thresh = weakly_thresh;
while any(any(strongly_thresh ~= old_thresh))
    old_thresh = strongly_thresh;
    strongly_thresh = weakly_thresh .* imdilate(strongly_thresh,neighborhood);
end

imf = strongly_thresh.*image;
end