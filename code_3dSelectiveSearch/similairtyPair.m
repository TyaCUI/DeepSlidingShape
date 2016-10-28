function similarity = similairtyPair(Pair_i,Pair_j,blobStruct)
         methodweight = blobStruct.methodweight;
         % s_size
         s_size = 1- (blobStruct.segSize(Pair_i)+blobStruct.segSize(Pair_j))/(blobStruct.imSize(1)*blobStruct.imSize(2));
        
         % s_fill
         bbsize_i = prod(blobStruct.BBs(4:6,Pair_i));
         bbsize_j = prod(blobStruct.BBs(4:6,Pair_j));
         BBcombine = [min([blobStruct.BBs(1:3,Pair_i),blobStruct.BBs(1:3,Pair_j)],[],2);...
                      max([blobStruct.BBs(4:6,Pair_i)+blobStruct.BBs(1:3,Pair_i),blobStruct.BBs(4:6,Pair_j)+blobStruct.BBs(1:3,Pair_j)],[],2)];
         BBcombine(4:6) = BBcombine(4:6)-BBcombine(1:3);
         bbsize_ij = prod(BBcombine(4:6));
         s_fill = 1- (bbsize_ij-bbsize_i-bbsize_j)/prod(blobStruct.rmSize);
         
         % s_sizeBB
         s_sizeBB = 1- bbsize_ij/prod(blobStruct.rmSize);
         
         % s_sizeBBtight
         if methodweight.sizetb>0
             if bbsize_ij>0.001
                 combinePoint = [blobStruct.pts{Pair_i};blobStruct.pts{Pair_i}];
                 bbtight = points2bounding_box(combinePoint);
                 s_sizeBBtight = 1- bbtight.volume/prod(blobStruct.rmSize);
             else
                 s_sizeBBtight = 1;
             end
         else
             s_sizeBBtight =1;
         end
         % s_color 
         s_color = sum(min([blobStruct.colourHist(:,Pair_i),blobStruct.colourHist(:,Pair_j)],[],2));
         
         similarity = methodweight.sizeb*s_sizeBB+...
                      methodweight.size*s_size+...
                      methodweight.fill*s_fill+...
                      methodweight.color*s_color+...
                      methodweight.sizetb*s_sizeBBtight;
         
end
