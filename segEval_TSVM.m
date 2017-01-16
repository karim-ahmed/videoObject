%% Evaluate Overall, using Avg Error Pixel between Segtrack GT ...
%% Author: Karim S. Ahmed


function [scoreError] = segEval_TSVM(video_name,method_num,extension1,extension2,visualize )
    format short g

    run('vlfeat/toolbox/vl_setup');

    % load SVM Model 
    if (method_num ==1)
        C = load('svm_train_s1_method1.mat', 'B', 'W');
    elseif (method_num ==2)
        C = load('svm_train_s1_method2.mat', 'B', 'W');
    end
    B = C.B;
    W = C.W;

    %method_num = 2;

    %video_name = 'birdfall2';
    %extension1 = 'png'; % of ground truth
    %extension2 = 'png';
    %data_path = '/home/karim/MyCode/video_objectness/';
    test_path = fullfile( 'test_data/segtrackv1/',video_name); % source



    % for gt
         gt_test_imgs = dir( fullfile( test_path, 'ground-truth' ,strcat('*.', extension2 )));
    % for real image 
    test_imgs = dir( fullfile( test_path ,strcat('*.', extension1 )));

    %grounftruth_file = fullfile(test_path,strcat ('ref-groundtruth.txt'));
    %fid =  fopen(grounftruth_file,'w+');
    %myformat = '%s\t%d\t%d\t%d\t%d\n';
    % imageName x1, y1, x2, y2
    len = length(test_imgs)*10;
    image_size_width = 0;
    image_size_height = 0;
    %
    dim = zeros(length(gt_test_imgs),4);
    max_w = 0;
    max_h = 0;


    labels_path = fullfile( 'results/segtrackv1/stl/', video_name);
    %dest_path = fullfile(data_path, 'test_data/segtrackv1/stl_labeled_final/', video_name);

    bboxes = zeros(0,4);
    confidences = zeros(0,1);
    image_ids = cell(0,1);
    svm_dim = zeros(length(gt_test_imgs),4);

    sum_pixel_errors = 0;


    % read TSVM results files 
    if (method_num == 1)
        tsvm_path = fullfile('svmlin_TSVM_Method1/');
    elseif (method_num == 2)
        tsvm_path = fullfile('svmlin_TSVM_Method2/');
    end
    file_tsvm_sim = fullfile(tsvm_path, strcat ( video_name, '.sim'));
    fid_tsvm_sim =  fopen(file_tsvm_sim);
    tsvm_sim_info = textscan(fid_tsvm_sim, '%s');

   

    for ind = 1:length(gt_test_imgs)

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

        if visualize
            figure, imshow(main_img), hold on    
        end
        w = x2 -x1;
        h = y2 -y1;
        
        if visualize
            rectangle('Position',[x1 y1 w h], 'LineWidth',1, 'EdgeColor','r');
        end
    % following gt dimensions...
        dim(ind,1) = x1;
        dim(ind,2) = y1;
        dim(ind,3) = x2;
        dim(ind,4) = y2;



        %% Calculate svm results dims
        i= ind;
        img_copy = imread( fullfile( test_path, test_imgs(i).name ));
         % read labels 
        file_label_path = fullfile(labels_path,strcat ( test_imgs(i).name, '.txt'));
        fid2 =  fopen(file_label_path);
        gt_info = textscan(fid2, '%d %d %d %d %f64');
        gt_info_width = gt_info{1,3} - gt_info{1,1};
        gt_info_height = gt_info{1,4} - gt_info{1,2};

        gt_bboxes_view = [gt_info{1,1}+1, gt_info{1,2}+1, gt_info_width-1, gt_info_height-1];
        gt_bboxes = [gt_info{1,1}, gt_info{1,2}, gt_info{1,3}, gt_info{1,4}];
        gt_confidences =  double(gt_info{1,5});
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
        
        if visualize
            figure, imshow(img_copy), hold on
        end

        % slect best SVM <<<<<<<<<<<<<<<<
         if visualize
            rectangle('Position',gt_bboxes_view(best_index,:), 'LineWidth',2, 'EdgeColor','r');
         end


        % select top 1 stl
        %rectangle('Position',gt_bboxes(maxIndexes(1),:), 'LineWidth',2, 'EdgeColor','b');


        %% calculate difference in pixels
        pixel_err_perframe = 0 ;
        obj_box = [svm_dim(ind,1) svm_dim(ind,2) (svm_dim(ind,3) - svm_dim(ind,1))   (svm_dim(ind,4) - svm_dim(ind,2))];
        gt_box = [dim(ind,1) dim(ind,2) (dim(ind,3) - dim(ind,1))   (dim(ind,4) - dim(ind,2))]; %gt
        overlap_area = rectint(obj_box,gt_box);
        gt_area = rectint(gt_box,gt_box);
        obj_area = rectint(obj_box,obj_box);
       

        isSim = false;
        % check if exist 
        for j=1:length(tsvm_sim_info{1,1})
           
            if (strcmp(strtrim(test_imgs(i).name), strtrim(num2str(cell2mat(tsvm_sim_info{1,1}(j))))) ==1)
                isSim = true;
                break;
            end
        end
        
         if isSim    
             pixel_err_perframe = (gt_area + obj_area) - 2*overlap_area;
             
         else
              pixel_err_perframe = gt_area;
              
         end
            
            
        sum_pixel_errors = sum_pixel_errors + pixel_err_perframe;



        fclose(fid2);
    end

    Avg_pixl_perFrame = sum_pixel_errors/len;

    scoreError = floor(Avg_pixl_perFrame);

    
    fclose(fid_tsvm_sim);
    %fclose(fid2);
    close all;


end


    

    
    
