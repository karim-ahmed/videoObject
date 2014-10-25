% Given a before and after binary image, compute a measure of shape.
%
% We propose to compute the centroid of the target in the previous and
% current binary input image.  The centroids will be used to compensate the
% currentImg to the previous image (translational registration only).
%
% Return [object-normalized shape, image-normalized shape]

function res = computeShapeMetric(previousImg, currentImg, outputFileNamePrefix, outputIndex)

w = 0;
h = 0;
currentCentroid = [0 0];
[r,c] = find(currentImg==1);
w = max(c)-min(c);
h = max(r)-min(r);
currentCentroid = sum([c r])./size(r,1);

% Get the dimensions of the largest blob for previousImg
wPrev = 0;
hPrev = 0;
previousCentroid = [0 0];
[r,c] = find(previousImg==1);
wPrev = max(c)-min(c);
hPrev = max(r)-min(r);
previousCentroid = sum([c r])./size(r,1);

% translate the currentImg
width = size(currentImg,2);
height = size(currentImg,1);
uv = [0 0];
translatedCurrentImg = zeros(height,width);
t = currentCentroid-previousCentroid; % t = [u v] or x y offsets
t = round(t);
for i=1:size(currentImg,1)
    for j=1:size(currentImg,2)
        uv = [j+t(1), i+t(2)];
        if (uv(1) >= 1 && uv(1) <= width)
            if (uv(2) >= 1 && uv(2) <= height)
                %translatedCurrentImg(uv(2),uv(1)) = currentImg(i,j);
                translatedCurrentImg(i,j) = currentImg(uv(2),uv(1));
            end
        end
    end
end

objectwidth = (w+wPrev)/2;
objectheight = (h+hPrev)/2;

%figure,imshow(abs(translatedCurrentImg-previousImg));
res = sum(sum(abs(previousImg-translatedCurrentImg))) / (objectwidth*objectheight);
res = [res, sum(sum(abs(previousImg-translatedCurrentImg))) / (width*height)];

% write output file
imwrite(abs(translatedCurrentImg-previousImg),[outputFileNamePrefix '_shape' num2str(outputIndex,'%.4d') '.png'], 'PNG'); 