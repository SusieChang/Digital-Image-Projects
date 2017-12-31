% =========================================================================
% Description��   ���Գ��ֱ��㷨��һ���ű���ע����Ҫ����sigma��scale�����޸ġ�             
% Author��        Susie Chang
% Date��          17/12/30
% =========================================================================
clc;
clear all;
close all;
%---------setting(��Ҫ����)-------------------------------------------------
% ��ʼ�������ã����޸ģ�Ӧ������������
sigma = 1.6;
scale = 3;
%--------------------------------------------------------------------------
lr_patch_size = 7;
lr_cr = 3;
lr_dem = lr_patch_size^2 - 4;
hr_patch_size = lr_patch_size*scale;
hr_cr = lr_cr*scale;
hr_dem = hr_cr^2;
lr_indexset = [2:6 8:42 44:48];
cr_hr_sidx = floor((hr_patch_size - hr_cr)/2) + 1;
cr_hr_eidx =  cr_hr_sidx + hr_cr - 1;
num_cluster = 520;
max_feature = 240000;
kernel_size = round(sigma*3)*2+1;
sigmal = double(sigma/3);
windowl = round(sigma*3)*2+1;
%----  training and learning(�޸Ĳ���������ѵ��ѧϰ)-------------------------
% T1_GenerateFDSRTrainPatchs
% T2_ExtractFeatureForClustering
% T3_TrainClusterCenter
% T4_TrainMappingFunction

%------------------testing-------------------------------------------------
file_path =  'Set14\';% ͼ���ļ���·��
img_path_list = dir(strcat(file_path,'*.bmp'));%��ȡ���ļ���������bmp��ʽ��ͼ��
len = length(img_path_list);%��ȡͼ��������
disp(['Name        ','PSNR          ','SSIM        ','Time']);
 for i = 1:len
%���ȡ���ļ�
    name = img_path_list(i).name;% ͼ����  
    HR = imread(strcat(file_path,name));%imread('Set14/lenna.bmp');%
    [h_hr,w_hr,b] = size(HR);
    if b > 1 % rgbͼ��
        YUV = rgb2ycbcr(HR);
        Y = YUV(:,:,1);
        U = YUV(:,:,2);
        V = YUV(:,:,3);           
        Yl = Guafilter2d(Y,sigma,kernel_size,'r');
        Yl = bicubic(Yl,h_hr/scale,w_hr/scale);
        Ul = bicubic(U,h_hr/scale,w_hr/scale);
        Vl = bicubic(V,h_hr/scale,w_hr/scale);
        t1 = clock;
        Yh = S1_GenerateTestPredictedImage(Yl,h_hr,w_hr,num_cluster);
        t2 = clock;
        t = etime(t2,t1);
        Uh = bicubic(Ul,h_hr,w_hr);
        Vh = bicubic(Vl,h_hr,w_hr);
        BI = cat(3,Yh,Uh,Vh);
        BI = ycbcr2rgb(BI);
    else % grayͼ��
        HRg = Guafilter2d(HR,sigma,kernel_size,'r');
        LR = bicubic(HRg,h_hr/scale,w_hr/scale);
        t1 = clock;
        BI = S1_GenerateTestPredictedImage(LR,h_hr,w_hr,num_cluster);
        t2 = clock;
        t = etime(t2,t1);
    end
    PSNR = compute_psnr(HR,BI);
    SSIM = compute_ssim(HR,BI);
    figure;
    subplot(1,2,1),imshow(HR),title('HR');
    subplot(1,2,2),imshow(BI),title('after super resolution');
    disp([name(1:end-4),'      ',num2str(PSNR),'      ',num2str(SSIM),'      ',num2str(t)]);
end