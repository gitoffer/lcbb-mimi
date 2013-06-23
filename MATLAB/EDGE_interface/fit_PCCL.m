function [edge_frame,img_frame,varargout] = fit_PCCL(embryo_struct,fields2fit)
%FIT_PCCL Fits piecewise continuous constant linear model to average myosin
% and average area in a single embryo. (Can specify other field(s).)
%
% USAGE: [edge_frames,img_frames] = fit_PCCL(embryo_struct);
%        [edge_frames,img_frames,xdata,models] = fit_PCCL(embryo_struct,fields2fit);
%        [edge_frames,img_frames,xdata,models,params] = fit_PCCL(embryo_struct,fields2fit);
%
% xies@mit.edu June 2013

if nargin < 2
    fields2fit = {'area','myosin_intensity_fuzzy'};
end

num_fields = numel(fields2fit);
input = embryo_struct.input;

% Extract relevant 'data-frames'/'edge-frames'
frames = 1:input.last_segmented - input.t0;
% Extract the correctly indexed time vector
xdata = embryo_struct.dev_time( frames );

% Preallocate
edge_frame = zeros(1,num_fields);
img_frame = zeros(1,num_fields);
params = zeros(2,num_fields);
models = zeros( numel(xdata),num_fields ); % T, measurement

for j = 1:num_fields
    
    fieldname = fields2fit{j};
    % Keep track of minresnorm
    minR2 = Inf;
    
    % Extract data with correct indexing, perform AVERAGING
    data2fit = nanmean( embryo_struct.(fieldname), 2)';
    data2fit = data2fit( frames );
    
    for i = 1:numel(xdata) - 2
        
        split = i + 1;
        guess = [nanmean(data2fit), nanmax(data2fit) - nanmin(data2fit)];
        
        % Perform LSQ / collect results
        opts = optimset('Display','off');
        [p,resnorm] = lsqcurvefit( @(p,x) lsq_PCCL(p,x,split), ...
            guess,xdata,data2fit, ...
            [0 -Inf],[Inf Inf],opts);
        y = lsq_PCCL(p,xdata,split);
        
        % Check for optimal split
        if resnorm < minR2
            minR2 = resnorm;
            models(:,j) = y;
            params(:,j) = p;
            edge_frame(j) = i + 1;
            img_frame(j) = edge_frame(j) + input.t0;
        end
        
    end
    
end

if ~ismember(nargout, [2 4 5]);
    error('2, 4, or 5 outputs');
end

if nargout > 2
    varargout{1} = xdata;
    varargout{2} = models;
    if nargout > 3
        varargout{3} = params;
    end

end