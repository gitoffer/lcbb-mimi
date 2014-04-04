
everywhere = double(imread('~/Desktop//Spatial distribution/everywhere.tif'));
everywhere_2 = double(imread('~/Desktop//Spatial distribution/everywhere_2.tif'));
everywhere_3 = double(imread('~/Desktop//Spatial distribution/everywhere_3.tif'));
junctional = double(imread('~/Desktop//Spatial distribution/junctional.tif'));
medial = double(imread('~/Desktop//Spatial distribution/medial.tif'));
medial_2 = double(imread('~/Desktop//Spatial distribution/medial_2.tif'));
medial_3 = double(imread('~/Desktop//Spatial distribution/medial_3.tif'));
medial_4 = double(imread('~/Desktop//Spatial distribution/medial_4.tif'));
junctional_2 = double(imread('~/Desktop//Spatial distribution/junctional_2.tif'));
nothing = double(imread('~/Desktop//Spatial distribution/nothing.tif'));

%%

mask_everywhere = logical(imread('~/Desktop//Spatial distribution/mask_everywhere.tif'));
mask_everywhere_2 = logical(imread('~/Desktop//Spatial distribution/mask_everywhere_2.tif'));
mask_everywhere_3 = logical(imread('~/Desktop//Spatial distribution/mask_everywhere_3.tif'));
mask_junctional = logical(imread('~/Desktop//Spatial distribution/mask_junctional.tif'));
mask_medial = logical(imread('~/Desktop//Spatial distribution/mask_medial.tif'));
mask_medial_2 = logical(imread('~/Desktop//Spatial distribution/mask_medial_2.tif'));
mask_medial_3 = logical(imread('~/Desktop//Spatial distribution/mask_medial_3.tif'));
mask_medial_4 = logical(imread('~/Desktop//Spatial distribution/mask_medial_4.tif'));
mask_junctional_2 = logical(imread('~/Desktop//Spatial distribution/mask_junctional_2.tif'));
mask_nothing = logical(imread('~/Desktop//Spatial distribution/nothing.tif'));

%%

everywhere = everywhere.*mask_everywhere;
everywhere_2 = everywhere_2.*mask_everywhere_2;
everywhere_3 = everywhere_3.*mask_everywhere_3;
junctional = junctional.*mask_junctional;
medial = medial.*mask_medial;
medial_2 = medial_2.*mask_medial_2;
medial_3 = medial_3.*mask_medial_3;
medial_4 = medial_4.*mask_medial_4;
junctional_2 = junctional_2.*mask_junctional_2;
nothing = nothing.*mask_nothing;

%%

[mx,my] = center_of_image(everywhere);
[cx,cy] = center_of_image(mask_everywhere);
dev_everywhere = sqrt((mx-cx)^2 + (my-cy)^2);

[mx,my] = center_of_image(everywhere_2);
[cx,cy] = center_of_image(mask_everywhere_2);
dev_everywhere_2 = sqrt((mx-cx)^2 + (my-cy)^2);

[mx,my] = center_of_image(everywhere_3);
[cx,cy] = center_of_image(mask_everywhere_3);
dev_everywhere_3 = sqrt((mx-cx)^2 + (my-cy)^2);

[mx,my] = center_of_image(junctional);
[cx,cy] = center_of_image(mask_junctional);
dev_junctional = sqrt((mx-cx)^2 + (my-cy)^2);

[mx,my] = center_of_image(medial);
[cx,cy] = center_of_image(mask_medial);
dev_medial = sqrt((mx-cx)^2 + (my-cy)^2);

[mx,my] = center_of_image(medial_2);
[cx,cy] = center_of_image(mask_medial_2);
dev_medial_2 = sqrt((mx-cx)^2 + (my-cy)^2);

[mx,my] = center_of_image(medial_3);
[cx,cy] = center_of_image(mask_medial_3);
dev_medial_3 = sqrt((mx-cx)^2 + (my-cy)^2);

[mx,my] = center_of_image(medial_4);
[cx,cy] = center_of_image(mask_medial_4);
dev_medial_4 = sqrt((mx-cx)^2 + (my-cy)^2);

[mx,my] = center_of_image(junctional_2);
[cx,cy] = center_of_image(mask_junctional_2);
dev_junctional_2 = sqrt((mx-cx)^2 + (my-cy)^2);

[mx,my] = center_of_image(nothing);
[cx,cy] = center_of_image(mask_nothing);
dev_nothing = sqrt((mx-cx)^2 + (my-cy)^2);

%%

DEBUG = 0;

rcp_everywhere = image_inertia(everywhere,mask_everywhere,DEBUG);
rcp_everywhere_2 = image_inertia(everywhere_2,mask_everywhere_2,DEBUG);
rcp_everywhere_3 = image_inertia(everywhere_3,mask_everywhere_3,DEBUG);
rcp_junctional = image_inertia(junctional,mask_junctional,DEBUG);
rcp_medial = image_inertia(medial,mask_medial,DEBUG);
rcp_medial_2 = image_inertia(medial_2,mask_medial_2,DEBUG);
rcp_medial_3 = image_inertia(medial_3,mask_medial_3,DEBUG);
rcp_medial_4 = image_inertia(medial_4,mask_medial_4,DEBUG);
rcp_junctional_2 = image_inertia(junctional_2,mask_junctional_2,DEBUG);
rcp_nothing = image_inertia(nothing,mask_nothing,DEBUG);

%%

% C = varycolor(9);
C = [[1 0 0];[1 0 0];[1 0 0];...
    [0 1 0];[0 1 0];...
    [0 1 1];[0 1 1];[0 1 1];[0 1 1 ]];
scatter( ...
    [dev_everywhere,dev_everywhere_2,dev_everywhere_3, ...
    dev_junctional,dev_junctional_2, ...
    dev_medial,dev_medial_2,dev_medial_3,dev_medial_4], ...
    [rcp_everywhere,rcp_everywhere_2,rcp_everywhere_3, ...
    rcp_junctional,rcp_junctional_2, ...
    rcp_medial,rcp_medial_2,rcp_medial_3,rcp_medial_4], ...
    500,C,'filled');
xlabel('Deviation from centroid');
ylabel('Moment of inertia');


