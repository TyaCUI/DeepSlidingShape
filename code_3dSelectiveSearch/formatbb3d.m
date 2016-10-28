function bbStructs = formatbb3d(bb3d,classname,imageNum)
    if size(bb3d,2) == 6,
        if exist('classname','var')
            ConstsDetection;
            [~,classId] = ismember(classname,consts.classNames);
            if isempty(classId), 
                error('class name %s not found',classname); 
            end
            if numel(classId) > 1, 
                error('multiple class name found'); 
            end
        else
            classId =0;
        end
        if ~exist('imageNum','var'); 
            imageNum=0;
        end
        basis = eye(3);
        centroid = num2cell(bb3d(:,1:3) + 0.5*bb3d(:,4:6), 2);
        coeffs = num2cell(0.5*bb3d(:,4:6), 2);
        imageNum = num2cell(imageNum(:));

        bbStructs = struct('basis',basis,'centroid',centroid,'coeffs',coeffs,...
                     'classId',classId,'imageNum',imageNum);

                 
    else
        if exist('classname','var')
            ConstsDetection;
            [~,classId] = ismember(classname,consts.classNames);
            if isempty(classId), 
                error('class name %s not found',classname); 
            end
            if numel(classId) > 1, 
                error('multiple class name found'); 
            end
        else
            classId =0;
        end
        if ~exist('imageNum','var'); 
        imageNum=0;
        end
        basis = eye(3);
        centroid = num2cell(bb3d(:,1:3) + 0.5*bb3d(:,4:6), 2);
        coeffs = num2cell(0.5*bb3d(:,4:6), 2);
        volume = num2cell(prod(bb3d(:,4:6),2));
        confidence = num2cell(bb3d(:,7));
        imageNum = num2cell(imageNum(:));

        bbStructs = struct('basis',basis,'centroid',centroid,'coeffs',coeffs,...
                     'volume',volume,'confidence',confidence,...
                     'classId',classId,'imageNum',imageNum);
    end
   
   
end