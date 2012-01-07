function stack_est = run_wave_denoise_on_stack(stack_name,num_frames,channels,s)



stack = imread_multi(stack_name,num_frames,channels);
% [X,Y,~,~] = size(stack);
stack_est = zeros(size(stack));

for i = 1:num_frames
    for j = 1:channels
        [coeff,As] = wavelet_decompose(stack(:,:,i,j),s);
        stack_est(:,:,i,j) = wavelet_denoise(coeff,As);
    end
end

end