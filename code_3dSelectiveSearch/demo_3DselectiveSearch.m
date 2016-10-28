
function demo_3DselectiveSearch()
        %% demo 
        seg_dir ='/n/fs/modelnet/deepDetect/seg/';
        ucmdir ='/n/fs/modelnet/deepDetect/ucm/';
        SUNrgbd_toolbox     = './external/SUNRGBDtoolbox/';
        addpath('./seg_plane');
        load([ '/n/fs/modelnet/SUN3DV2/prepareGT/Metadata/SUNRGBDMeta_tight_Yaw.mat']);

        imageNum =1;
        
        data = SUNRGBDMeta(imageNum);
        [rgb,points3d,imgZ]=read3dPoints(data);
        %% get segmetation 
        try 
            load([fullfile(seg_dir,data.sequenceName) '.mat'],'room','imageSeg_final')
        catch
            [imageSeg_final,room] = getSegmetation(points3d,size(imgZ),ucmdir);
        end
        %% get box from segmetation 
        [candidates3d] = genboxesfromSeg(points3d,rgb,room,imageSeg_final);       
end 
  

