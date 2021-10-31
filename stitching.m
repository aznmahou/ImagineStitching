function stitch = stitching(img1, img2, N)

run('VLFeatSIFT/vlfeat-0.9.20/toolbox/vl_setup');

img1Gray = im2single(rgb2gray(img1));
img2Gray = im2single(rgb2gray(img2));

[features1,description1] = vl_sift(img1Gray);
[features2,description2] = vl_sift(img2Gray);

matches = vl_ubcmatch(description1,description2);
numMatches = size(matches,2);

%X1 gives the 1st 2 rows of features at the position of which
%the value of matches is.
%like matches(1,1) is 5 so it goes to features column 5 and takes
%the values at (1,5) and (2,5). Same for X2 but for the 2nd row of
%matches
%The third row of X1 and X2 are made 1.
X1 = features1(1:2,matches(1,:)); 
X1(3,:) = 1;
X2 = features2(1:2,matches(2,:)); 
X2(3,:) = 1;

%RANSAC

for t = 1:N
  %gets 4 random numbers from 1 to the number of total matches
  fourTuple = vl_colsubset(1:numMatches, 4);
  kronSkew = [];
  for i = fourTuple
     %vl_hat gets the skew_symmetric_matrix of X2 
     %X2 = [ a1, a2, a3] so vl_hat gives us
     %xhat = | 0 , -a3 , a2 |
     %       | a3,  0  ,-a1 |
     %       |-a2,  a1 , 0  |
     %kron gets the kronecktor Tensor Product of X1 and the skew
     %symmetric_matrix of X2
     %then we just concatenate our matrix kronSkew with this product.
     %this makes kronSkew a 3x9 in the first iteration, 6x9, 9x9, 12x9
     %in the following 3, giving us a 12x9 with 3 rows of each kron
     %of its fourTuple value.
    kronSkew = cat(1, kronSkew, kron(X1(:,i)', vl_hat(X2(:,i))));
  end
  %use svd to get U,V rotation matrices and Sigma our scaling matrix
  [~,~,V] = svd(kronSkew);
  %Our homography solution is V and we take the bottom 9th row and reshape
  %into a 3x3
  H{t} = reshape(V(:,9),3,3);

  % score the H
  %apply the H, get the differences in x and y of the calculated 
  %H and see how many are inliers and score the sum
  %then we repeat a bunch
  X2homoApply = H{t} * X1;
  du = X2homoApply(1,:)./X2homoApply(3,:) - X2(1,:)./X2(3,:);
  dv = X2homoApply(2,:)./X2homoApply(3,:) - X2(2,:)./X2(3,:);
  inliers{t} = (du.*du + dv.*dv) < 6*6;
  score(t) = sum(inliers{t});
end

%we take the max of score and get the best score val and where it is
[~, indicie] = max(score);
%get the best H and the best matches at are inliers
H = H{indicie};

%stiching

%gets the size of the new image with both sitched together.

cornersH = H\[[ 1 ; 1 ;1] [size(img2Gray,2);1;1] [size(img2Gray,2);size(img2Gray,1);1] [1;size(img2Gray,1);1]];
newImg = cornersH;
newImg(1,:) = newImg(1,:) ./ newImg(3,:);
newImg(2,:) = newImg(2,:) ./ newImg(3,:);
newXSize = min([1,newImg(1,:)]):max([size(img1,2),newImg(1,:)]);
newYSize = min([1,newImg(2,:)]):max([size(img1,1),newImg(2,:)]);

[x,y] = meshgrid(newXSize,newYSize);
img1Back = vl_imwbackward(im2double(img1),x,y);

%(wx,wy,w) = H(x,y,1);
w = H(3,1) * x + H(3,2) * y + H(3,3);
xtil = (H(1,1)*x + H(1,2)*y + H(1,3))./w;
ytil = (H(2,1)*x + H(2,2)*y + H(2,3))./w;

img2Back = vl_imwbackward(im2double(img2),xtil,ytil);

%check for nans and make the intensity cut by half as its doubled
%where it is joined.
overlap = ~isnan(img1Back) + ~isnan(img2Back);
img1Back(isnan(img1Back)) = 0;
img2Back(isnan(img2Back)) = 0;
stitch = (img1Back + img2Back)./overlap;

figure;
imshow(stitch);

end