clc;
clear all;
close all;
file_path =  'Set14\';% ͼ���ļ���·��
img_path_list = dir(strcat(file_path,'*.bmp'));%��ȡ���ļ���������jpg��ʽ��ͼ��
len = length(img_path_list);%��ȡͼ��������
disp(['Name        ','PSNR          ','SSIM        ']);
for i = 1:len
%���ȡ���ļ�
    name = img_path_list(i).name;% ͼ����  
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