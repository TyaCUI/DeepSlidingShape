function blobStruct = updateblobStruct(blobStruct,Pair_i,Pair_j,newind)
blobStruct.segSize(newind) = blobStruct.segSize(Pair_i)+blobStruct.segSize(Pair_j);

BBcombine = [min([blobStruct.BBs(1:3,Pair_i),blobStruct.BBs(1:3,Pair_j)],[],2);...
          max([blobStruct.BBs(4:6,Pair_i)+blobStruct.BBs(1:3,Pair_i),blobStruct.BBs(4:6,Pair_j)+blobStruct.BBs(1:3,Pair_j)],[],2)];
BBcombine(4:6) = BBcombine(4:6)-BBcombine(1:3);
blobStruct.BBs(:,newind) = BBcombine;

w_i = blobStruct.segSize(Pair_i)/blobStruct.segSize(newind);
w_j = blobStruct.segSize(Pair_j)/blobStruct.segSize(newind);
blobStruct.colourHist(:,newind) = w_i*blobStruct.colourHist(:,Pair_i)...
                                 +w_j*blobStruct.colourHist(:,Pair_j);
                             
blobStruct.pts{newind} = [blobStruct.pts{Pair_i};blobStruct.pts{Pair_j}];
blobStruct.pts{Pair_i} = [];
blobStruct.pts{Pair_j} = []; 

end