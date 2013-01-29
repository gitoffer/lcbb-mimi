function thresholded = threshold_stack(stack,threshold)
%THRESHOLD_STACK
%
% SYNOPSIS: im_th = thresolded_stack(stack,th);
%
% xies@mit.edu

thresholded = stack*0;
thresholded(stack > threshold) = stack(stack > threshold);

end