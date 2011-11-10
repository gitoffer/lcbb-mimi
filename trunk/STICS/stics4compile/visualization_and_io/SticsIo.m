classdef SticsIo
    properties
        folder
        file_name
        file_suffix
        save_name
        sticsSaveName
        custom
    end
    methods
        function obj = SticsIo(imname,folder_stem,o,custom)
            
            obj.folder = folder_stem;
            obj.file_suffix = ['_ch',num2str(o.ch),'_wt',int2str(o.wt),'_wx',int2str(o.wx),'_dt',int2str(o.dt)];
            obj.save_name = [folder_stem,imname,obj.file_suffix,custom];
            mkdir(obj.save_name);
            obj.sticsSaveName = [obj.save_name,'/stics',obj.file_suffix,custom];
            
            display('Loaded data set:');
            display(imname)
            display('Will save data to:')
            display(obj.sticsSaveName)
            
        end
    end
end