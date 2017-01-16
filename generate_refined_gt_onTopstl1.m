

video_name = 'parachute';
extension = 'png'; % of ground truth
data_path = '/home/karim/MyCode/video_objectness/';
test_path = fullfile(data_path, 'test_data/segtrackv1/',video_name); % source


labels_path = fullfile(data_path , 'results/segtrackv1/stl/', video_name);

image_ids = cell(0,1);


test_imgs = dir( fullfile( test_path, '*.png' ));




% imageName x1, y1, x2, y2

image_size_width = 0;
image_size_height = 0;
%
dim = zeros(length(test_imgs),4);
max_w = 0;
max_h = 0;
for ind = 1:length(test_imgs)
      
    %% new code here 
    
     img = imread( fullfile( test_path,'ground-truth', test_imgs(ind).name ));
         [m,n,~] = size (img);
    image_size_width = n;
    image_size_height = m;
        
     % read labels 
    file_label_path = fullfile(labels_path,strcat ( test_imgs(ind).name, '.txt'));
    fid =  fopen(file_label_path);
    gt_info = textscan(fid, '%d %d %d %d %f64');
    %gt_info_width = gt_info{1,3} - gt_info{1,1};
    %gt_info_height = gt_info{1,4} - gt_info{1,2};

    gt_bboxes = [gt_info{1,1}, gt_info{1,2}, gt_info{1,3}, gt_info{1,4}];
    %gt_bboxes = [gt_info{1,1}, gt_info{1,2}, gt_info{1,3}, gt_info{1,4}];
    gt_confidences =  double(gt_info{1,5});
    %[val idx] = max(gt_confidences);
    [sortedValues,sortIndex] = sort(gt_confidences(:),'descend');  
    maxIndexes = sortIndex(1:4);
    %gt_bboxes(maxIndexes(1),:)

   
    
    %%
    

    dim(ind,1) = gt_bboxes(maxIndexes(1),1)+1; %gt_bboxes(maxIndexes(1),:); %x1;
    dim(ind,2) = gt_bboxes(maxIndexes(1),2)+1; %y1;
    dim(ind,3) = gt_bboxes(maxIndexes(1),3)+1; %x2;
    dim(ind,4) = gt_bboxes(maxIndexes(1),4)+1; %y2;
    
    w = dim(ind,3) -  dim(ind,1) +1 ;
    h = dim(ind,4) - dim(ind,2) +1;

  if w > max_w 
      max_w = w;
  end 
  
  if h > max_h 
      max_h = h;
  end
 
    
end



%% refine size
% % 
% for ind = 1:length(test_imgs)
%     w = dim(ind,3) -  dim(ind,1) +1;
%     h = dim(ind,4) - dim(ind,2) +1;
%     
%     
%     if w < max_w         
%         % increase width 
%         shift = max_w - w;
%         if  mod(shift,2) == 0 % even
%             dim(ind,3) = dim(ind,3) + shift/2 ;
%             dim(ind,1) = dim(ind,1) - shift/2;
%         else % odd 
%             sh = ceil(shift/2);
%             dim(ind,3) = dim(ind,3) + sh;
%             dim(ind,1) = dim(ind,1) - sh +1;
%         end
%     end
%     
%     
%     
%     if h < max_h         
%         % increase hig 
%         shift = max_h - h;
%         if  mod(shift,2) == 0 % even
%             dim(ind,4) = dim(ind,4) + shift/2;
%             dim(ind,2) = dim(ind,2) - shift/2;
%         else % odd 
%             sh = ceil(shift/2);
%             dim(ind,4) = dim(ind,4) + sh;
%             dim(ind,2) = dim(ind,2) - sh +1;
%         end
%     end
%     
%     assert ( max_w == (dim(ind,3) -  dim(ind,1) +1) );
%     assert ( max_h == (dim(ind,4) - dim(ind,2)+1) );
% 
%    % assert ( dim(ind,1) > 0);
%     assert ( dim(ind,3) < image_size_width);
%     
%     assert ( dim(ind,2) > 0);
%    assert ( dim(ind,4) < image_size_height);
    
%end


%%
grounftruth_file = fullfile(test_path,strcat ('stl1-groundtruth_refined.txt'));
fid =  fopen(grounftruth_file,'w+');
myformat = '%s\t%d\t%d\t%d\t%d\n';

for ind = 1:length(test_imgs)
    filename = test_imgs(ind).name;
    filename = strrep(test_imgs(ind).name, strcat('.',extension) , '.png');
    fprintf(fid, myformat, filename, dim(ind,1), dim(ind,2), dim(ind,3), dim(ind,4));
end
    fclose(fid);
    close all;