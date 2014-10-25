function [width, height] = getBlobSize(bwlabelIndexImg, i)

width = 0;
height = 0;

labelimg = bwlabelIndexImg==i;

% get width and height of ones in labelimg
