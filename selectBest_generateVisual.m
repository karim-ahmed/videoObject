% Generate visualizations after selecting best bounding box 
% ** Works in local machine not remote **, if remote needed 
% change image folder paths..
% source folder : 
% labels textfiles :"results/segtrackv1/girl/"
% source images folder: "test_data/segtrackv1/stl/girl/"
% Destination folder (contains labeled images): "results/segtrackv1/stl_labeled/girl/"

video_name = 'girl';
data_path = '/home/karim/MyCode/video_objectness/';
test_path = fullfile(data_path, 'test_data/segtrackv1/',video_name); % source
labels_path = fullfile(data_path , 'results/segtrackv1/stl/', video_name);
dest_path = fullfile(data_path, 'test_data/segtrackv1/stl_labeled_top4/', video_name);

bboxes = zeros(0,4);
confidences = zeros(0,1);
image_ids = cell(0,1);



test_imgs = dir( fullfile( test_path, '*.bmp' ));
%labels_files = dir( fullfile( labels_path, '*.txt' ));


for i = 1:length(test_imgs)
      
    fprintf('Labeleing %s\n', test_imgs(i).name)
    %copy_file(fullfile(test_path, test_imgs(i).name ), fullfile(dest_path, test_imgs(i).name ) );
    img = imread( fullfile( test_path, test_imgs(i).name ));
        
    % copy image
    img_copy = img;
    
    num_top_bboxes = 4; % take top 4 boxes
    
    % read labels 
    file_label_path = fullfile(labels_path,strcat ( test_imgs(i).name, '.txt'));
    fid =  fopen(file_label_path);
    stl_info = textscan(fid, '%d %d %d %d %f64');
    stl_info_width = stl_info{1,3} - stl_info{1,1};
    stl_info_height = stl_info{1,4} - stl_info{1,2};

    stl_bboxes = [stl_info{1,1}, stl_info{1,2}, stl_info_width, stl_info_height];
    stl_conf_scores =  double(stl_info{1,5});
    [sortedValues,sortIndex] = sort(stl_conf_scores(:),'descend');  
    maxIndexes = sortIndex(1:num_top_bboxes); % top num_top_bboxes

    %% generate gaussians for each bounding box
     

     %higest_score = -1; % final score 
     new_score_bboxes = zeros(num_top_bboxes,1);

     for k = 1:length(maxIndexes)
        cur_index = maxIndexes(k);
        %cur_x =  stl_bboxes(cur_index,1);
        %cur_y =  stl_bboxes(cur_index,2);
        %cur_w =  stl_bboxes(cur_index,3);
        %cur_h =  stl_bboxes(cur_index,4);
        cur_stl_conf = stl_conf_scores(cur_index);
        mu = [0.0 0.0 0.0 0.0];
        sigma = [1.0 1.0 1.0 1.0]; 
        X = double(stl_bboxes(cur_index, :));
        prior_gauss = min(normpdf( X , mu, sigma)); 
        %gausswin(stl_bboxes(cur_index, :) );
        new_score_bboxes(k) = cur_stl_conf * prior_gauss ;
                        
     end
    
    [sortedValues,sortIndex] = sort(new_score_bboxes(:),'descend');  
    maxIndexes = sortIndex(1:num_top_bboxes); % top num_top_bboxes
     
    %% Visualize..
    figure, imshow(img_copy), hold on

   rectangle('Position',stl_bboxes(maxIndexes(1),:), 'LineWidth',2, 'EdgeColor','r');
        

    f=getframe(gca);
    [X, map] = frame2im(f);
    imwrite(X,  test_imgs(i).name ,'bmp');
    
end
    
    
    
    close all;
    
%     
%     
% fid = fopen(label_path);
% gt_info = textscan(fid, '%s %d %d %d %d');
% fclose(fid);
% gt_ids = gt_info{1,1};
% gt_bboxes = [gt_info{1,2}, gt_info{1,3}, gt_info{1,4}, gt_info{1,5}];
% gt_bboxes = double(gt_bboxes);