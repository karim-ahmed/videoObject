

run('/home/karim/vlfeat/toolbox/vl_setup');
     
% load SVM params
C = load('svm_train_s1.mat', 'B', 'W');
B = C.B;
W = C.W;
 


video_name = 'parachute';
extension = 'png';
data_path = '/home/karim/MyCode/video_objectness/';
test_path = fullfile(data_path, 'test_data/segtrackv1/',video_name); % source
labels_path = fullfile(data_path , 'results/segtrackv1/stl/', video_name);
dest_path = fullfile(data_path, 'test_data/segtrackv1/stl_labeled_final/', video_name);

bboxes = zeros(0,4);
confidences = zeros(0,1);
image_ids = cell(0,1);



test_imgs = dir( fullfile( test_path, strcat('*.',extension) ));
%labels_files = dir( fullfile( labels_path, '*.txt' ));


for i = 1:length(test_imgs)
    fprintf('Labeleing %s\n', test_imgs(i).name)
    %copy_file(fullfile(test_path, test_imgs(i).name ), fullfile(dest_path, test_imgs(i).name ) );
    img = imread( fullfile( test_path, test_imgs(i).name ));
        
    % copy image
    img_copy = img;
    
    % read labels 
    file_label_path = fullfile(labels_path,strcat ( test_imgs(i).name, '.txt'));
    fid =  fopen(file_label_path);
    gt_info = textscan(fid, '%d %d %d %d %f64');
    gt_info_width = gt_info{1,3} - gt_info{1,1};
    gt_info_height = gt_info{1,4} - gt_info{1,2};

    gt_bboxes = [gt_info{1,1}+1, gt_info{1,2}+1, gt_info_width+1, gt_info_height+1];
    %gt_bboxes = [gt_info{1,1}, gt_info{1,2}, gt_info{1,3}, gt_info{1,4}];
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
 %[~,~,~, scores] = vl_svmtrain(xtest, y, 0, 'model', W, 'bias', B, 'solver', 'none') ;
       
     end
    
     %final_scores = all_scores *
     best_index = find( all_scores == max(all_scores));
        
    figure, imshow(img_copy), hold on
    
    % slect best SVM <<<<<<<<<<<<<<<<
   % rectangle('Position',gt_bboxes(maxIndexes(best_index),:), 'LineWidth',2, 'EdgeColor','r');
    


    % select top 1 stl
    rectangle('Position',gt_bboxes(maxIndexes(1),:), 'LineWidth',2, 'EdgeColor','r');

  


    f=getframe(gca);
    [X, map] = frame2im(f);
    imwrite(X,  strcat(test_imgs(i).name) ,extension);
    
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