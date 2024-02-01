function b = AREstimation(y,p)
Y = y(p+1:end);
T = size(Y,1);
X = ones(T,1);

for j = 1:p
        X = [X y(p+1-j:end-j,:)];
end

% Column of ones of size T, which is the lenght of Y

b = inv(X'*X)*X'*Y