% calculate the FG/BG overlap over one frame
function overlap = calOverlap(imgRef, img1, nbStates, outputFileNamePrefix, outputIndex)

fgProb = 0.0;
bgProb = 0.0;
thr = 128;

[m n] = size(imgRef);

imgRef = imgRef - uint8(imgRef < thr).*imgRef;
imgRef = (imgRef > 0) * 1;  
imgRef = reshape(imgRef,[m*n 1]); 

fgPixel = find(imgRef > 0);
bgPixel = find(imgRef == 0);

pause(0.5);
[fgPriors, fgMu, fgSigma] = EM_init_kmeans(img1(:,fgPixel), nbStates);
pause(0.5);
[fgPriors, fgMu, fgSigma] = EM(img1(:,fgPixel), fgPriors, fgMu, fgSigma);

pause(0.5);
[bgPriors, bgMu, bgSigma] = EM_init_kmeans(img1(:,bgPixel), nbStates);
pause(0.5);
[bgPriors, bgMu, bgSigma] = EM(img1(:,bgPixel), bgPriors, bgMu, bgSigma);

for i=1:nbStates
  fgProb = fgProb + fgPriors(i).*gaussPDF(img1, fgMu(:,i), fgSigma(:,:,i));
  bgProb = bgProb + bgPriors(i).*gaussPDF(img1, bgMu(:,i), bgSigma(:,:,i));
end

fg = fgProb ./ (fgProb + bgProb);
bg = bgProb ./ (fgProb + bgProb);
 
overlap = sum(bg(fgPixel)) / sum(fg(fgPixel)) + sum(fg(bgPixel)) / sum(bg(bgPixel));

fg1 = reshape(fg,m,n);
bg1 = reshape(bg,m,n);

% TODO: add index to filename
imwrite(fg1*255,[outputFileNamePrefix '_fgColor' num2str(outputIndex,'%.4d') '.png'], 'PNG');
imwrite(bg1*255,[outputFileNamePrefix '_bgColor' num2str(outputIndex,'%.4d') '.png'], 'PNG');
%imshow(uint8(fg1*255));
% imshow(uint8(bg1*255));