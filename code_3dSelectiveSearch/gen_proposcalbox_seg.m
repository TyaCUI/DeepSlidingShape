function gen_proposcalbox_seg(id)
% 
%  cd /n/fs/modelnet/deepDetect/code/gen_proposal/
% /n/fs/vision/ionicNew/starter.sh gen_proposcalbox_seg 7500mb 165:00:00 1 300 1 
load('/n/fs/modelnet/SUN3DV2/prepareGT/traintestSUNRGBD/test_kv1NYU.mat')
load('/n/fs/modelnet/SUN3DV2/prepareGT/traintestSUNRGBD/train_kv1NYU.mat')

allPath = [trainSeq,testSeq];
if ~exist('id','var')
    imageNums = 1:length(allPath);
else
    imageNums =id:300:length(allPath);
end

load([ '/n/fs/modelnet/SUN3DV2/prepareGT/Metadata/SUNRGBDMeta_tight_Yaw.mat']);
load('/n/fs/modelnet/SUN3DV2/prepareGT/cls')
addpath /n/fs/modelnet/slidingShape_release_all/code_benchmark
addpath('/n/fs/modelnet/SUN3DV2/roomlayout/');
addpath('./HierarchicalGrouping');
initPath;
seg_dir ='/n/fs/modelnet/deepDetect/seg/';
ucmdir ='/n/fs/modelnet/deepDetect/ucm/';
proposal_dir = '/n/fs/modelnet/deepDetect/proposal/rgbd_tight/';
replace =0;


show =0;

