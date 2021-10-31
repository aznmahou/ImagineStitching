%please place the images in the same folder as this matlab file to run
%this method. Also have stitching.m in the same folder as RANSAC.m as that is the
%actual function that does the image stitching
%
%This is just a file to load the images, resize and straighten them
%and to run the stitching functions on the multiple images

run('VLFeatSIFT/vlfeat-0.9.20/toolbox/vl_setup');
clear;
close all;

row = 512;
column = 512;
img1 = imread('1.jpg');
img2 = imread('2.jpg');
img3 = imread('3.jpg');
img4 = imread('4.jpg');
img5 = imread('5.jpg');
img1 = imrotate(img1,-90);
img2 = imrotate(img2,-90);
img3 = imrotate(img3,-90);
img4 = imrotate(img4,-90);
img5 = imrotate(img5,-90);
img1 = (imresize(img1,[row,column]));
img2 = (imresize(img2,[row,column]));
img3 = (imresize(img3,[row,column]));
img4 = (imresize(img4,[row,column]));
img5 = (imresize(img5,[row,column]));


stitch1 = stitching(img3,img2,100);
stitch2 = stitching(stitch1,img4,100000);
stitch3 = stitching(stitch2,img1,100000);
stitch4 = stitching(stitch3,img5,100000);

