%% Evaluate Overall, using Avg Error Pixel between Segtrack GT ...
%% Author: Karim S. Ahmed


function [scoreError] = segEval_STL1_Only(video_name,extension1,extension2,visualize )
    format short g

    run('vlfeat/toolbox/vl_setup');

   test_path = fullfile( 'test_data/segtrackv1/',video_name); % source



    % for gt
    gt_test_imgs = dir( fullfile( test_path, 'ground-truth' ,strcat('*.', extension2 )));
    % for real image 
    test_imgs = dir( fullfile( test_path ,strcat('*.', extension1 )));
    len = length(test_imgs)*10;
    image_size_width = 0;
    image_size_height = 0;
    %
    dim = zeros(length(gt_test_imgs),4);
    max_w = 0;
    max_h = 0;


    labels_path = fullfile( 'results/segtrackv1/stl/', video_name);
   

    stl1_dim = zeros(length(gt_test_imgs),4);

    sum_pixel_errors = 0;


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



        %% for stl1
        i= ind;
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
        [sortedValues,sortIndex] = sort(gt_confidences(:),'descend');  
        maxIndexes = sortIndex(1:4);
        best_index = maxIndexes(1); % Top-1 STL BBox index

        stl1_dim(ind,1) = gt_bboxes(best_index,1)+1;
        stl1_dim(ind,2) = gt_bboxes(best_index,2)+1;
        stl1_dim(ind,3) = gt_bboxes(best_index,3)-1;
        stl1_dim(ind,4) = gt_bboxes(best_index,4)-1;
        
        if visualize
            figure, imshow(img_copy), hold on
        end

  
         if visualize
            rectangle('Position',gt_bboxes_view(best_index,:), 'LineWidth',2, 'EdgeColor','r');
         end


        %% calculate difference in pixels
        pixel_err_perframe = 0 ;
        obj_box = [stl1_dim(ind,1) stl1_dim(ind,2) (stl1_dim(ind,3) - stl1_dim(ind,1))   (stl1_dim(ind,4) - stl1_dim(ind,2))];
        gt_box = [dim(ind,1) dim(ind,2) (dim(ind,3) - dim(ind,1))   (dim(ind,4) - dim(ind,2))]; %gt
        overlap_area = rectint(obj_box,gt_box);
        gt_area = rectint(gt_box,gt_box);
        obj_area = rectint(obj_box,obj_box);
        pixel_err_perframe = (gt_area + obj_area) - 2*overlap_area;

        sum_pixel_errors = sum_pixel_errors + pixel_err_perframe;


     fclose(fid);
    end

    Avg_pixl_perFrame = sum_pixel_errors/len;

    scoreError = floor(Avg_pixl_perFrame);

   
    close all;


end
