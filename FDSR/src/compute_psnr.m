function [PSNR] = compute_psnr(img1, img2) 
[M,N,b] = size(img1);
if b > 1
    img1 = rgb2ycbcr(img1);
    img2 = rgb2ycbcr(img2);
    img1 = img1(:,:,1);
    img2 = img2(:,:,1);
end
diff =  double(img1) - double(img2);
MSE = mean2(diff.^2);
PSNR = 20*log10(255/sqrt(MSE));
end

