function [imageFinal, o] = image_generator (logs,varargin)

% interpret the input
o_base = struct( ...
    ...%%%%%%%% parameters for Brownian dynamics simulation %%%%%%%%%%%%%%%%
    'um_per_px', 0.0645 ...			    % resolution, microns per pixel
    ... 
    ...%%%%%%%% parameters for image generation %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    , 'box_size_px', [2 2 2].^8 ...  	% size of the images.
    , 'psf_type', 'g' ...            	% only gaussian psf ('g') is currently supported
    , 'psf_sigma_um', [0.4 0.4 0.7] ...  	% standard deviation of the psf in microns, indepedent for all three directions
    , 'renderer', 'points_from_nodes' ...  	%   'lines_from_bonds' or 'points_from_nodes'.
    ...
    , 'signal_level', 100 ...               %signal level above background
    , 'signal_background', 200 ...
    , 'counting_noise_factor', 1.327  ...   % counting noise  factor (noise = sqrt(o.counting_noise_factor*imageFinal).*randn(im_dims) 
    , 'dk_background',  189.462 ...   % dark background average
    , 'dk_noise', 7.265 ...           % dark noise rms(std)
    ...
    , 'finer_grid' , 3 ... %%% to more accurately simulate bead position
    , 'store_x', 1 ...
);


o = merge_ops(varargin, o_base);
o.num_frames = size(logs.x, 3);
o.n_dims = size(logs.x, 2);

% % check the simulation box size for nonsense input
% if isnan(o.sim_box_size_um)
%     o.sim_box_size_um = o.box_size_px*o.um_per_px;
% end
% assert(~any(o.sim_box_size_um < o.box_size_px*o.um_per_px));
% o.u_convection = merge_list(o.u_convection, [0 0 0 ]);

imageFinalSize = [o.box_size_px(1),o.box_size_px(2)]; % define output image size
imageFinal = zeros(imageFinalSize(1),imageFinalSize(2),o.num_frames); % define output image
o.box_size_px = o.box_size_px*o.finer_grid; % expand image to have finer grid
o.um_per_px = o.um_per_px/o.finer_grid; % recale calibration factor

%% adding PSF and noise to create the images

% Preallocate intermediate images (resized, and need to be resized back)
image = zeros(o.box_size_px(2),o.box_size_px(1),o.num_frames);


%%%%%%%%%%%% add the particles to the images, and the same time add signal background to images %%%%%%%%%%%
for t = 1:o.num_frames;    
    image(:,:,t) = image(:,:,t) + feval(o.renderer, logs.x(:,:,t), o); % same as point_from_nodes(state, o)
end


%%%%%%%%%%%% pick a psf %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(o.psf_type,'g')
    psf = @(f)convolveGaussianPSF(f,o.psf_sigma_um(1)/o.um_per_px);
elseif strcmp(PSFType,'l')
    psf = @(f) convolveGaussianLine(f,filter_size(1:2),o.psf_sigma_um(1)/o.um_per_px);
else
    psf = @(f) convolveAiry(f,filter_size(1:2),o.psf_sigma_um(1)/o.um_per_px);
end

%%%%%%%%%%%% Convolve new positions, resize back the image %%%%%%%%%%
for t = 1:o.num_frames

    image(:,:,t)  = psf(image(:,:,t)); % psf is a picked psf function

    imageFinal(:,:,t) = imresize(image(:,:,t),1/o.finer_grid,'bilinear'); % resize back the image  

end

o.box_size_px = o.box_size_px/o.finer_grid; % rescale back image size
o.um_per_px = o.um_per_px*o.finer_grid; % recale back calibrationfactor

%%%%%%%%%%% adding signal & noice %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
meanIntensity = mean(imageFinal(:)); % scale signal level
maxIntensity = max(imageFinal(:)); 
stdIntensity = std(imageFinal(:));
mean_bead_intensity = mean(imageFinal(imageFinal> (meanIntensity + maxIntensity)/2  ));

imageFinal_Binary = imageFinal> meanIntensity + (maxIntensity-meanIntensity)/3;


for i = 1 : o.num_frames%o.num_frames
    L = bwlabel(imageFinal_Binary(:,:,i));
    s  = regionprops(L, 'centroid');
    centroids = round(cat(1, s.Centroid));
    peaks_perframe = [];
    for j = 1 : size(centroids,1)
    peaks_perframe(j) = imageFinal(centroids(j,2),centroids(j,1),i);
    end
    mean_peak_intensity_perframe(i) = mean(peaks_perframe);
end
mean_beadpeak_intensity = mean(mean_peak_intensity_perframe);


intensity_rescale =o.signal_level/mean_beadpeak_intensity;
imageFinal = imageFinal*intensity_rescale;

imageFinal = imageFinal + o.signal_background;

imageFinal = imageFinal + sqrt(o.counting_noise_factor*imageFinal).*randn(imageFinalSize(1),imageFinalSize(2),o.num_frames); % add photon counting noise (signal noise)

imageFinal = imageFinal + o.dk_background + abs( o.dk_noise*randn(imageFinalSize(1),imageFinalSize(2),o.num_frames) ); % add dark backround and noise

