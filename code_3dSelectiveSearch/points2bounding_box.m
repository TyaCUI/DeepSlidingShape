% Returns a tighly fitting 3D bounding box for the given set of points.
%
% Args:
%   points3d - Nx3 matrix of 3D points whose columns are the X, Y and Z axes respectively.
%
% Returns:
%   boundingBox3d - struct containing the attributes of the 3D bounding box.
%
% Author:
%   Nathan Silberman (silberman@cs.nyu.edu)
function boundingBox3d = points2bounding_box(points3d)  

  % Project everything to the 2d plane.
  bb2d = get_min_bounding_rectangle(points3d(:,1:2), 360);
  
  maxHeight = max(points3d(:,3));
  minHeight = min(points3d(:,3));
  midPointZ = (maxHeight - minHeight) / 2;
  
  centroid = [bb2d.centroid midPointZ + minHeight];
  coeffs = [bb2d.coeffs midPointZ];
  
  boundingBox3d = create_bounding_box_3d(bb2d.basis, centroid, coeffs);
end

% Finds the minimum bounding rectangle for a given set of 2D points using
% the rotating calipers method.
%
% Args:
%   points2d - Nx2 point cloud
%   numTheta - the number of angles to check.
%
% Returns:
%   bb2d - a 2D bounding box
%
% Author: Nathan Silberman (silberman@cs.nyu.edu)
function bb2d = get_min_bounding_rectangle(points2d, numTheta)
  assert(~isempty(points2d));

  if nargin < 2
    numTheta = 360;
  end
  
  DEBUG = 0;

  [N, D] = size(points2d);
  assert(D == 2, 'Expected 2D point cloud');

  % Pull the centroid before we shift everything to the origin.
  centroidOrig = mean(points2d);
  
  % Move the cloud to the mean.
  points2dCentered = points2d - repmat(centroidOrig, [N, 1]);
  
  % First, start by fitting the points using PCA.
  %basis = princomp(points2dCentered);
   basis = pca_m(points2dCentered');
  axis = basis(:,1);
  thetaAxis = atan2(axis(2), axis(1));
  
  % Show the prin axis.
  if DEBUG
    figure(1);
    vis_point_cloud(points2dCentered);
    vis_line(zeros(2,1), axis);
    title('Principle Axis');
    pause
  end
  
  % Now rotate the points so that the primary axis is aligned with the
  % positive X-axis.
  prinRot = [cos(-thetaAxis) -sin(-thetaAxis);
             sin(-thetaAxis)  cos(-thetaAxis);];
  points2dAligned = (prinRot * points2dCentered')';
  
  % Show the newly aligned point cloud.
  if DEBUG
    sfigure(2);
    vis_point_cloud(points2dAligned);
    title('Post alignment Axis');
    pause;
  end
  
  % Now that we have a starting point, find the bounding box with minimal
  % area.
  minArea = 10e10;
  rect = [];
  bestFitTheta = [];
  
  step = pi/(2*(numTheta-1));
  
  for theta = -pi/4 : step : pi/4
    
    % Rotate the points, not the basis. This will make it easier to fit a
    % rectangle to the points.
    R = [cos(theta) -sin(theta)
         sin(theta)  cos(theta)];
    points2dTmp = (R * points2dAligned')';
    
    % Now, find the axis aligned bounding box.
    minX = min(points2dTmp(:,1));
    maxX = max(points2dTmp(:,1));
    minY = min(points2dTmp(:,2));
    maxY = max(points2dTmp(:,2));
    
    if DEBUG
      sfigure(3);
      vis_point_cloud(points2dTmp);
      
      hold on;
      scatter(minX, minY, 30, 'b', 'filled');
      scatter(minX, maxY, 30, 'b', 'filled');
      scatter(maxX, minY, 30, 'b', 'filled');
      scatter(maxX, maxY, 30, 'b', 'filled');
      title(sprintf('Degrees=%f', 180*theta/pi));
      hold off;
      pause;
    end

    % Calculate the area.
    area = (maxY - minY) * (maxX - minX);
    if area < minArea
      if DEBUG
        sfigure(4);
        vis_point_cloud(points2dTmp);
        hold on;
        scatter(minX, minY, 30, 'b', 'filled');
        scatter(minX, maxY, 30, 'b', 'filled');
        scatter(maxX, minY, 30, 'b', 'filled');
        scatter(maxX, maxY, 30, 'b', 'filled');
        title('Best Fit');
        hold off;
      end
      
%       bestPoints = points2dTmp;
%       
      rect = [minX maxX minY maxY];
      minArea = area;
      bestFitTheta = theta;
    end
  end
  
  %%
  bb2d = struct();
  bb2d.basis = [1 0; 0 1];
  bb2d.coeffs = [(rect(2) - rect(1))/2 (rect(4) - rect(3))/2];
  
  % Pretend the centroid is really at 0. This is necessary for the
  % rotation to be correct.
  bb2d.centroid = bb2d.coeffs + [rect(1), rect(3)];

%   % Take a look
%   sfigure(6);
%   vis_point_cloud(bestPoints);
%   hold on;
%   corners = get_corners_of_bb2d(bb2d);
%   draw_square_2d(corners, 0, 'r');
%   hold off;
  
  % Now, perform 2 rotations to the axes.
  theta2 = thetaAxis - bestFitTheta;
  
  R = [cos(theta2) -sin(theta2);
       sin(theta2)  cos(theta2)];
     
%   bb2d1 = bb2d;
%      
%      
%   % Rotate the basis.
%   bb2d1.basis = (R * bb2d.basis')';
%      
%   % Center the points and rectangle.
%   zz = bb2d.centroid;
%   
%   pp1 = bestPoints;
%   pp1 = pp1 - repmat(zz, [size(pp1, 1), 1]);
%   bb2d1.centroid = zeros(1,2); % bb2d.centroid = bb2d.centroid - bb2d.centroid;
%   
%   % Now, rotate the points.
%   pp1 = (R * pp1')';
%   
%   % Re-draw
%   sfigure(7);
%   vis_point_cloud(pp1);
%   hold on;
%   corners = get_corners_of_bb2d(bb2d1);
%   draw_square_2d(corners, 0, 'r');
%   hold off;
%      
  
  %%
  yy = (R * bb2d.centroid')';
%   pp2 = pp1 + repmat(centroidOrig + yy, [size(pp1, 1) 1]);
%   
%   sfigure(8);
%   vis_point_cloud(points2d, 'b');
%   hold on;
%   vis_point_cloud(pp2);
%   hold off;
  
  %%
  
  bb2d.basis = (R * bb2d.basis')';
  bb2d.centroid = yy + centroidOrig;
  

  
  %%
  
  
end

% function basis = get_rot_basis(basis, theta)
%   R = [ cos(theta) sin(theta);
%        -sin(theta) cos(theta)];
%    
%   basis = (basis' * R)';
% end

