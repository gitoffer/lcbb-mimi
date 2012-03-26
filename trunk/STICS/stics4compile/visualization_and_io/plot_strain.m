function plot_strain(E,imcrop,Xf,Yf,io)

EF = 1.5;
Xf = Xf*EF;
Yf = Yf*EF;

flat = @(x) x(:);

T = numel(E);
[X,Y,~,~] = size(E{1});

Psi = cell(T,1);
L = cell(T,1);
conds = zeros(X,Y,T,2);
% diagonalize strain matrix
for t = 1:T
    for i = 1:X
        for j = 1:Y
            ep(:,:) = E{t}(i,j,:,:);
            [d,lambda,conds(i,j,t,:)] = condeig(ep);
            Psi{t}(i,j) = atan(d(1,2)/d(1,1));
            L{t}(i,j,:,:) = lambda;
        end
    end
end

clear F;
figure(401)
B = zeros(T,X,Y);
for t = 1:T
    foo = imresize(imcrop(:,:,t),1.5);
    imshow(foo,[])
    hold all
    for i = 1:X
        for j = 1:Y
            
            [ellipse_x,ellipse_y] = get_ellipse(Xf(i,j),Yf(i,j),200*L{t}(i,j,1,1),200*L{t}(i,j,2,2),Psi{t}(i,j));
            A = get_ellipse_area(L{t}(i,j,1,1),L{t}(i,j,2,2));
            B(t,i,j) = A;
            C = find_color(A, -.0002,.0002);
            plot(ellipse_x,ellipse_y,'Color',C);
        end
    end
    drawnow
    F(t) = getframe;
    hold off
end

hist(flat(B),100)
movie(F);
movie2avi(F,[io.save_name '/strain' io.file_suffix]);
display('Saved strain movie to:')
display([io.save_name '/strain' io.file_suffix]);