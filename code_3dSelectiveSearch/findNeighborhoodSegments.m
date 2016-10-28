function thisneighbor = findNeighborhoodSegments(imageSeg,thisSegId)
        mask = imdilate(imageSeg==thisSegId,strel('disk',4,4));
        thisneighbor = unique(imageSeg(mask&imageSeg~=thisSegId));
        thisneighbor = thisneighbor(thisneighbor>0&thisneighbor~=thisSegId);
end