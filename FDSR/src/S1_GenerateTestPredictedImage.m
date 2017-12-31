% =========================================================================
% Description：   输入低分辨率图片和要得到的高分辨率图片的长宽，输出超分辨率图片             
% Author：        Susie Chang
% Date：          17/12/30
% =========================================================================
function [img_hr] = S1_GenerateTestPredictedImage(img_lr,h_hr,w_hr,num_cluster)

% setting
[h_lr,w_lr] = size(img_lr);
lr_patch_size = 7;
scale = round(h_hr / h_lr);
lr_cr = 3;
hr_cr = lr_cr*scale;
lr_indexset = [2:6 8:42 44:48];
halfpatchsize = (lr_patch_size - 1) /2;
gap_hr = scale;
dist = gap_hr*2;
img_lr_ext = extend_boundary(img_lr,halfpatchsize);

cluster_path = 'Clusters/Cluster.mat'; %ClusterCenters,Idx
coef_path = 'Coefs/coef_matrix.mat'; %coef_matrix
load(cluster_path);
load(coef_path);

img_ext_b = imresize(img_lr_ext,scale);
[h_hr_ext, w_hr_ext] = size(img_ext_b);
 img_hr_ext = zeros(h_hr_ext,w_hr_ext);
 sum_patchs = zeros(h_hr_ext,w_hr_ext);


for rl = 1:h_lr
    for cl = 1:w_lr        
        rh = (rl - 1)*gap_hr +  dist + 1;
        ch = (cl - 1)*gap_hr +  dist + 1;
        rh2 = rh + hr_cr - 1;
        ch2 = ch + hr_cr - 1;
        patch_lr = img_lr_ext(rl:rl + lr_patch_size -1,cl:cl + lr_patch_size - 1);
            mean_lr = mean(patch_lr(lr_indexset));
            feature_lr = patch_lr(lr_indexset) - mean_lr;
            %找系数矩阵
            diff = repmat(feature_lr,[num_cluster,1]) - ClusterCenters;
            sd = sum((diff.^2));
            [~,best_idx] = find(sd==min(sd));
            coef = coef_matrix{best_idx};             
            if  nnz(coef > 10000)
                img_hr_ext(rh:rh2,ch:ch2) = img_hr_ext(rh:rh2,ch:ch2) + img_ext_b(rh:rh2,ch:ch2);               
            else
            v = [feature_lr,1];
            feature_hr = v * coef;
            patch_hr = reshape(feature_hr,[hr_cr,hr_cr]) + mean_lr;
            img_hr_ext(rh:rh2,ch:ch2) = img_hr_ext(rh:rh2,ch:ch2) + patch_hr;
            end
            sum_patchs(rh:rh2,ch:ch2)= sum_patchs(rh:rh2,ch:ch2) + 1;
    end
end     
img_hr_ext = img_hr_ext./ sum_patchs;
img_hr_ext = uint8(img_hr_ext);
extended_boundary_hr = halfpatchsize*scale;
img_hr = img_hr_ext(extended_boundary_hr+1:extended_boundary_hr + h_hr,extended_boundary_hr+1:extended_boundary_hr+w_hr);