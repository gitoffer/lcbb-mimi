function I = find_earlierst_nonan(x)

I = find(~isnan(x),1,'first');

end