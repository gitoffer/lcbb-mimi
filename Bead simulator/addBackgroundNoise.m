function matrix =addBackgroundNoise(matrix, coefficient)

% adds random numbers normally distributed with variance coefficeint*mean(image)
% to an image matrix

if coefficient > 0
noiseMatrix=abs(randn(size(matrix)));
matrix =matrix+coefficient*max(nonzeros(matrix))*noiseMatrix;
end