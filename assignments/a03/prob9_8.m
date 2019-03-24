% Question 9.8 from the text book

function ex9_8

cimage = input('Enter name of image: ','s');
im = imread(cimage);

% reconstruct with 4 coefficients
[im_r,N,psnr] = coeff9_8(im,4);
figure(1)
imshow(uint8(im_r))
title(sprintf('4 coefficients (PSNR = %.4f, %d nonzero coefficients in total)',...
    psnr, N))
print -deps2 lena_4

% reconstruct with 8 coefficients
[im_r,N,psnr] = coeff9_8(im,8);
figure(2)
imshow(uint8(im_r))
title(sprintf('8 coefficients (PSNR = %.4f, %d nonzero coefficients in total)',...
    psnr, N))
print -deps2 lena_8

% reconstruct with 16 coefficients
[im_r,N,psnr] = coeff9_8(im,16);
figure(3)
imshow(uint8(im_r))
title(sprintf('16 coefficients (PSNR = %.4f, %d nonzero coefficients in total)',...
    psnr, N))
print -deps2 lena_16

% reconstruct with 32 coefficients
[im_r,N,psnr] = coeff9_8(im,32);
figure(4)
imshow(uint8(im_r))
title(sprintf('32 coefficients (PSNR = %.4f, %d nonzero coefficients in total)',...
    psnr, N))
% 32*prod(size(im))/64)
print -deps2 lena_32

% Compute the reconstructed image with different numbers of coefficients
% input:     im -- original image
%             k -- number of retained coefficients
% output:  im_r -- reconstructed image
%             N -- number of nonzero coefficients
%          psnr -- psnr of the reconstructed image

function [im_r,N,psnr] = coeff9_8(im,k)

im = double(im);

a = ones(1,k);
im_c = blkproc(im,[8,8],'round(dct2(x)).*P1',zigzag(a,8));
N = length(find(im_c ~= 0));
im_r = blkproc(im_c,[8,8],'idct2');
psnr = 10*log10(255*255/mean(mean((im - im_r).^2)));

% vector a --> square matrix b (sizeb-by-sizeb) in zigzag order
function b = zigzag(a,sizeb)

b = zeros(sizeb,sizeb);
n = 0;

if length(a) < sizeb^2
    a = [a, zeros(1,sizeb^2-length(a))];
else 
    a = a(1:sizeb^2);
end

for k = 1:sizeb
    n = n+k-1;
    for i = 1:k
        if rem(k,2)==0 
            b(i,k+1-i) = a(n+i);
        else 
            b(k+1-i,i) = a(n+i);
        end
    end
end
for k = 2:sizeb
    n = n+sizeb+1-k;
    for i = k:sizeb
        if rem((sizeb-k),2)==0 
            b(k+sizeb-i,i) = a(n+i);
        else 
            b(i,k+sizeb-i) = a(n+i);
        end
    end
end