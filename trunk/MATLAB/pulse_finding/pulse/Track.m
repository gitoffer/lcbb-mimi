classdef Track
    properties (SetAccess = private)
        
        embryoID
        cellID
        stackID
        mdfID
        
        dev_frame
        dev_time
        img_frame
        
    end
    
    properties (SetAccess = public)
        
        trackID
        category
        
    end
    methods
        function obj = Track(this_track)
            if nargin > 0
                names = fieldnames(this_track);
                for i = 1:numel(names)
                    [obj.(names{i})] = deal(this_track.(names{i}));
                end
            end 
        end % constructor
        function obj = removePulse(obj)
            
            nbm.removeElement(obj,value,'fit')
            obj = [];
            
        end
    end
end