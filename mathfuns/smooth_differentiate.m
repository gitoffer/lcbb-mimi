function df = smooth_differentiate(f,method)


if ~exist('method','var')
    method = @sgolay;
end


filter = sgolay()