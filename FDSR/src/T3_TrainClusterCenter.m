%==========================================================================
% Description: 加载特征向量训练聚类中心
% Author: Susie Chang
% Date: 17/12/25
%==========================================================================

% setting
count = 1;
num_iteration = 1000;
opts = statset('Display','iter','MaxIter',num_iteration);
flag = 0;
if ~exist('Clusters')
    mkdir('Clusters') 
end
% k-means
load('Features/LRFeatures.mat');
[Idx,ClusterCenters] = kmeans(LRFeatures,num_cluster,'emptyaction','drop','options',opts);  
figure;hist(Idx,num_cluster);
save('Clusters/Cluster.mat','ClusterCenters','Idx');
