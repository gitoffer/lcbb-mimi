function dot_field = dot_vectorfields(V1,V2)

V1x = V1(:,:,1);
V1y = V1(:,:,2);
V2x = V2(:,:,1);
V2y = V2(:,:,2);

dot_field = V1x.*V2x + V1y.*V2y;