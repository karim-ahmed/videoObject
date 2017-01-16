function create_PRgraphs_TSVM2()


    run('vlfeat/toolbox/vl_setup');
   
    tsvm_path = fullfile('svmlin_TSVM_Method2/');

    videos = {'girl', 'birdfall2','cheetah', 'monkeydog', 'parachute', 'penguin' };
    extension1 = {'bmp', 'png','bmp', 'bmp', 'png', 'bmp' };
    extension2 = {'bmp', 'png','png', 'png', 'png', 'png' };
    num_videos = length(videos);

    
    for i=1:num_videos
        
      video_name = videos{i};

    file_outputs = fullfile(tsvm_path, strcat ( video_name, '.output.outputs'));
    fid_outputs =  fopen(file_outputs);
    outputs_info = textscan(fid_outputs, '%f');

    file_train_labels = fullfile(tsvm_path, strcat ( video_name, '_trainlabelssvm'));
    fid_train_labels =  fopen(file_train_labels);
    train_labels_info = textscan(fid_train_labels, '%d');
    
    file_test_labels = fullfile(tsvm_path, strcat ( video_name, '_testlabelssvm'));
    fid_test_labels =  fopen(file_test_labels);
    test_labels_info = textscan(fid_test_labels, '%d');
    
    trueLabels = test_labels_info{1,1}(:);
    scores = outputs_info{1,1}(:);
    
    
    %[prec, tpr, fpr, thresh] =
    
    %prec_rec(scores, double(trueLabels));
    
    
    
    %[RECALL, PRECISION] = vl_pr(trueLabels, scores);
    %[tp, fp, p, n, perm, varargin] = vl_tpfp(trueLabels, scores) ;
    %figure;
     
    %trueLabels(find(trueLabels ==0)) =-1;
      figure( 1 );
    vl_pr(trueLabels, scores) ;
     
    saveas(gcf, strcat(video_name,'_TSVM2.pdf'));
    
    
     %saveas( gcf, strcat(video_name,'_TSVM2'), 'jpg' );
    %saveas(video_name);
    %vl_pr(trueLabels+10, scores+10) ;hold on 
    %[recall, precision] = vl_roc(trueLabels, scores) ;

    end

 %close all;
end


