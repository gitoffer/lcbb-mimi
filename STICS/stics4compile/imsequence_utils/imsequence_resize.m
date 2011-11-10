function imseq_rescaled = imsequence_resize(imseq,scale)

[n,m,l] = size(imseq);

imseq_rescaled = zeros(n*scale,m*scale,l);

for i= 1:l
    imseq_rescaled(:,:,i) = imresize(imseq(:,:,i),scale);
end

end