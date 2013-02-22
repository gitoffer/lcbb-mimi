classdef Fitted
    properties (SetAccess = private)
        
        embryoID
        cellID
        stackID
        fitID
        amplitude
        center
        width
        margin_frames
        width_frames
        raw
        fit
        aligned_time
        aligned_time_padded
        fit_padded
        
    end
    properties (SetAccess = public)
        
        category
        
    end
    methods % Dynamic methods
        function obj = Fitted(this_fit)
            % Constructor - use from FIT_GAUSSIANS (array constructor)
            if nargin > 0
                names = fieldnames(this_fit);
                for i = 1:numel(names)
                    [obj.(names{i})] = deal(this_fit.(names{i}));
                end
            end 
        end % constructor
        
        function objs = get_fitID(obj_array,fitID)
            % Find the FIT(s) with the given fitID(s)
            objs = obj_array( ismember([ obj_array.fitID ], fitID) );
        end %get_fitID
        
        function objs = get_stackID(obj_array,stackID)
            % Find the FIT(s) with the given stackID(s)
            objs = obj_array( ismember([ obj_array.stackID ], stackID) );
        end %get_stackID
        
        function obj = removePulse(obj)
            
            nbm.removeElement(obj,value,'fit')
            obj = [];
            
        end
    end
end