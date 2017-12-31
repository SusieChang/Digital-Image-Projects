clc;
clear all;
close all;
file_path =  'Set14\';% 图像文件夹路径
img_path_list = dir(strcat(file_path,'*.bmp'));%获取该文件夹中所有jpg格式的图像
len = length(img_path_list);%获取图像总数量
disp(['Name        ','PSNR          ','SSIM        ']);
for i = 1:len
%逐次取出文件
    name = img_path_list(i).name;% 图像名  
    HR =  imread(strcat(file_path,name));
    [w,h,s]=size(HR);
    lw = floor(w/3);
    lh = floor(h/3);
    LR = bicubic(HR,lw,lh);
    BI = bicubic(LR,w,h);
    PSNR = compute_psnr(HR,BI);
    SSIM = compute_ssim(HR,BI);
    disp([name(1:end-4),'      ',num2str(PSNR),'      ',num2str(SSIM)]);
    figure;subplot(1,2,1),imshow(HR),title('HR');
           subplot(1,2,2),imshow(LR),title('After bicubic');
end