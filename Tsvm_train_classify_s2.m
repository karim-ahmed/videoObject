%% Prepare for training and testing TSVM 
%  This file uses the trained model in phaseI (model stored previously in 'svm_train_s1.mat')
%  It generate text file as format needed by SVMLin library 
%  Author: Karim S. Ahmed

run('vlfeat/toolbox/vl_setup');

% load SVM trained model...
C = load('svm_train_s1.mat', 'B', 'W');
B = C.B;
W = C.W;


% Below works only on one video, 
% to execute more videos change the name of the video 
% The total videos are 6 videos.


video_name = 'birdfall2';
extension = 'png';
%data_path = '/home/karim/MyCode/video_objectness/';
test_path = fullfile('test_data/segtrackv1/',video_name); % source
labels_path = fullfile('results/segtrackv1/stl/', video_name);
dest_path = fullfile('test_data/segtrackv1/stl_labeled_final/', video_name);

bboxes = zeros(0,4);
confidences = zeros(0,1);
image_ids = cell(0,1);


test_imgs = dir( fullfile( test_path, strcat('*.',extension) ));
%labels_files = dir( fullfile( labels_path, '*.txt' ));

% used for TSVM, output first loop
train_image_bestbbox_feats = [];
train_image_bestbbox_labels = [];
train_image_negative_feats = [];


