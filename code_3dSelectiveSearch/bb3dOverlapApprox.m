function overlaps = bb3dOverlapApprox(bb1,bb2struct)
% to run 
% bb1 =[0,0,0,1,1,1];load('bb3d'); bb3dOverlapApprox(bb1,bb3d);
    nBb1 = size(bb1,1);
    nBb2 = size(bb2struct,1);
    
    bb1(:,4:6) = bb1(:,4:6) + bb1(:,1:3);
    
    bb2 = zeros(nBb2,6);
    for i = 1:nBb2,
        corners = get_corners_of_bb3d(bb2struct(i));
        bb2(i,1) = min(corners(:,1));
        bb2(i,2) = min(corners(:,2));
        bb2(i,3) = min(corners(:,3));
        bb2(i,4) = max(corners(:,1));
        bb2(i,5) = max(corners(:,2));
        bb2(i,6) = max(corners(:,3));
    end
    
    volume1 = prod(bb1(:,4:6)-bb1(:,1:3),2);
    volume2 = prod(bb2(:,4:6)-bb2(:,1:3),2);
    
    overlaps = zeros(nBb1,nBb2);
    for i = 1:nBb2,
        xx1 = max(bb1(:,1), bb2(i,1));
        yy1 = max(bb1(:,2), bb2(i,2));
        zz1 = max(bb1(:,3), bb2(i,3));
        xx2 = min(bb1(:,4), bb2(i,4));
        yy2 = min(bb1(:,5), bb2(i,5));
        zz2 = min(bb1(:,6), bb2(i,6));
        
        intersection = max(0, xx2-xx1) .* max(0, yy2-yy1) .* max(0, zz2-zz1);
        overlaps(:,i) = intersection ./ (volume1 + volume2(i) - intersection);
    end
end