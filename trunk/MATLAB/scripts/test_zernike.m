%% Test Zernike moments

n = 2;
m = -2;

p = double(imread('~/Desktop//Spatial distribution/everywhere.tif'));
p = p(:,:,2);
mask = double(logical(imread('~/Desktop//Spatial distribution/mask_everywhere.tif')));
figure(1),subplot(2,3,1),imshow(p.*mask,[]);
title('Everywhere');
[~,AOH,phiOH] = Zernikmoment(p.*mask,n,m);
xlabel({['A = ' num2str(AOH)]; ['\phi = ' num2str(phiOH)]});

p = double(imread('~/Desktop//Spatial distribution/junctional.tif'));
p = p(:,:,2);
mask = double(logical(imread('~/Desktop//Spatial distribution/mask_junctional.tif')));
figure(1),subplot(2,3,2),imshow(p.*mask,[]);
title('Junctional');
[~,AOH,phiOH] = Zernikmoment(p.*mask,n,m);
xlabel({['A = ' num2str(AOH)]; ['\phi = ' num2str(phiOH)]});

p = double(imread('~/Desktop//Spatial distribution/medial.tif'));
p = p(:,:,2);
mask = double(logical(imread('~/Desktop//Spatial distribution/mask_medial.tif')));
figure(1),subplot(2,3,3),imshow(p.*mask,[]);
title('Medial');
[~,AOH,phiOH] = Zernikmoment(p.*mask,n,m);
xlabel({['A = ' num2str(AOH)]; ['\phi = ' num2str(phiOH)]});

p = double(imread('~/Desktop//Spatial distribution/everywhere_2.tif'));
p = p(:,:,2);
mask = double(logical(imread('~/Desktop//Spatial distribution/mask_everywhere_2.tif')));
figure(1),subplot(2,3,4),imshow(p.*mask,[]);
title('Everywhere 2');
[~,AOH,phiOH] = Zernikmoment(p.*mask,n,m);
xlabel({['A = ' num2str(AOH)]; ['\phi = ' num2str(phiOH)]});

p = double(imread('~/Desktop//Spatial distribution/junctional_2.tif'));
p = p(:,:,2);
mask = double(logical(imread('~/Desktop//Spatial distribution/mask_junctional_2.tif')));
figure(1),subplot(2,3,5),imshow(p.*mask,[]);
title('Junctional 2');
[~,AOH,phiOH] = Zernikmoment(p.*mask,n,m);
xlabel({['A = ' num2str(AOH)]; ['\phi = ' num2str(phiOH)]});

p = double(imread('~/Desktop//Spatial distribution/medial_2.tif'));
p = p(:,:,2);
mask = double(logical(imread('~/Desktop//Spatial distribution/mask_medial_2.tif')));
figure(1),subplot(2,3,6),imshow(p.*mask,[]);
title('Medial 2');
[~,AOH,phiOH] = Zernikmoment(p.*mask,n,m);
xlabel({['A = ' num2str(AOH)]; ['\phi = ' num2str(phiOH)]});

