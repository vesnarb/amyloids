function Rads = precomputeZernikeBasis(N, deg)

x = 1:N; y = x;
[X,Y] = meshgrid(x,y);
R = sqrt((2.*X-N-1).^2+(2.*Y-N-1).^2)/N; %x = column number, Y= row number
Theta = atan2((N-1-2.*Y+2),(2.*X-N+1-2));

mask = (R<=1);
R = mask .* R;
R2 = R.^2;

if mod(deg, 2) == 0
    num_of_polys = (deg + 2)^2 / 4;
else
    num_of_polys = (deg + 1) * (deg + 3) / 4;
end

Rads = zeros(N, N, num_of_polys);


PowR = mask .* ones(size(R));   % for each m, it represents R^m
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
        if mod(n, 2) == 0 %if n is even
            pos = n*(n+2)/4 + m/2 + 1;
        else
            pos = (n+1)*(n+1)/4 + (m+1)/2;
        end
        Rads(:, :, pos) = Rad .* exp(-1i * m * Theta);
    end
    PowR = PowR .* R;
end

end


