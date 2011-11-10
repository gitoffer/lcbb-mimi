function bvector = get_velocities(most_probable_model,varargin)

if ~isempty(varargin)
    threshold = varargin{1};
else
    threshold = 0;
end

[T,X,Y] = size(most_probable_model);
bvector = cell(T,1);

for i = 1:T
    
    v = nan(X,Y,2);
    for j = 1:X
        for k = 1:Y
            if (strcmpi(most_probable_model(i,j,k).Model,'convection_model') ...
                    || strcmpi(most_probable_model(i,j,k).Model,'mixed_model')) ...
                    && most_probable_model(i,j,k).model_probability > threshold
                
                this = convert(most_probable_model(i,j,k));
                v(j,k,1) = this.vx;
                v(j,k,2) = this.vy;
            end
        end
    end
    bvector{i} = v;
end
