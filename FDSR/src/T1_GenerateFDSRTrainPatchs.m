% =========================================================================
% 描述：   产生训练样本，将高分辨率图片高斯滤波后下采样指定倍率得到低分辨率图像,
%          高低分辨率图像中提取图像块作为样本，按图片分块重新存储                
%          (56,12,4) 
% 作者：    Susie Chang
% 日期：    17/12/25
% =========================================================================

%---------setting----------------------------------------------------------
gap_lr = 2; % 为了减少分块数量，设置每隔gap个像素点切块
label_idx = 1;
count = 0;
% 若不存在，在当前目录中产生一个子目录‘Patchs’
if ~exist('Patchs')
    mkdir('Patchs') 
end
%----------read data-------------------------------------------------------

%获取该文件夹中所有jpg格式的图像
file_path =  'Train\';
img_path_list = dir(strcat(file_path,'*.jpg'));
len = length(img_path_list);
for k = 1:len
    %逐次取出文件
    name = img_path_list(k).name;   % image name  
    HR =  imread(strcat(file_path,name));   
    YUV = rgb2ycbcr(HR);            % get YUV picture
    Y = YUV(:,:,1);                 % extract intensity layer
    glr = Guafilter2d(Y,sigma,kernel_size,'r');       % gaussian convolution
    [h_hr,w_hr] = size(Y);
    h_lr = floor(h_hr/scale);
    w_lr = floor(w_hr/scale);
    LR = bicubic(glr,h_lr,w_lr);     %downsample
    num_max_row = floor((h_lr - lr_patch_size) / gap_lr) + 1;  
    num_max_col = floor((w_lr - lr_patch_size) / gap_lr) + 1;
    gap_hr = floor((h_hr - hr_patch_size) / (num_max_row - 1));
    lr_patchs = zeros(lr_patch_size,lr_patch_size,1,1);
    hr_patchs = zeros(hr_patch_size,hr_patch_size,1,1);
    lr_mean = zeros(1,1);
    % 分块
    label_idx = 1;
    for i = 1:num_max_row
        for j = 1:num_max_col   
            rl = 1 + gap_lr*(i - 1);
            cl = 1 + gap_lr*(j - 1);
            rl2 = rl + lr_patch_size - 1;
            cl2 = cl + lr_patch_size - 1;
            rh = 1 + gap_hr*(i - 1);
            ch = 1 + gap_hr*(j - 1);
            rh2 = rh + hr_patch_size - 1;
            ch2 = ch + hr_patch_size - 1;
            lr_patch = LR(rl:rl2,cl:cl2);
            lr_patchs(:,:,1,label_idx) = lr_patch;
            hr_patchs(:,:,1,label_idx) = Y(rh:rh2,ch:ch2);                 
            label_idx = label_idx+1;
            count = count + 1;
        end   
    end
    disp([name(1:end-4),' ' , num2str(count)]);
    save(['Patchs/',name(1:end-4),'.mat'],'lr_patchs','hr_patchs','label_idx');
end 
disp('Generate train patchs done.');

