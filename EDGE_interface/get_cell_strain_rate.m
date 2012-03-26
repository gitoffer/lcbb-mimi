function strain_rate = get_cell_strain_rate(shape_0,shape_f,area_constraint)
%GET_CELL_STRAIN_RATE
%
% xies@mit.edu March 2012.

% get parameters about measurement stack

target_area = polyarea(shape_0(:,1),shape_f(:,2));
initial_guess = .1*ones(4,1);
trace_constraint_matrix = [1 0 0 1];

%use fmincon
[strain_rate] = fmincon( ...
    @(params) abs(lsq_strained_area(params,shape_0)-target_area),... % FUN
    initial_guess, ... %X0
    [],[], ... %A,B inequality constraint
    trace_constraint_matrix, area_constraint ... %equality constraint
    );

end