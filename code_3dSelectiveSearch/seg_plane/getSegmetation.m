function [imageSeg_final,room] = getSegmetation(points3d,imgZ,ucmdir,data)
        Space=struct('Rx',[nanmin(points3d(:,1)), nanmax(points3d(:,1))],...
                 'Ry',[nanmin(points3d(:,2)),nanmax(points3d(:,2))],...
                 'Rz',[nanmin(points3d(:,3)),nanmax(points3d(:,3))],'s',0.1);
        sizethr =50;
        [imageSeg,Rot]= getPlanSeg_complete(points3d,Space,size(imgZ),sizethr);
        [minZ,maxZ,minX,maxX,minY,maxY] = getRoom(points3d,imageSeg,Rot,0);
        room = struct('minZ',minZ,'maxZ',maxZ,'minX',minX,'maxX',maxX,'minY',minY,'maxY',maxY,'Rot',Rot);
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
        
end
