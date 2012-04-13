function [strain_rate,fval,flag] = get_cell_strain_rate(shape_0,shape_f,area_constraint)
%GET_CELL_STRAIN_RATE Uses FMINCON to calculate the most likley strain
% rate tensor that would yield a final shape given an initial shape. The
% shapes are parametrized as 'clouds of points'. The optimization criterion
% is the squared area-difference between the deformed shape, and the actual
% final shape. The strain rate volumetric change (trace of matrix) is
% constrained by the observed area change.
%
% USE: strain_rate =
%   get_cell_strain_rate(init_shape,final_shape,area_constraint) ;
%
% Reference: Blanchard, GB et al. Tissue tectonics: morphogenetic strain
%            rates, cell shape change and intercalation. Nature Methods
%            (2009).
%   http://www.nature.com/nmeth/journal/v6/n6/full/nmeth.1327.html
%
% xies@mit.edu March 2012.

% get parameters about measurement stack
target_area = polyarea(shape_0(:,1),shape_f(:,2));

% initial strain rate guess
initial_guess = zeros(4,1);
trace_constraint_matrix = [1 0 0 1];

%use fmincon
[strain_rate,fval,flag] = fmincon( ... 
    @(params) norm(lsq_strained_area(params,shape_0)-shape_f)^2, ...
    initial_guess, ... %X0
    [],[], ... %A,B inequality constraint
    trace_constraint_matrix, area_constraint ... %equality constraint
    );

% 
% @(params) (polyarea_wrapper(lsq_strained_area(params,shape_0))-target_area)^2 , ...

% Put into matrix
strain_rate = reshape(strain_rate,2,2);

    function area = polyarea_wrapper(shape)
        area = polyarea(shape(1,:),shape(2,:));
    end

end