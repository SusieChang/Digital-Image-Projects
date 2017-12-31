function [mssim] = compute_ssim(img1, img2 )
% ssim_map - 图像加窗后得到
[M,N,b] = size(img1);
% 处理RGB情况
if b > 1
    img1 = rgb2ycbcr(img1);
    img2 = rgb2ycbcr(img2);
    img1 = img1(:,:,1);
    img2 = img2(:,:,1);
end
% 设置参数及有关常数
K1 = 0.01;
K2 = 0.03;
L = 255;
C1 = (K1*L)^2;
C2 = (K2*L)^2;
img1 = double(img1);
img2 = double(img2);
sigma = 1.5;
kernel_width = 11;
%图像加窗
% w = fspecial('gaussian', 11, 1.5);
% w = w/sum(sum(w));
%求高斯模板 
% w = [];                                        
% for i=1:kernel_width  
%     for j=1:kernel_width  
%         fenzi=double((i-N-1)^2+(j-N-1)^2);  
%         w(i,j)=exp(-fenzi/(2*sigma*sigma))/(2*pi*sigma);  
%     end  
% end  
% w=w/sum(w(:));  
% gx = filter2(w,img1,'valid');
% gy = filter2(w,img2,'valid');
gx = Guafilter2d(img1,sigma,kernel_width,'v');
gy = Guafilter2d(img2,sigma,kernel_width,'v');
num1 = 2*(gx.*gy) + C1;
den1 = (gx - gy).^2 + num1;
% gxy = filter2(w, img1.*img2, 'valid');
gxy = Guafilter2d(img1.*img2,sigma,kernel_width,'v');
num2 = 2*gxy + (C1+C2) - num1;
% gx_y = filter2(w, img1.^2+img2.^2, 'valid');
gx_y = Guafilter2d(img1.^2+img2.^2,sigma,kernel_width,'v');
den2 = gx_y+(C1+C2)-den1;                                                        
ssim_map = (num2.*num1)./(den2.*den1);   
mssim = mean2(ssim_map);
end

