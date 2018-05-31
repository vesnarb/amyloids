function reconstructed_image = reconstructFast(deg, N, Z)
%N=size of image
%feature=moments

reconstructed_image = zeros(N, N);

% the whole code would be identical to recursiveZernike, except this fact 
% that instead of computing the Zernike moments, we add the component 
% <V_{n,m}, p> V_{n,m} to the reconstructed image.

x = 1:N; y = x;
[X,Y] = meshgrid(x,y);
R = sqrt((2.*X-N-1).^2+(2.*Y-N-1).^2)/N;
Theta = atan2((N-1-2.*Y+2),(2.*X-N+1-2));

mask = (R <= 1);
R = mask .*R;
R2 = R.^2;

total_features = size(Z, 2);

PowR = mask .* ones(size(R));
for m = 0:deg
    firstTerm = PowR;
    secondTerm = ((m + 2) * R2 - (m + 1)) .* PowR;
    for n = m:2:deg
        if n == m
            Rad = firstTerm;
        elseif n == m + 2
            Rad = secondTerm;
        else
            Rad = (2*(n-1)*(2*n*(n-2) * R2 - m^2 - n*(n-2)) .* secondTerm ...
                   - n*(n+m-2)*(n-m-2)*firstTerm) / ((n+m)*(n-m)*(n-2));
            firstTerm = secondTerm;
            secondTerm = Rad;
        end
        V = Rad .* exp(+1i * m * Theta);
        if mod(n, 2) == 0 
            pos = n*(n+2)/4 + m/2 + 1;
        else
            pos = (n+1)*(n+1)/4 + (m+1)/2;
        end
        % note. the zernike moments for negative and positive m's are
        % complex conjugates. Added together, one gets 2 * Real part of one
        % of them.
        if m ~= 0
            reconstructed_image = reconstructed_image + 2 * real(Z(pos) * V);
        else
            reconstructed_image = reconstructed_image + Z(pos) * V;
        end
    end
    PowR = PowR .* R;
end

end

