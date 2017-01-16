% generate TSVM Results Sim

function generateTSVMResultsSim(video_name,method_num)

    if (method_num == 1)
        tsvm_path = fullfile('svmlin_TSVM_Method1/');
    elseif (method_num == 2)
        tsvm_path = fullfile('svmlin_TSVM_Method2/');
    end


    file_names = fullfile(tsvm_path, strcat ( video_name, '.names'));
    fid_names =  fopen(file_names);
    names_info = textscan(fid_names, '%s');

    file_outputs = fullfile(tsvm_path, strcat ( video_name, '.output.outputs'));
    fid_outputs =  fopen(file_outputs);
    outputs_info = textscan(fid_outputs, '%f');

    file_train_labels = fullfile(tsvm_path, strcat ( video_name, '_trainlabelssvm'));
    fid_train_labels =  fopen(file_train_labels);
    train_labels_info = textscan(fid_train_labels, '%d');

    file_sim = fullfile(tsvm_path, strcat ( video_name, '.sim'));
    fid_sim =  fopen(file_sim,'w+');


    %names_info{1}{1}, .. names_info{1}{2}
    img_index = 1;



    for i=1:length(train_labels_info{1,1})
        if (train_labels_info{1,1}(i) == -1)
            continue;
        end


        cur_img_name = names_info{1,1}(img_index);
        cur_outputVal = (outputs_info{1,1}(i));


        if (cur_outputVal>=0)
            cur_row =  sprintf('%s\n', num2str(cell2mat(cur_img_name)));
            fprintf(fid_sim, cur_row);
        end



         img_index = img_index +1;
    end



    fclose(fid_sim);
    
    
end

    

    
    
    