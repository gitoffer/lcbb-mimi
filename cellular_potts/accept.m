function result = accept(P)
%ACCEPT Metropolis step
%
% xies@mit.edu Spring 20.415

R = rand(1);

result = P >= R;
