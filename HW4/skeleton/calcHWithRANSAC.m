function H = calcHWithRANSAC(p1, p2)
% Returns the homography that maps p2 to p1 under RANSAC.
% Pre-conditions:
%     Both p1 and p2 are nx2 matrices where each row is a feature point.
%     p1(i, :) corresponds to p2(i, :) for i = 1, 2, ..., n
%     n >= 4
% Post-conditions:
%     Returns H, a 3 x 3 homography matrix

    assert(all(size(p1) == size(p2)));  % input matrices are of equal size
    assert(size(p1, 2) == 2);  % input matrices each have two columns
    assert(size(p1, 1) >= 4);  % input matrices each have at least 4 rows

   %------------- YOUR CODE STARTS HERE -----------------
    % 
    % The following code computes a homography matrix using all feature points
    % of p1 and p2. Modify it to compute a homography matrix using the inliers
    % of p1 and p2 as determined by RANSAC.
    %
    % Your implementation should use the helper function calcH in two
    % places - 1) finding the homography between four point-pairs within
    % the RANSAC loop, and 2) finding the homography between the inliers
    % after the RANSAC loop.


    n = size(p1, 1);
    iter = 100;
    distCap = 3;
    valCap = 0;


    % RANSAC, 100 tries
    for RANSAC = 1 : iter
        
        k = 1;
        inLiner1 = [];
        inLiner2 = [];
        inds = randperm(n, 4);
        
        % Select 4 randomized pairs (8 points)
        
            H = calcH(p1(inds, :), p2(inds,:));
        
        
        % Test homography accuracy against all feature pairs
        for m = 1:size(p2,1)
            
            p2_H = [ p2(m,:)'; 1 ];
            q = H * p2_H;
            q = [ q(1,:)./q(3,:) ; q(2,:)./q(3,:) ];
            diff = sqrt( sum( (q - p1(m,:)').^2) );
            
            % Collect feature pairs which are consistent with homography
            if diff < distCap
                inLiner1(k,:) = p1(m,:);
                inLiner2(k,:) = p2(m,:);
                k = k +1;
            end
            
        end
        
        % Test if new homography is better than previous one
        if size(inLiner1,1) > valCap
            
            valCap = size(inLiner1,1);
            finalInlinersP1 = inLiner1;
            finalInlinersP2 = inLiner2;
            
        end
        
    end

    %calculate homography using bestinliners
        H = calcH(finalInlinersP1, finalInlinersP2);
        
    %------------- YOUR CODE ENDS HERE -----------------
end

% The following function has been implemented for you.
% DO NOT MODIFY THE FOLLOWING FUNCTION
function H = calcH(p1, p2)
% Returns the homography that maps p2 to p1 in the least squares sense
% Pre-conditions:
%     Both p1 and p2 are nx2 matrices where each row is a feature point.
%     p1(i, :) corresponds to p2(i, :) for i = 1, 2, ..., n
%     n >= 4
% Post-conditions:
%     Returns H, a 3 x 3 homography matrix
    
    assert(all(size(p1) == size(p2)));
    assert(size(p1, 2) == 2);
    
    n = size(p1, 1);
    if n < 4
        error('Not enough points');
    end
    H = zeros(3, 3);  % Homography matrix to be returned

    A = zeros(n*3,9);
    b = zeros(n*3,1);
    for i=1:n
        A(3*(i-1)+1,1:3) = [p2(i,:),1];
        A(3*(i-1)+2,4:6) = [p2(i,:),1];
        A(3*(i-1)+3,7:9) = [p2(i,:),1];
        b(3*(i-1)+1:3*(i-1)+3) = [p1(i,:),1];
    end
    x = (A\b)';
    H = [x(1:3); x(4:6); x(7:9)];

end
