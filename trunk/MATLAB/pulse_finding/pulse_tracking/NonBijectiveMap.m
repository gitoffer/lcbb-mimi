classdef NonBijectiveMap
    % A class to handle non-bijective mapping between two Map objects.
    %
    % See also: MAP
    %
    % xies@mit.edu Feb 2013
    properties (SetAccess = private)
        dictAB
        dictBA
        nameA
        nameB
    end
    methods
        
        function obj = NonBijectiveMap(dictAB,dictBA,nameA,nameB)
            
            import containers.Map
            
            if ~strcmpi(class(dictAB),'Map') && strcmpi(class(dictBA),'Map');
                error('Need MAP objects as inputs.');
            end
            obj.dictAB = Map( dictAB.keys , dictAB.values );
            obj.dictBA = Map( dictBA.keys , dictBA.values );
            
            obj.nameA = nameA;
            obj.nameB = nameB;
            
        end % constructor
        
        function obj = Merge(obj,obj2)
            
            if ~strcmpi( obj.nameA,obj2.nameA ) || ~strcmpi( obj.nameB,obj2.nameB )
                error('Two NonBijectiveMaps must have the same names.');
            end
            
            mergedAB = merge_maps(obj.dictAB,obj2.dictAB);
            mergedBA = merge_maps(obj.dictBA,obj2.dictBA);
            
            obj.dictAB = mergedAB;
            obj.dictBA = mergedBA;
            
            function map = merge_maps(map,map2)
                keylist = map2.keys;
                for i = 1:numel(keylist)
                    if map.isKey(keylist{i})
                        error('CONFLICT MERGE found between maps.')
                    end
                    map(keylist{i}) = map2(keylist{i});
                end
            end % Merge/merge_maps
            
        end % Merge
        
        function obj = removeElement(obj,value,name)
            
            if strcmpi(name,obj.nameA)
                mapname = 'dictAB'; othername = 'dictBA';
            else
                mapname = 'dictBA'; othername = 'dictAB';
            end
            
            obj.(mapname).remove(value);
            
            vlist = obj.(othername).values;
            keylist = obj.(othername).keys;
            obj.(othername).remove( num2cell( keylist{cellfun(@(x) x == value,vlist)} ) );
            keyboard
        end
        
    end
        
end