%% generate best bounding boxes for this video into matrix 
for i = 1:length(test_imgs)
    fprintf(' ----------- %s\n', test_imgs(i).name)
    
    img = imread( fullfile( test_path, test_imgs(i).name ));
        
    img_copy = img;
    
    % read labels 
    file_label_path = fullfile(labels_path,strcat ( test_imgs(i).name, '.txt'));
    fid =  fopen(file_label_path);
    gt_info = textscan(fid, '%d %d %d %d %f64');
    gt_info_width = gt_info{1,3} - gt_info{1,1};
    gt_info_height = gt_info{1,4} - gt_info{1,2};

    gt_bboxes = [gt_info{1,1}+1, gt_info{1,2}+1, gt_info_width+1, gt_info_height+1];    
    gt_confidences =  double(gt_info{1,5});
    %[val idx] = max(gt_confidences);
    [sortedValues,sortIndex] = sort(gt_confidences(:),'descend');  
    maxIndexes = sortIndex(1:4);
         
    gray_img = rgb2gray(img_copy);

    hog_cell_size = 8;
    all_scores = zeros(length(maxIndexes),1);
    
    % loop on top 4 stl bounding boxes
     for k = 1:length(maxIndexes)
        x1 = gt_info{1,1}(maxIndexes(k))+1;
        y1 = gt_info{1,2}(maxIndexes(k))+1;
        x2 = gt_info{1,3}(maxIndexes(k))+1;
        y2 = gt_info{1,4}(maxIndexes(k))+1;
        
        
         features = vl_hog(im2single(gray_img(y1:y2,x1:x2)), hog_cell_size) ;         
         test_feats = features(:);
         padSize = size(W,1) - size(test_feats,1);
         if (padSize<0)
           
           new_w = padarray( W, abs(padSize) ,'symmetric', 'post');
           new_w = new_w/ norm(new_w);
           all_scores(k) = new_w'*test_feats + B ; 
 
         elseif (padSize>0)
               
            test_feats = padarray(test_feats, padSize ,'symmetric', 'post');
            all_scores(k) = ( W'*test_feats + B ) ; %* gt_confidences(maxIndexes(k)); 
         end
       
     end
    

     best_index = find( all_scores == max(all_scores));
        
     
     % %% make resize features...
     best_x1 = gt_info{1,1}(maxIndexes(best_index))+1;
     best_y1 = gt_info{1,2}(maxIndexes(best_index))+1;
     best_x2 = gt_info{1,3}(maxIndexes(best_index))+1;
     best_y2 = gt_info{1,4}(maxIndexes(best_index))+1;
        
        
     best_feats = vl_hog(im2single(gray_img(best_y1:best_y2,best_x1:best_x2)), hog_cell_size) ;
     %best_feats = gray_img(best_y1:best_y2,best_x1:best_x2);
     %best_feats = imresize(best_feats, 0.25);
     best_feats = best_feats(:);
     
     [sm, sn]= size(train_image_bestbbox_feats);
     if (sm ~= 0 )
        any_prev_feats = train_image_bestbbox_feats(1,:);
        padSize = size( any_prev_feats,2) - size(best_feats,1);
        
        
        if (padSize<0)
           % best all elems in  train_image_bestbbox_feats
                
           train_image_bestbbox_feats = padarray( train_image_bestbbox_feats, [ 0 abs(padSize)] ,'replicate', 'post');
           %train_image_bestbbox_feats = train_image_bestbbox_feats/ norm(train_image_bestbbox_feats);
           
 
         elseif (padSize>0)
         % pad best_feat       
            best_feats = padarray(best_feats, padSize ,'replicate', 'post');
        end
                
        
        train_image_bestbbox_feats = [train_image_bestbbox_feats ; best_feats' ];
        train_image_bestbbox_labels = [train_image_bestbbox_labels ; 0]; % unlabeled
     else
         train_image_bestbbox_feats = [train_image_bestbbox_feats ; best_feats' ];
         train_image_bestbbox_labels =  [train_image_bestbbox_labels ; 1]; % first one is +1
         
         %% Generate negative from background of 1st frame
         
        % =========================================================================================
        x1 = best_x1;
        y1 = best_y1;
        x2 = best_x2;
        y2 = best_y2;
     
     
        stepX = 10; % pixels
        stepY = 10;
        [m,n] = size (gray_img);
        % NW corner 
        for cur_x =1:stepX:n
            neg_x1 = cur_x;
            neg_x2 = neg_x1 + stepX;
            if (neg_x2 >= n)
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
                neg_y2 = neg_y1 + stepY;
                if (neg_y2 >= m)
                    continue;
                end                    
                if (neg_y1 > y1) && (neg_y1 > y2)  % between 
                    continue;
                end
                if (neg_y2 > y1) && (neg_y2 > y2)  % between
                    continue;
                end
            
                % Negative found >> get features
                neg_feats = vl_hog(im2single(gray_img(neg_y1:neg_y2,neg_x1:neg_x2)), hog_cell_size) ;
                %neg_feats = gray_img(neg_y1:neg_y2,neg_x1:neg_x2);
                %neg_feats = imresize(best_feats, 0.25);
                neg_feats = neg_feats(:);
                best_feats = neg_feats;
               % *******************************************************************
                   [sm, sn]= size(train_image_bestbbox_feats);
                     if (sm ~= 0 )
                        any_prev_feats = train_image_bestbbox_feats(1,:);
                        padSize = size( any_prev_feats,2) - size(best_feats,1);
                        if (padSize<0)
                           train_image_bestbbox_feats = padarray( train_image_bestbbox_feats, [ 0 abs(padSize)] ,'replicate', 'post');
                         elseif (padSize>0)                         
                            best_feats = padarray(best_feats, padSize ,'replicate', 'post');
                        end
                        train_image_bestbbox_feats = [train_image_bestbbox_feats ; best_feats' ];
                        train_image_bestbbox_labels = [train_image_bestbbox_labels ; -1]; % negative
                        
                        
                 % *******************************************************************
                end

            end
        
        % ===========================================================================================
         
         
         
         
     end

end

end
%% generate negative
 
%%
% a =0;
% b=255;
% for tt =1:5
%     r = int32( a + (b-a).*rand(size( any_prev_feats,2) ,1));
%     train_image_bestbbox_feats = [train_image_bestbbox_feats ; r' ];
%     train_image_bestbbox_labels =  [train_image_bestbbox_labels ; -1]; % first one is +1
%    
% end

    
%% generate tsvm training file & labels file. for this video 

train_feats_file_name = strcat(video_name, '_trainingtsvm');
train_labels_file_name = strcat(video_name, '_trainlabelssvm');

res = write_tsvm_trainingfile(train_feats_file_name,train_labels_file_name, train_image_bestbbox_feats, train_image_bestbbox_labels);





%% %% generate video image names for you
% note names not ordered



%% Test one bbox vs rest ... for this video only






%%