%% Script to crop out single cells segmented by EDGE
% See also: load_from_edge, make_cell_img

% The image channels you want to include in your final movie. MUST USE the
% folder names used by EDGE's DATA_GUI folder; e.g. 'Membranes' or 'Myosin'
% or 'Actin'.
channels = {'Membranes','Myosin'};

% The variable 'input' is from the script load_from_edge.m

% 'vertices_x','vertices_y' are loaded from EDGE measurements. See
% load_from_edge.m

% The frames you want to make a movie out of... use num_frames for the
% total number of frames
frames = 1:num_frames;

% SliceID is the original slice number in the raw image stack (NOT the
% EDGE-exported stack number)
sliceID = 4;

% The cellID given by EDGE
cellID = 1;


F = make_cell_img(vertices_x,vertices_y,frames,sliceID,cellID,input,channels);

% Make an AVI output

% output_file = ['~/Desktop/cell_' num2str(cellID)];
% 
% movie2avi(F,output_file);