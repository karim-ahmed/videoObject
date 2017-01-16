

% save svm_train_s1.mat  B W;

video_name = 'parachute';
data_path = '/home/karim/MyCode/video_objectness/';
test_path = fullfile(data_path, 'test_data/segtrackv1/',video_name); % source
labels_path = fullfile(data_path , 'results/segtrackv1/stl/', video_name);
dest_path = fullfile(data_path, 'test_data/segtrackv1/stl_labeled/', video_name);

bboxes = zeros(0,4);
confidences = zeros(0,1);
image_ids = cell(0,1);



test_imgs = dir( fullfile( test_path, '*.png' ));
%labels_files = dir( fullfile( labels_path, '*.txt' ));

gt_stl_values = zeros(length(test_imgs),1);

gt_stl_names =  cell(length(test_imgs),1);
    

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

    gt_bboxes = [gt_info{1,1}, gt_info{1,2}, gt_info_width, gt_info_height];
    %gt_bboxes = [gt_info{1,1}, gt_info{1,2}, gt_info{1,3}, gt_info{1,4}];
    gt_confidences =  double(gt_info{1,5});
    %[val idx] = max(gt_confidences);
    [sortedValues,sortIndex] = sort(gt_confidences(:),'descend');  
    maxIndexes = sortIndex(1:4);


    figure, imshow(img_copy), hold on

    %# draw a rectangle
    for k = 1:length(maxIndexes)
        if k ==1 
            rectangle('Position',gt_bboxes(maxIndexes(k),:), 'LineWidth',1, 'EdgeColor','r');
        else
            rectangle('Position',gt_bboxes(maxIndexes(k),:), 'LineWidth',k, 'EdgeColor','b');
        end
    end


    f=getframe(gca);
    [X, map] = frame2im(f);
    imwrite(X,  test_imgs(i).name ,'png');
    
    
    gt_stl_names(i, 1) = cellstr(test_imgs(i).name);
     reply =  input('Which box is the best?: ', 's'); % number from 1 to 4
    
    if isempty(reply)
        break;
    else
        if strcmp('reply' , '1' ==0)
            gt_stl_values(i, 2) = 1;
        elseif strcmp('reply' , '2' ==0)
            gt_stl_values(i, 2) = 2;
        elseif strcmp('reply' , '3' ==0)     
            gt_stl_values(i, 2) = 3;
        elseif strcmp('reply' , '4' == 0)
            gt_stl_values(i, 2) = 4;
        end
    end
    
    
     close all;
end
    
    
    
    close all;
    
    
    save gt_stl.mat  gt_stl_names gt_stl_values;
%     
%     
% fid = fopen(label_path);
% gt_info = textscan(fid, '%s %d %d %d %d');
% fclose(fid);
% gt_ids = gt_info{1,1};
% gt_bboxes = [gt_info{1,2}, gt_info{1,3}, gt_info{1,4}, gt_info{1,5}];
% gt_bboxes = double(gt_bboxes);