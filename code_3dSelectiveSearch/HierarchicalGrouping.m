function [bbw,bbtightbox,groupRegoin] = HierarchicalGrouping(imageSeg,points3d_align,rgb,methodweight)
    % get neighborhood segments 
    uid = unique(imageSeg);
    uid = uid(uid~=0&uid~=1);
    
    neighbor = cell(1,length(uid));
    for i =1:length(uid)
        mask = imdilate(imageSeg==uid(i),strel('disk',4,4));
        thisneighbor = unique(imageSeg(mask&imageSeg~=uid(i)));
        thisneighbor = thisneighbor(thisneighbor>1&thisneighbor~=uid(i));
        if ~isempty(thisneighbor)
           neighbor{uid(i)} = thisneighbor;
        end
    end
    % for each regoin get the feature
    [BBs,segSize,pts] = BBsize(points3d_align,imageSeg,uid);
    colourHist = ColourHist(rgb,imageSeg,uid);
    
    blobStruct.BBs = BBs;
    blobStruct.pts = pts;
    blobStruct.colourHist = colourHist;
    blobStruct.segSize = segSize;
    blobStruct.imSize = size(imageSeg);
    blobStruct.rmSize = nanmax(points3d_align)-nanmin(points3d_align);
    blobStruct.methodweight = methodweight;
    
   
    groupRegoin ={};
    for i =1:length(uid)
       groupRegoin{end+1} = find((imageSeg(:)==uid(i)));
    end
    % for each pair get the initial similairty
    S =[];
    for Pair_i =1:length(neighbor)
        numNeig = length(neighbor{Pair_i});
        for np = 1:numNeig
            Pair_j = neighbor{Pair_i}(np);
            similarity = similairtyPair(Pair_i,Pair_j,blobStruct);
            S(end+1,:) = [Pair_i,Pair_j,similarity];
        end
    end
    
    % HierarchicalGrouping get all grouped regoin
    imageSeg_update = imageSeg;
    cnt = max(uid);
    while ~isempty(S)
      [~,ind] = sort(-1*S(:,3));
      S = S(ind,:);
      mergeregoin = S(1,:);
      % get new regoin 
      cnt = cnt+1;
      newRegoin = imageSeg_update==mergeregoin(1)|imageSeg_update==mergeregoin(2);
      groupRegoin{end+1} = find(newRegoin(:));
      % get new regoin feature 
      blobStruct = updateblobStruct(blobStruct,mergeregoin(1),mergeregoin(2),cnt);
      % remove the i,j similiarty 
      removeInd = ismember(S(:,1),mergeregoin(1:2))|ismember(S(:,2),mergeregoin(1:2));
      S(removeInd,:) =[];
      % add the new regoin similiarity
      imageSeg_update(newRegoin) = cnt;
      thisneighbor = findNeighborhoodSegments(imageSeg_update,cnt);
      % for each new neigbor add to similairy
      for kk= 1:length(thisneighbor)
           similarity = similairtyPair(cnt,thisneighbor(kk),blobStruct);
           S(end+1,:) = [cnt,thisneighbor(kk),similarity];
      end
    end
    % convert regoin to box 
   
    cnt = 1;
    for i =1:length(groupRegoin)
        pts_r = points3d_align(groupRegoin{i},:);
        BB = [nanmin(pts_r),nanmax(pts_r)-nanmin(pts_r)]';
        if size(pts_r,1)>50&&prod(BB(4:6))>0.005&&prod(BB(4:6))<0.8*prod(blobStruct.rmSize)
             bbw(cnt,:) = BB;
             bbtightbox(cnt) = points2bounding_box(pts_r);  
             
             cnt = cnt +1;
        end
    end

    %{
    figure,
    vis_point_cloud(points3d_align,rgb,10,10000);
    for bi =1:1:length(candidates3d_align)
        vis_cube(candidates3d_align(bi),rand(1,3));
    end
    %}
end

function colourHist = ColourHist(rgb,imageSeg,uid)
         colourHist = zeros(3*25,length(uid));
         for i =1:length(uid)
            color_r = rgb((imageSeg(:)==uid(i)),:);
            binc = 1/25:1/25:1;
            colorhist_r = [hist(color_r(:,1),binc),hist(color_r(:,2),binc),hist(color_r(:,3),binc)]';
            colourHist(:,uid(i)) = colorhist_r/(3*length(color_r));
         end
end

function [BBs,segSize,pts] = BBsize(points3d_align,imageSeg,uid)
         BBs = zeros(6,length(uid));
         segSize = zeros(1,length(uid));
         for i =1:length(uid)
             pts_r = points3d_align((imageSeg(:)==uid(i)),:);
             BBs(:,uid(i)) = [nanmin(pts_r,[],1),nanmax(pts_r,[],1)-nanmin(pts_r,[],1)]';
             segSize(uid(i)) = size(pts_r,1);
             pts{uid(i)} = pts_r;
         end
         
end