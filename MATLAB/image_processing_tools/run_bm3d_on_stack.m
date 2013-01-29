function imser_est = run_bm3d_on_stack(imser)

[n,m,T] = size(imser);
imser_est = zeros(n,m,T);

for i = 1:T
    [~,imser_est(:,:,i)] = BM3D(1,mat2gray(imser(:,:,i)));
end

end