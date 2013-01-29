function output = get_physical_params(input)

output = input;

for i = 1:numel(input)
    switch input(i).model_name
        case 'diffusion_model'
            output(i).D = input(i).params(3);
        case 'flow_model'
            output(i).vy = input(i).params(3);
            output(i).vx = input(i).params(4);
        case 'mixed_model'
            output(i).D = input(i).params(3);
            output(i).vy = input(i).params(4);
            output(i).vx = input(i).params(5);
    end
end
end