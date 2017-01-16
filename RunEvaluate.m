% Evaluate 
format short g

run('/home/karim/vlfeat/toolbox/vl_setup');
     
% load SVM params
C = load('svm_train_s1.mat', 'B', 'W');
B = C.B;
W = C.W;
 


video_name = 'birdfall2';
extension1 = 'png'; % of ground truth
extension2 = 'png';
data_path = '/home/karim/MyCode/video_objectness/';
test_path = fullfile(data_path, 'test_data/segtrackv1/',video_name); % source


% for gt
     gt_test_imgs = dir( fullfile( test_path, 'ground-truth' ,strcat('*.', extension2 )));
% for real image 
test_imgs = dir( fullfile( test_path ,strcat('*.', extension1 )));

grounftruth_file = fullfile(test_path,strcat ('ref-groundtruth.txt'));
fid =  fopen(grounftruth_file,'w+');
myformat = '%s\t%d\t%d\t%d\t%d\n';
% imageName x1, y1, x2, y2
len = length(test_imgs)*10;

image_size_width = 0;
image_size_height = 0;
%
dim = zeros(length(gt_test_imgs),4);
max_w = 0;
max_h = 0;


labels_path = fullfile(data_path , 'results/segtrackv1/stl/', video_name);
%dest_path = fullfile(data_path, 'test_data/segtrackv1/stl_labeled_final/', video_name);

bboxes = zeros(0,4);
confidences = zeros(0,1);
image_ids = cell(0,1);



%test_imgs = dir( fullfile( test_path, strcat('*.',extension2) ));
%test_imgs = dir( fullfile( test_path, strcat('*.',extension2) ));
%%%%%%%%%%%%%%%%% for SVM part ********************






svm_dim = zeros(length(gt_test_imgs),4);





sum_pixel_errors = 0;


%%%%%%%%%%%%%%%%%%%%%%%%55


for ind = 1:length(gt_test_imgs)
      
    
    %fprintf('Labeleing %s\n', test_imgs(ind).name)
    %copy_file(fullfile(test_path, test_imgs(i).name ), fullfile(dest_path, test_imgs(i).name ) );
    main_img = imread( fullfile( test_path,'ground-truth', gt_test_imgs(ind).name ));
        
    % copy image
    img = main_img(:,:,1);
    img(img>0)=1;
    img(img<=0)=0;
    
    [m,n] = size (img);
    image_size_width = n;
    image_size_height = m;
    % get x1
    x1 =0;
    y1 =0;
    x2 =0; 
    y2 =0;
    % get x1
    for j = 1:n
       if (sum(img(:,j)) ~=0)         
           x1 = j;
           new_j = j;
           % loop
           while(sum(img(:,new_j)) ~=0)
               new_j = new_j+1;
           end
           x2 = new_j-1;           
           break;
       end
    end
    % get y1
    for i = 1:m
       if (sum(img(i,:)) ~=0)         
           y1 = i;
            % loop
           new_i = i;
           while(sum(img(new_i,:)) ~=0)
               new_i = new_i+1;
           end
           y2 = new_i-1;           
           break;    
       end
    end
    
    
   figure, imshow(main_img), hold on    
    w = x2 -x1;
    h = y2 -y1;
    rectangle('Position',[x1 y1 w h], 'LineWidth',1, 'EdgeColor','r');

% following gt dimensions...
    dim(ind,1) = x1;
    dim(ind,2) = y1;
    dim(ind,3) = x2;
    dim(ind,4) = y2;
    
    
    
    %% Calculate svm results dims
    i= ind;
     %img_copy = imread( fullfile( test_path,'ground-truth', test_imgs(ind).name )); 
     
     
    img_copy = imread( fullfile( test_path, test_imgs(i).name ));
     % read labels 
    file_label_path = fullfile(labels_path,strcat ( test_imgs(i).name, '.txt'));
    fid =  fopen(file_label_path);
    gt_info = textscan(fid, '%d %d %d %d %f64');
    gt_info_width = gt_info{1,3} - gt_info{1,1};
    gt_info_height = gt_info{1,4} - gt_info{1,2};

    gt_bboxes_view = [gt_info{1,1}+1, gt_info{1,2}+1, gt_info_width-1, gt_info_height-1];
    gt_bboxes = [gt_info{1,1}, gt_info{1,2}, gt_info{1,3}, gt_info{1,4}];
    gt_confidences =  double(gt_info{1,5});
    %[val idx] = max(gt_confidences);
    [sortedValues,sortIndex] = sort(gt_confidences(:),'descend');  
    maxIndexes = sortIndex(1:4);
         
    gray_img = rgb2gray(img_copy);

    hog_cell_size = 8;
    all_scores = zeros(length(maxIndexes),1);
     for k = 1:length(maxIndexes)
        x1 = gt_info{1,1}(maxIndexes(k))+1;
        y1 = gt_info{1,2}(maxIndexes(k))+1;
        x2 = gt_info{1,3}(maxIndexes(k))-1;
        y2 = gt_info{1,4}(maxIndexes(k))-1;
        
        
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
    
     %final_scores = all_scores *
     best_index = find( all_scores == max(all_scores));
     
     
     
     
    % following svm dimensions...cl
    svm_dim(ind,1) = gt_bboxes(best_index,1)+1;
    svm_dim(ind,2) = gt_bboxes(best_index,2)+1;
    svm_dim(ind,3) = gt_bboxes(best_index,3)-1;
    svm_dim(ind,4) = gt_bboxes(best_index,4)-1;
    figure, imshow(img_copy), hold on
    
    % slect best SVM <<<<<<<<<<<<<<<<
    rectangle('Position',gt_bboxes_view(best_index,:), 'LineWidth',2, 'EdgeColor','r');
    


    % select top 1 stl
    %rectangle('Position',gt_bboxes(maxIndexes(1),:), 'LineWidth',2, 'EdgeColor','b');
    
    
    %% calculate difference in pixels
    pixel_err_perframe = 0 ;
    obj_box = [svm_dim(ind,1) svm_dim(ind,2) (svm_dim(ind,3) - svm_dim(ind,1))   (svm_dim(ind,4) - svm_dim(ind,2))];
    gt_box = [dim(ind,1) dim(ind,2) (dim(ind,3) - dim(ind,1))   (dim(ind,4) - dim(ind,2))]; %gt
    overlap_area = rectint(obj_box,gt_box);
    gt_area = rectint(gt_box,gt_box);
    obj_area = rectint(obj_box,obj_box);
    pixel_err_perframe = (gt_area + obj_area) - 2*overlap_area;
    
    sum_pixel_errors = sum_pixel_errors + pixel_err_perframe;
    %for ii =
    
    
    
end

Avg_pixl_perFrame = sum_pixel_errors/len;

    

    fclose(fid);
    close all;