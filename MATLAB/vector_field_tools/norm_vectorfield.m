function norm_field = norm_vectorfield(V)

Vx = V(:,:,1);
Vy = V(:,:,2);

norm_field = sqrt(Vx.^2 + Vy.^2);