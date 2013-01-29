function obj = select_constructor(model_name,varargin)

if isempty(varargin)
    switch model_name
        case 'convection_model'
            obj = ConvectionModel;
        case 'diffusion_model'
            obj = DiffusionModel;
        case 'mixed_model'
            obj = MixedModel;
        case 'noise_model'
            obj = NoiseModel;
        otherwise
            error('Model not regonized.');
    end
else
    if length(varargin) == 2
        p = varargin{1};
        ml = varargin{2};
        switch model_name
            case 'convection_model'
                obj = ConvectionModel(p,ml);
            case 'diffusion_model'
                obj = DiffusionModel(p,ml);
            case 'mixed_model'
                obj = MixedModel(p,ml);
            case 'noise_model'
                obj = NoiseModel(p,ml);
            otherwise
                error('Model not regonized.');
        end
    end
end

end