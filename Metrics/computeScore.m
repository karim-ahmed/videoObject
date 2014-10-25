% Compute simple score measure

function res = computeScore(imgRef, img, outputFileNamePrefix, outputIndex)

imgRef = imgRef>128; %gt
img = img>128; % test sequence

% BIRDFALL: BOTTOM AND LEFT ARE PADDED
% PARACHUTE: RIGHT SIDE IS PADDED

% Stan Birchfield's code would crash if the width was not a multiple of
% four.  Typically this was done by removing columns from the right side.
% Here we add them back in with 0.
if (size(img,2) < size(imgRef,2))
    %img(:,end:size(imgRef,2)) = 0; % right side %use for parachute
    img(:,size(imgRef,2)-size(img,2)+1:size(imgRef,2)) = img; % left side
end
if (size(img,1) < size(imgRef,1))
    img(end:size(imgRef,1),:) = 0; % bottom side
end
res = sum(sum(abs(imgRef-img)));

% write output file
imwrite(abs(imgRef-img),[outputFileNamePrefix '_score' num2str(outputIndex,'%.4d') '.png'], 'PNG'); 
