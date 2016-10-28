function [candidates3d] = genboxesfromSeg(points3d,rgb,room,imageSeg_final)
        
        % get out of room points set them NaN
        Rot = room.Rot;
        points3d_align = [[Rot(1:2,1:2)*points3d(:,[1,2])']', points3d(:,3)];
        outside =points3d_align(:,1)<room.minX|points3d_align(:,1)>room.maxX|...
                 points3d_align(:,2)<room.minY|points3d_align(:,2)>room.maxY|...
                 points3d_align(:,3)<room.minZ|points3d_align(:,3)>prctile(points3d(:,3),90);

        outside = find(outside);
        points3d_align(outside,:) = NaN;
        imageSeg_final(find(isnan(points3d_align(:,1)))) = 0;
        uid = sort(unique(imageSeg_final(:)));
        for i=1:length(uid)
            if sum(imageSeg_final(:)==uid(i))<5
               imageSeg_final(imageSeg_final==uid(i)) =0;
            end
        end
        uid = sort(unique(imageSeg_final(:)));
        clear mapping
        mapping(uid+1) = [0,1:length(uid)-1];
        imageSeg_cleanup = mapping(imageSeg_final+1);

        % HierarchicalGrouping 
        sizeb_w =[0,0,0,0, 1];
        size_w  =[0,1,0,0, 1];
        fill_w  =[0,0,1,0,.1];
        color_w =[0,0,0,1, 1];
        sizetb_w=[1,0,0,0, 1];
        bbw = cell(1,length(color_w));
        for method_i  =1:length(color_w)
            methodweight = struct('sizeb',sizeb_w(method_i),'size',size_w(method_i),'fill',fill_w(method_i),'color',color_w(method_i),'sizetb',sizetb_w(method_i));
            [bbw{method_i},bbtightbox{method_i}] = HierarchicalGrouping(imageSeg_cleanup,points3d_align,rgb,methodweight);
        end
        bbw_align = cat(1,bbw{:});
        bbtightbox_align = cat(2,bbtightbox{:})';
        
        % add those extend to floor 
        minC = [bbw_align(:,1),bbw_align(:,2),room.minZ*ones(size(bbw_align(:,2)))];
        maxC = [bbw_align(:,4:6)+bbw_align(:,1:3)];
        bbw_align = [bbw_align;[minC,maxC-minC]];
        % nms 
        pick = nmsMe_3d([bbw_align(:,1:3),bbw_align(:,1:3)+bbw_align(:,4:6),zeros(size(bbw_align(:,2)))], 0.9);
        bbw_align = bbw_align(pick,:);
        candidates3d_align = formatbb3d(bbw_align);
        % combine
        bbtightbox_align = rmfield(bbtightbox_align,'volume');
        candidates3d_align = rmfield(candidates3d_align,{'imageNum','classId'});
        candidates3d_align = [candidates3d_align;bbtightbox_align(:)];
        for bi =1:length(candidates3d_align)
            candidates3d_align(bi).conf = 0;
        end
        pick= nms3d(candidates3d_align, 0.9);
        candidates3d_align = candidates3d_align(pick);
        % conver to word coordinate 
        candidates3d = candidates3d_align;
        for bi =1:length(candidates3d_align)
            candidates3d(bi).basis(1:2,1:2) = [Rot(1:2,1:2)'*candidates3d_align(bi).basis(1:2,1:2)']';
            candidates3d(bi).centroid(1:2) = [Rot(1:2,1:2)'*candidates3d_align(bi).centroid(1:2)']';
        end
        
        candidates3d = getTightGTBB(points3d,candidates3d);
        candidates3d = candidates3d(:);
end