for imageNum = imageNums
    %fullpath2seq = allPath{imageNum};
    %data = readframeSUNRGBD(fullpath2seq,[],cls);
    data = SUNRGBDMeta(imageNum);
    [rgb,points3d,imgZ]=read3dPoints(data);
    % get segmentation room rotation, segmentation 
    try 
         load([fullfile(seg_dir,data.sequenceName) '.mat'],'imageSeg','room');
    catch
        fprintf('%d compute seg %s...\n',imageNum, fullfile(seg_dir,data.sequenceName))
        Space=struct('Rx',[nanmin(points3d(:,1)), nanmax(points3d(:,1))],...
                     'Ry',[nanmin(points3d(:,2)),nanmax(points3d(:,2))],...
                     'Rz',[nanmin(points3d(:,3)),nanmax(points3d(:,3))],'s',0.1);
        sizethr =50;
        [imageSeg,Rot]= getPlanSeg_complete(points3d,Space,size(imgZ),sizethr);
        room.Rot = Rot;
        tosavepath = fullfile(seg_dir,data.sequenceName);
        ind = find(tosavepath =='/');
        mkdir(tosavepath(1:ind(end)));
        save([fullfile(seg_dir,data.sequenceName) '.mat'],'imageSeg','room')
    end

    %%
    tosavepathCand = [fullfile(proposal_dir,data.sequenceName) '.mat'];
    if ~exist(tosavepathCand,'file')||replace
        %% get room
        [minZ,maxZ,minX,maxX,minY,maxY] = getRoom(points3d,imageSeg,room.Rot,0);
        room = struct('minZ',minZ,'maxZ',maxZ,'minX',minX,'maxX',maxX,'minY',minY,'maxY',maxY,'Rot',room.Rot);
        
        L = bwlabel(imgZ~=0&imageSeg==0);
        L(imgZ==0) = 0;
        imageSegfull = imageSeg;
        imageSegfull(L~=0) = max(imageSeg(:))+L(L~=0);
        if exist([fullfile(ucmdir,data.sequenceName) '.mat'],'file')
            imageSeg_ucm= ucm2seg(fullfile(ucmdir,data.sequenceName),0.2);
            imageSeg_divided = divideBigSeg(imageSegfull,imageSeg_ucm);
            imageSeg_final = imageSeg_divided;
        else
            imageSeg_final =imageSegfull;
            fprintf('missing ucm %s\n',fullfile(ucmdir,data.sequenceName))
        end
        fprintf('save imageSeg_final %s...\n',fullfile(proposal_dir,data.sequenceName))
        save([fullfile(seg_dir,data.sequenceName) '.mat'],'room','imageSeg','imageSeg_final');
        
        fprintf('computing image %s...\n',fullfile(proposal_dir,data.sequenceName))
        [candidates3d] = genboxesfromSeg(points3d,rgb,room,imageSeg_final,data);        
        
        %% eval
        postive_bb = data.groundtruth3DBB;
        postive_bb_tight =data.groundtruth3DBB_tight;
        eval = struct('GTmaxOverlap_t',[],'bestCand_t',[],...
                      'GTmaxOverlap',[],'bestCand',[]);
        if isempty(postive_bb)
            oscf = zeros(size(candidates3d,1),1);
        else
            oscfM=bb3dOverlapCloseForm(candidates3d,postive_bb');
            [GTmaxOverlap,bestCand] = max(oscfM);
            [oscf,matchgt] = max(oscfM,[],2);
        end
        if isempty(postive_bb_tight)
            oscf_t = zeros(size(candidates3d,1),1);
        else 
            oscfM_t=bb3dOverlapCloseForm(candidates3d,postive_bb_tight');
            [GTmaxOverlap_t,bestCand_t] = max(oscfM_t);
            [oscf_t,matchgt_t] = max(oscfM_t,[],2);
            eval = struct('GTmaxOverlap_t',GTmaxOverlap_t,'bestCand_t',bestCand_t,...
                     'GTmaxOverlap',GTmaxOverlap,'bestCand',bestCand);
                 
        end
        

        for bi =1:length(candidates3d)
            candidates3d(bi).ioufull = oscf(bi);
            candidates3d(bi).iou = oscf_t(bi);
            if candidates3d(bi).iou >0
               candidates3d(bi).classname = postive_bb(matchgt_t(bi)).classname;
            else
               candidates3d(bi).classname = 'negative';
            end
        end
        
        %% save
        ind = find(tosavepathCand =='/');
        mkdir(tosavepathCand(1:ind(end)));
        save(tosavepathCand,'candidates3d','eval');
    else
        fprintf('skipng image %s...\n',fullfile(proposal_dir,data.sequenceName))
        load([fullfile(proposal_dir,data.sequenceName) '.mat'])
    end
    %{
    fprintf('image : %d total box: %d average ABO: %f average ABO_t: %f recall: %f\n',...
            imageNum,length(candidates3d), mean(eval.GTmaxOverlap),mean(eval.GTmaxOverlap_t),mean(eval.GTmaxOverlap_t>0.25));
    total(imageNum,:) = [length(candidates3d),mean(eval.GTmaxOverlap),mean(eval.GTmaxOverlap_t)];
    GTmaxOverlapall{imageNum} = eval.GTmaxOverlap;
    GTmaxOverlap_tall{imageNum} = eval.GTmaxOverlap_t;
    %}
    if show
        %{
        figure,
        vis_point_cloud(points3d,rgb,10,10000);
        points3d_align = [[room.Rot(1:2,1:2)*points3d(:,[1,2])']', points3d(:,3)];
        figure,
        vis_point_cloud(points3d_align,rgb,10,10000);
        
        %}
        f =figure;
        vis_point_cloud(points3d,rgb,10,5000);
        
        hold on;
        for bi =1:length(data.groundtruth3DBB_tight)
            vis_cube(data.groundtruth3DBB_tight(bi),'r',2);
            vis_cube(candidates3d(eval.bestCand_t(bi)),[0.6824,0.7804,0.9098],2);
        end 
        axis off;

        saveas(f,[ proposal_dir '/figures/' num2str(imageNum) '.jpg']);
        close(f)
        
    end 
    
        
           
    
end   
save([proposal_dir '_total.mat'],'GTmaxOverlapall','GTmaxOverlap_tall','total');
recall = mean(cat(2,GTmaxOverlapall{:})>0.25);
recall_t = mean(cat(2,GTmaxOverlap_tall{:})>0.25);
averbox = mean(total(:,1));
fprintf ('average num of box : %f\nrecall:%f, recall_t: %f\naverage ABO: %f average ABO_t: %f\n'...
         ,averbox,recall,recall_t,nanmean(cat(2,GTmaxOverlapall{:})),nanmean(cat(2,GTmaxOverlap_tall{:})));
end
