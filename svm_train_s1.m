
% generate model (theta , B) after training on all grounf truth. 
% output : file svm_train_s1.mat 'should be by all used for testing bounding boxes'
run('vlfeat/toolbox/vl_setup');


gt_type= 'stl1-groundtruth.txt';  % or ref-groundtruth.txt for refineed gt 

videos = {'girl', 'birdfall2','cheetah', 'monkeydog', 'parachute', 'penguin' };
extensions = {'bmp', 'png','bmp', 'bmp', 'png', 'bmp' };
num_videos = length(videos);

for v=1:1
    
     fprintf('Training %s\n', videos{v})
    data_path = '/home/karim/MyCode/video_objectness/';
    src_path = fullfile(data_path, 'test_data/segtrackv1/',videos{v}); % source
    %labels_path = fullfile(data_path , 'results/segtrackv1/stl/', video_name);
    %dest_path = fullfile(data_path, 'test_data/segtrackv1/stl_labeled/', video_name);

    %bboxes = zeros(0,4);
    %confidences = zeros(0,1);
    %image_ids = cell(0,1);



    src_imgs = dir( fullfile( src_path ,strcat('*.', extensions{v} )));
    %gt_path = fullfile( src_path, 'ground-truth' ,strcat('*.', extension )));

    %grounftruth_file = dir( fullfile( test_path, 'ref-groundtruth.txt'));

    images_id = [];% cell(1,1) ; %[num x1]
    train_feats = [] ;%zeros(1,1); %[n X m]
    train_labels = []; %zeros(1,1); % [m x 1]


    grounftruth_file = fullfile(src_path,strcat (gt_type));
    fid =  fopen(grounftruth_file);
    myformat = '%s\t%d\t%d\t%d\t%d\n';
    gt_info = textscan(fid, myformat);


    % read true part for all images
    hog_cell_size =8 ;
    for i = 1: length(src_imgs)

        % read ground truth . assume src images with same name as groundtruth
        src_img = imread( fullfile( src_path, src_imgs(i).name )); % color rgb

        indx = find(ismember(gt_info{1,1},src_imgs(i).name));
        x1 = gt_info{1,2}(indx);
        y1 = gt_info{1,3}(indx);
        x2 = gt_info{1,4}(indx);
        y2 = gt_info{1,5}(indx);
    % 
    %     if size(src_img,3)~= 1
    %      img = rgb2gray(src_img);
    %     end
    %     
    %     img = single(vl_imdown(src_img));
    %    

        gray_img = rgb2gray(src_img);
        features = vl_hog(im2single(gray_img(y1:y2,x1:x2,:)), hog_cell_size) ; 
        images_id{i} =  src_imgs(i).name;
        
        features = features(:);
        %%%% my new code ....if gt_type= 'stl1-groundtruth.txt'
        if (size( train_feats,2)~=0)
            padSize = size( train_feats,1) - size(features,1);

            if (padSize<0)
                train_feats = padarray(  train_feats, [ abs(padSize) 0] ,'replicate', 'post');
               % pad all elems in  train_image_bestbbox_feats
%                 for mm=1:size(train_feats,2) % loop on column
%                     train_feats(:,mm) = padarray(  train_feats(:,mm), [ 0 abs(padSize)] ,'replicate', 'post');
%                 end
               %train_image_bestbbox_feats = train_image_bestbbox_feats/ norm(train_image_bestbbox_feats);


             elseif (padSize>0)
             % pad features       
                features = padarray(features, padSize ,'replicate', 'post');
            end

        %
        end
        
        train_feats = [train_feats, features];
        train_labels = [train_labels; 1]; % 1: positive, -1: negative


        % get negative parts
        w = x2 - x1 +1;
        h = y2 - y1 +1;
        stepX = 20; % pixels
        stepY = 20;
        [m,n] = size (gray_img);
        % NW corner 
        for cur_x =1:stepX:n
            neg_x1 = cur_x;
            neg_x2 = neg_x1 +w -1;
            if (neg_x2 >= n)
                continue;
            end
            if ( w ~= (neg_x2 -  neg_x1 +1) )
                continue;
            end
            if (neg_x1 > x1) && (neg_x1 < x2)  % neg_x1 between 
                continue;
            end
            if (neg_x2 > x1) && (neg_x2 < x2)  % neg_x2 between 
                continue;
            end


            for cur_y = 1:stepY:m

                neg_y1 = cur_y;
                neg_y2 = neg_y1 + h -1;
                if (neg_y2 >= m)
                    continue;
                end
                
                if ( h ~= (neg_y2 - neg_y1 +1) )
                    continue;
                end

                if (neg_y1 > y1) && (neg_y1 > y2)  % between 
                    continue;
                end
                if (neg_y2 > y1) && (neg_y2 > y2)  % between 
                    continue;
                end
                %figure, imshow(src_img(neg_y1:neg_y2,neg_x1:neg_x2,:)), hold on
                %fprintf('found negative %d%d\n', neg_x1, neg_y1);

                % Negative found >> get features

                features = vl_hog(im2single(gray_img(neg_y1:neg_y2,neg_x1:neg_x2,:)), hog_cell_size) ; 
                images_id{i} =  src_imgs(i).name;
                
                % new
                features = features(:);
                 padSize = size( train_feats,1) - size(features,1);
                 if (padSize~=0)
                    features = padarray(features, padSize ,'replicate', 'post');
                 end
                
                %
                train_feats = [train_feats, features];
                train_labels = [train_labels; -1]; % 1: positive, -1: negative

            end
        end



    end
end % all videos

%% train SVM

%SVMStruct = svmtrain(train_feats',train_labels,'showplot',true);


 LAMBDA =  0.001; % regularization parameter
 all_scores = [];
 [W B] = vl_svmtrain(train_feats, train_labels, LAMBDA);
     
save svm_train_s1.mat  B W;



%C = load('svm_train_s1.mat', 'B', 'W');
%testB = C.B;
 
 %% test SVM 
% for i =1: num_categories
%     
%         % score : 1 X 1500 (per 1 category)
%     scores = W'*rot_test_image_feats + B ; 



    fclose(fid);
    close all;