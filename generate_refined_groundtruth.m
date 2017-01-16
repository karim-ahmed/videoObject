

video_name = 'cheetah';
extension = 'png'; % of ground truth
data_path = '/home/karim/MyCode/video_objectness/';
test_path = fullfile(data_path, 'test_data/segtrackv1/',video_name); % source
%labels_path = fullfile(data_path , 'results/segtrackv1/stl/', video_name);
%dest_path = fullfile(data_path, 'test_data/segtrackv1/stl_labeled/', video_name);

%bboxes = zeros(0,4);
%confidences = zeros(0,1);
image_ids = cell(0,1);


% % for groundtruth only
% if (strcmp (video_name , 'monkeydonkey') == 1)
%     test_imgs = dir( fullfile( test_path, 'ground-truth' ,strcat('*.', 'png' )));
% else
     test_imgs = dir( fullfile( test_path, 'ground-truth' ,strcat('*.', extension )));

%end
%grounftruth_file = dir( fullfile( test_path, 'ref-groundtruth.txt'));


grounftruth_file = fullfile(test_path,strcat ('ref-groundtruth.txt'));
fid =  fopen(grounftruth_file,'w+');
myformat = '%s\t%d\t%d\t%d\t%d\n';
% imageName x1, y1, x2, y2

image_size_width = 0;
image_size_height = 0;
%
dim = zeros(length(test_imgs),4);
max_w = 0;
max_h = 0;
for ind = 1:length(test_imgs)
      
    fprintf('Labeleing %s\n', test_imgs(ind).name)
    %copy_file(fullfile(test_path, test_imgs(i).name ), fullfile(dest_path, test_imgs(i).name ) );
    main_img = imread( fullfile( test_path,'ground-truth', test_imgs(ind).name ));
        
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
    
    
   %figure, imshow(main_img), hold on    
    %w = x2 -x1;
    %h = y2 -y1;
    %rectangle('Position',[x1 y1 w h], 'LineWidth',1, 'EdgeColor','r');

    dim(ind,1) = x1;
    dim(ind,2) = y1;
    dim(ind,3) = x2;
    dim(ind,4) = y2;
    
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

for ind = 1:length(test_imgs)
    w = dim(ind,3) -  dim(ind,1) +1;
    h = dim(ind,4) - dim(ind,2) +1;
    
    
    if w < max_w         
        % increase width 
        shift = max_w - w;
        if  mod(shift,2) == 0 % even
            dim(ind,3) = dim(ind,3) + shift/2 ;
            dim(ind,1) = dim(ind,1) - shift/2;
        else % odd 
            sh = ceil(shift/2);
            dim(ind,3) = dim(ind,3) + sh;
            dim(ind,1) = dim(ind,1) - sh +1;
        end
    end
    
    
    
    if h < max_h         
        % increase hig 
        shift = max_h - h;
        if  mod(shift,2) == 0 % even
            dim(ind,4) = dim(ind,4) + shift/2;
            dim(ind,2) = dim(ind,2) - shift/2;
        else % odd 
            sh = ceil(shift/2);
            dim(ind,4) = dim(ind,4) + sh;
            dim(ind,2) = dim(ind,2) - sh +1;
        end
    end
    
    assert ( max_w == (dim(ind,3) -  dim(ind,1) +1) );
    assert ( max_h == (dim(ind,4) - dim(ind,2)+1) );

   % assert ( dim(ind,1) > 0);
    assert ( dim(ind,3) < image_size_width);
    
    assert ( dim(ind,2) > 0);
   assert ( dim(ind,4) < image_size_height);
    
end


%%

for ind = 1:length(test_imgs)
    filename = test_imgs(ind).name;
    filename = strrep(test_imgs(ind).name, strcat('.',extension) , '.bmp');
    fprintf(fid, myformat, filename, dim(ind,1), dim(ind,2), dim(ind,3), dim(ind,4));
end
    fclose(fid);
    close all;