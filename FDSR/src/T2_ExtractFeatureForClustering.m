%==========================================================================
% author: Susie Chang
% date: 17/12/25
% description: �����ȡһ��������LR Patchs �� HR Patchs����ȡFeature 
%==========================================================================

patchsize_half = (lr_patch_size-1)/2;
LRFeatures = zeros(max_feature,lr_dem);
HRFeatures = zeros(max_feature,hr_dem);
flag = 0;
count = 1;

% �������ڣ��ڵ�ǰĿ¼�в���һ����Ŀ¼��Patchs��
if ~exist('Features')
    mkdir('Features') 
end

% ��ȡ���ļ���������mat��ʽ��ͼ��
file_path =  'Patchs\';
img_path_list = dir(strcat(file_path,'*.mat'));
len = length(img_path_list);
% ����ͼƬ,�����ȡ
vec = randperm(len);
for i = 1 : len
    if flag == 1
        break;
    end
    name = img_path_list(vec(i)).name; 
    load(strcat(file_path,name));
    vec_l = randperm(label_idx-1); 
    n = round(label_idx*0.25); % �����ȡ�ٷ�֮25
    for j = 1 : n        
        if count > max_feature
            flag = 1;
            break;
        end
        s = vec_l(j);
        lr_patch = lr_patchs(:,:,1,s);
        vector_lr = lr_patch(lr_indexset);
        lr_mean = mean(vector_lr);
        lr_feature = vector_lr - lr_mean;
        hr_patch = hr_patchs(:,:,1,s);
        hr_f = hr_patch(cr_hr_sidx:cr_hr_eidx,cr_hr_sidx:cr_hr_eidx) - lr_mean; 
        hr_feature = reshape(hr_f,[hr_dem,1]);
        LRFeatures(count,:) = lr_feature;
        HRFeatures(count,:) = hr_feature;
        count = count + 1;
%         end
    end
end
save('Features/LRFeatures.mat','LRFeatures');
save('Features/HRFeatures.mat','HRFeatures');
disp(['Extract feature of LR and HR done. Total amount of every features:  ',num2str(count-1)]);