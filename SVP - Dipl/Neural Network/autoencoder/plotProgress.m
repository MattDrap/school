function plotProgress(theta, thetaSize, X, parameters)
% Plots the input data, reconstructed data, weight matrices, and biases.

[W1 W2 b1 b2] = theta2params(theta, thetaSize);
h = sigma(bsxfun(@plus, W1 * X(:,1:100), b1), parameters.activation{1})*(0.5*parameters.useDropout+(1-parameters.useDropout));
Xrec = sigma(bsxfun(@plus, W2 * h, b2), parameters.activation{2});
subplot(3,2,[3 4]); imagesc(h); colormap('gray'); title('Hidden layer activations')
if size(W1,2)==784 %MNIST
    subplot(3,2,1); displayData(X(:,1:100)',28,28); title('Input')
    subplot(3,2,2); displayData(Xrec(:,1:100)',28,28); title('Reconstruction')
    subplot(3,2,[5 6]); displayData(W1(1:50,:),28,28); title('W1')
elseif mod(sqrt(size(W1,2)/3),1)==0 % Probably Colorfilter
    subplot(3,2,1); displayColorNetwork(X(:,1:100)); title('Input')
    subplot(3,2,2); displayColorNetwork(Xrec(:,1:100)); title('Reconstruction')
    subplot(3,2,[5 6]); displayColorNetwork(W1'); title('W1')
elseif mod(sqrt(size(W1,2)/4),1)==0 % Probably Colorfilter + Heightmap
    subplot(3,2,1); displayColorNetwork(X(1:0.75*size(W1,2),1:100)); title('Input')
    subplot(3,2,2); displayColorNetwork(Xrec(1:0.75*size(W1,2),1:100)); title('Reconstruction')
    subplot(3,2,[5 6]); displayColorNetwork(W1(:,1:0.75*size(W1,2))'); title('W1')
else
    subplot(3,2,1); imagesc(X(:,1:100)); colormap('gray'); title('Input')
    subplot(3,2,2); imagesc(Xrec); colormap('gray'); title('Reconstruction')
    subplot(3,2,[5 6]); imagesc(W1); title('W1')
end
drawnow;

end

