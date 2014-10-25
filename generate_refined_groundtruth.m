

video_name = 'monkeydog';
extension = 'bmp';
data_path = '/home/karim/MyCode/video_objectness/';
test_path = fullfile(data_path, 'test_data/segtrackv1/',video_name); % source
%labels_path = fullfile(data_path , 'results/segtrackv1/stl/', video_name);
%dest_path = fullfile(data_path, 'test_data/segtrackv1/stl_labeled/', video_name);

%bboxes = zeros(0,4);
%confidences = zeros(0,1);
image_ids = cell(0,1);



test_imgs = dir( fullfile( test_path, 'ground-truth' ,strcat('*.', extension )));
%grounftruth_file = dir( fullfile( test_path, 'ref-groundtruth.txt'));


grounftruth_file = fullfile(test_path,strcat ('ref-groundtruth.txt'));
fid =  fopen(grounftruth_file,'w+');
myformat = '%s\t%d\t%d\t%d\t%d\n';


for ind = 1:length(test_imgs)
      
    fprintf('Labeleing %s\n', test_imgs(ind).name)
    %copy_file(fullfile(test_path, test_imgs(i).name ), fullfile(dest_path, test_imgs(i).name ) );
    main_img = imread( fullfile( test_path,'ground-truth', test_imgs(ind).name ));
        
    % copy image
    img = main_img(:,:,1);
    img(img>0)=1;
    img(img<=0)=0;
    
    [m,n] = size (img);
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
    
    
   %figure, imshow(main_img), hold on    
    %w = x2 -x1;
    %h = y2 -y1;
    %rectangle('Position',[x1 y1 w h], 'LineWidth',1, 'EdgeColor','r');

    fprintf(fid, myformat, test_imgs(ind).name, x1, y1, x2, y2);

 
    
end
    
    fclose(fid);
    close all;