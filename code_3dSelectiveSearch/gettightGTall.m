clear all;
load('/n/fs/modelnet/SUN3DV2/prepareGT/Metadata/SUNRGBDMeta.mat');
cnt =1;
addpath /n/fs/modelnet/SUN3DV2/prepareGT/;
setup_benchmark;

for imageNum =1:length(SUNRGBDMeta)
    imageNum
    data = SUNRGBDMeta(imageNum);
    [rgb,points3d,imgZ]=read3dPoints(data);
    data.groundtruth3DBB_tight = getTightGTBB(points3d,data.groundtruth3DBB);
    SUNRGBDMeta_tight(imageNum) =  data;
    
    for j =1:length(data.groundtruth3DBB_tight)
        groundtruth(cnt) = data.groundtruth3DBB_tight(j);
        cnt = cnt+1;
    end
end
SUNRGBDMeta = SUNRGBDMeta_tight;
save('/n/fs/modelnet/SUN3DV2/prepareGT/Metadata/SUNRGBDMeta_tight.mat','SUNRGBDMeta');
save('/n/fs/modelnet/SUN3DV2/prepareGT/Metadata/groundtruth_tight.mat','groundtruth');

%{
figure,
vis_point_cloud(points3d,rgb,10,10000);
hold on;
for bi =1:length(data.groundtruth3DBB)
    vis_cube(data.groundtruth3DBB(bi),'r');
end 
%}