%==========================================================================
% Description: ÑµÁ·µÃµ½Ó³Éäº¯Êý
% Author: Susie Chang
% Date: 17/12/26
%==========================================================================
% setting
lr_path = 'Features/LRFeatures.mat';
hr_path = 'Features/HRFeatures.mat';
cluster_path = 'Clusters/Cluster.mat';
coef_matrix = cell(1,num_cluster);
num_per_cluster = zeros(1,num_cluster); 
% initialization
if ~exist('Coefs')
    mkdir('Coefs') 
end

load(lr_path);  % load LRFeatures
load(hr_path);  % load HRFeatures
load(cluster_path); % load ClusterCenter

for label = 1 : num_cluster
    V = LRFeatures(Idx == label,:);
    W = HRFeatures(Idx == label,:);
    num = sum(Idx(:) == label);
    Va = [V,ones(num,1)];
    if ~isempty(V)
        coef_matrix{label} = Va \ W;
        num_per_cluster(label) = num;
    end
end
save('Coefs/coef_matrix','coef_matrix','num_per_cluster');
disp('Train Mapping Function done.');