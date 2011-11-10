function array = sort_models_by_prob(array)

if ~isstruct(array)
    error('Requires struct class data as input.')
end

if ~isvector(array)
    error('Need vector array input.');
end

probs = [array.model_probability];
[~,I] = sort(probs(:,:,:,:,:,:),'descend');
array = array(I);