function embryo_structs = edge2embryo(EDGEstack)
%EDGE2EMBRYO Convers an EDGEstack (output of LOAD_EDGE_DATA) into an embryo-
% centric structure. The fields are the abbreviated names of each measurement
% and the field contents are the respective measurements.
%
% SYNOPSIS: embryo_structs = edge2embryo(EDGEstack,IDs);
%
% INPUT: EDGEstack - a NxM array of EDGE structure, where N is the number of
% 									 embryos and M the number of measurements
% 
% OUTPUT: embryo_structs - a N-dimensional vector of structs
%											  .(measurement) - the fieldnames are the measurement
%														
% xies@mit.edu

[num_embryos,num_meas] = size(EDGEstack);

% Preallocate structures
meas_fieldnames = make_valid_fieldname({EDGEstack(1,:).name});
embryo_structs(num_embryos) = cell2struct(cell(1,num_meas),meas_fieldnames,2);

for i = 1:num_embryos
    embryo_structs(i) = ...
        cell2struct({EDGEstack(i,:).data},meas_fieldnames,2);
    
end

end