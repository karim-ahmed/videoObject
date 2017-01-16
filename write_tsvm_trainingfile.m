function res = write_tsvm_trainingfile(train_feats_file_name,train_labels_file_name, train_image_feats, train_image_bestbbox_labels)

% <feature>:<value> <feature>:<value> ... <feature>:<value>

% train_image_feats m x n  rows 

%% 

%file_path = fullfile(file_name);
fid =  fopen(train_feats_file_name,'w+');
fidlabels =  fopen(train_labels_file_name,'w+');


train_image_feats = double(train_image_feats);
[m,n] = size (train_image_feats);

for i = 1:m 
    str = ''; % for 1 line

    for j = 1:n
        if (train_image_feats(i,j) ~= 0)
            
           %cur_val =  sprintf('%d:%f',j, train_image_feats(i,j));
           cur_val =  sprintf('%d:%d',j, train_image_feats(i,j));
           
           %strcat( nums2tr(j),':',nums2tr(train_image_feats(i,j), 5 )  );
           str = sprintf ('%s %s', str, cur_val);
             
        end
    end
    
    
    % append \n , write
    str = sprintf ('%s\n', str);
    fprintf(fid, str);
    
    str2 = sprintf ('%d\n', train_image_bestbbox_labels(i,1) );
    fprintf(fidlabels, str2);
end 


fclose(fid);
fclose(fidlabels);
res =  true;

end