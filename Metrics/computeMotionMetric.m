% Given a before and after binary image, compute a measure of motion.
%
% We propose an object-normalized measure of motion.  The object
% which moves beside itself to "kiss" the previous object's
% segmentation would likely correspond to a normalized motion
% measure > 1.
%
% Return [object-normalized motionOverlap, image-normalizedMotionOverlap,
% image-normalized horizontalMotion, image-normalized verticalMotion,
% object-normalized horizontalMotion, object-normalized verticalMotion]

function res = computeMotionMetric(previousImg, currentImg, outputFileNamePrefix, outputIndex)


w = 0;
h = 0;
[r,c] = find(currentImg==1);
w = max(c)-min(c);
h = max(r)-min(r);
currentCentroid = sum([c r])./size(r,1);
        
wPrev = 0;
hPrev = 0;
[r,c] = find(previousImg==1);
wPrev = max(c)-min(c);
hPrev = max(r)-min(r);
previousCentroid = sum([c r])./size(r,1);
t = currentCentroid-previousCentroid; % t = [u v] or x y offsets

objectwidth = (w+wPrev)/2;
objectheight = (h+hPrev)/2;

width = size(currentImg,2);
height = size(currentImg,1);

%figure,imshow(abs(previousImg-currentImg));
res = sum(sum(abs(previousImg-currentImg))) / (objectwidth*objectheight);
res = [res, sum(sum(abs(previousImg-currentImg))) / (width*height)];
res = [res, t(1), t(2), t(1)/objectwidth, t(2)/objectheight];

% write output file
imwrite(abs(previousImg-currentImg),[outputFileNamePrefix '_motion' num2str(outputIndex,'%.4d') '.png'], 'PNG'); 
