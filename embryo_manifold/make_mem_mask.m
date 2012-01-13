function masked_img = make_mem_mask(raw_membrane,raw_img,im_params,mem_params)


mem_mask = sum(raw_membrane(:,:,5:Z),3);
mem_mask(mem_mask <= mean(mem_mask(:)) + ...
pr_params.mask_sigma_th*std(mem_mask(:))) = 0;
mem_mask(mem_mask ~= 0) = 1;

mem_mask = bwmorph(mem_mask,'thick',mem_params.thickness);
mem_mask = ~mem_mask;

if strcmpi(mem_params.display,'on')
	figure(10);clf;imagesc(mem_mask);
end

raw_myosin = raw_myosin.*mem_mask(:,:,ones(1,Z));
