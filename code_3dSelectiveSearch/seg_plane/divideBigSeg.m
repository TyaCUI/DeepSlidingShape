function imageSeg_divided = divideBigSeg(imageSegtodivide,imageSegrefer)
maxind = max(imageSegtodivide(:));
imageSeg_divided = imageSegtodivide;
uid = sort(unique(imageSegtodivide(:)));
imsize = numel(imageSegtodivide);
for i=1:length(uid)
    if sum(imageSegtodivide(:)==uid(i))>0.1*imsize&&uid(i)~=0
       mask = imageSegtodivide ==uid(i);
       segpart = imageSegrefer(mask);
       uind_p = unique(segpart(segpart~=0));
       map(uind_p) = [maxind+[1:length(uind_p)]];
       map = [maxind+length(uind_p)+1,map];
       maxind = maxind + length(uind_p)+1;
       imageSeg_divided(mask) = map(imageSegrefer(mask)+1);
    end
end
        


end