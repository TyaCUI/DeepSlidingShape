function  postive_bb_tight = getTightGTBB(points3d,postive_bb,tile)
          cnt =1;
          
          for i = 1:length(postive_bb)
              isIntightBBall = ptsInTightBB(points3d,postive_bb(i));
              pts = points3d(isIntightBBall,:);
              pts = [postive_bb(i).basis*pts']';
              % remove 1% points in 3 dirction 
              removeId = zeros(sum(isIntightBBall),1);
              if ~exist('tile','var')
                 tile = 0.1;
              end
              for dim =1:3
                  out = pts(:,dim)>prctile(pts(:,dim),100-tile)|pts(:,dim)<prctile(pts(:,dim),tile);
                  removeId = removeId|out;
              end
              pts(removeId,:) = [];
              minLoc = nanmin(pts);
              maxLoc = nanmax(pts);
              centroid = [postive_bb(i).basis'*(0.5*(minLoc'+maxLoc'))]';
              if sum(isIntightBBall)>50
                 postive_bb_tight(cnt) = postive_bb(i);
                 postive_bb_tight(cnt).centroid = centroid;
                 postive_bb_tight(cnt).basis = postive_bb(i).basis;
                 postive_bb_tight(cnt).coeffs = 0.5*(maxLoc - minLoc);
                 cnt = cnt+1;
              end
          end
          if cnt ==1
             postive_bb_tight =[]; 
          end
          
end

