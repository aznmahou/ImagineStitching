%please place the images in the same folder as this matlab file to run
%this method.
run('VLFeatSIFT/vlfeat-0.9.20/toolbox/vl_setup');
clear;
close all;
row=512;
column=512;
img1=imread('1.jpg');
img1 = imresize(img1,[row,column]);
img1 = imrotate(img1,-90);
img2 = imread('2.jpg');
img2 = imresize(img2,[row,column]);
img2 = imrotate(img2,-90);


img1Gray = im2single(rgb2gray(img1));
img2Gray = im2single(rgb2gray(img2));

[features1,description1] = vl_sift(img1Gray);
[features2,description2] = vl_sift(img2Gray);

matches = vl_ubcmatch(description1,description2);
numMatches = size(matches,2);

img1PlusPad = max(size(img2Gray,1)-size(img1Gray,1),0);
img2PlusPad = max(size(img1Gray,1)-size(img2Gray,1),0);

figure;
imshow([padarray(img1,img1PlusPad) padarray(img2,img2PlusPad)]);
o = size(img1Gray,2);
line([features1(1,matches(1,:));features2(1,matches(2,:))+o],[features1(2,matches(1,:));features2(2,matches(2,:))]);
