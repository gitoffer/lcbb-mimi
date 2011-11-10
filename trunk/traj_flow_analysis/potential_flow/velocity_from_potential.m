function [Vx,Vy] = velocity_from_potential(W)

Vx = real(gradient(W));
Vy = -imag(gradient(W));