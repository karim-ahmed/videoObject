%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run color overlap, motion and shape
% change metrics on the GTrackingDB.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic
clear all
dbSize = 1;

HOMEDIR = cell(1,dbSize);
GROUNDTRUTHFOLDER = cell(1,dbSize);
PREFIX = cell(1,dbSize);
SUFFIX = cell(1,dbSize);
FNUMSTART = cell(1,dbSize);
FNUMFINISH = cell(1,dbSize);
FNUMPADLENGTH = cell(1,dbSize);
GTPREFIX = cell(1,dbSize);
GTSUFFIX = cell(1,dbSize);
GTFNUMSTART = cell(1,dbSize);
GTFNUMFINISH = cell(1,dbSize);
GTFNUMPADLENGTH = cell(1,dbSize);
OUTFNAMEPREFIX = cell(1,dbSize);   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (1) parachute-color0-motion0-shape0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dbIndex = 1;
HOMEDIR{dbIndex} = '/host/Database/VideoGraphCut/SegTrack/parachute/';
GROUNDTRUTHFOLDER{dbIndex} = 'ground-truth/';
PREFIX{dbIndex} = 'parachute_';
SUFFIX{dbIndex} = '.png';
FNUMSTART{dbIndex} = 0;
FNUMFINISH{dbIndex} = 50;
FNUMPADLENGTH{dbIndex} = '%.5d';
GTPREFIX{dbIndex} = 'parachute_';
GTSUFFIX{dbIndex} = '.png';
GTFNUMSTART{dbIndex} = 0;
GTFNUMFINISH{dbIndex} = 50;
GTFNUMPADLENGTH{dbIndex} = '%.5d';
OUTFNAMEPREFIX{dbIndex} = '000-parachute';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nbStates = 5;  % number of GMM
k = 3;
threshold = 128;

dbIndex = 1;

% initialize output
overlap = zeros(1,FNUMFINISH{dbIndex}-FNUMSTART{dbIndex}+1);
motion = zeros(6,FNUMFINISH{dbIndex}-FNUMSTART{dbIndex}+1);
shape = zeros(2,FNUMFINISH{dbIndex}-FNUMSTART{dbIndex}+1);

for i = FNUMSTART{dbIndex}:FNUMFINISH{dbIndex} 
    % Get ground truth
    gti = (i-FNUMSTART{dbIndex})+GTFNUMSTART{dbIndex};
    gtfname = [HOMEDIR{dbIndex} GROUNDTRUTHFOLDER{dbIndex} GTPREFIX{dbIndex} num2str(gti,GTFNUMPADLENGTH{dbIndex}) GTSUFFIX{dbIndex} ];
    imgRef = imread(gtfname);
    if (size(imgRef,3) > 1)
        imgRef = imgRef(:,:,1);
    end
    [m n] = size(imgRef);

    % Get original color image
    colori = (i-FNUMSTART{dbIndex})+FNUMSTART{dbIndex};
    fname = [HOMEDIR{dbIndex} PREFIX{dbIndex} num2str(colori,FNUMPADLENGTH{dbIndex}) SUFFIX{dbIndex} ];
    img = imread(fname);
    img1 = double(reshape(img,[m*n k]))';
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COLOR: Overlap as sum of error likelihood ratios:
    % overlap = p(x_fg|bg)/p(x_fg|fg) + p(x_bg|fg)/p(x_bg|bg)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    overlap(1,i-FNUMSTART{dbIndex}+1) = calOverlap(imgRef, img1, nbStates, OUTFNAMEPREFIX{dbIndex}, i);

    if (i > FNUMSTART{dbIndex})
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % MOTION: Xor intersection
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Should normalize for target size.  large target with small motion
        % could create a greater measure of motion than a small target with
        % very large motion.
        %
        % We propose an object-normalized measure of motion.  The object
        % which moves beside itself to "kiss" the previous object's
        % segmentation would likely correspond to a normalized motion
        % measure > 1.
        motion(:,i-FNUMSTART{dbIndex}+1) = computeMotionMetric(previousImgRef>threshold, imgRef>threshold, OUTFNAMEPREFIX{dbIndex}, i);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % SHAPE: Xor intersection
        % after compensating for coarse
        % motion computed between
        % centroids.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        shape(:,i-FNUMSTART{dbIndex}+1) = computeShapeMetric(previousImgRef>threshold, imgRef>threshold, OUTFNAMEPREFIX{dbIndex}, i);
    end      
    previousImgRef = imgRef;
    
    % Output metrics
    ofname = [OUTFNAMEPREFIX{dbIndex} '-overlap.mat'];
    save(ofname,'overlap');
    ofname = [OUTFNAMEPREFIX{dbIndex} '-motion.mat'];
    save(ofname,'motion');
    ofname = [OUTFNAMEPREFIX{dbIndex} '-shape.mat'];
    save(ofname,'shape');
    disp(i);

end

toc