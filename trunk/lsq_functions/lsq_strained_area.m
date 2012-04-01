function new_shape = lsq_strained_area(params,old_shape)
%LSQ_STRAINED_AREA
%
%

N = size(old_shape,2);

dudx = params(1);
dvdx = params(2);
dudy = params(3);
dvdy = params(3);

F = [[dudx dudy];[dvdx dvdy]];

new_shape = zeros(size(old_shape));
for i = 1:N
    new_shape(:,i) = F*old_shape(:,i);
end

% def_area = polyarea(new_shape(:,1),new_shape(:,2));

end