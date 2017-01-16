% Run all for segEval_SVM
% call function segEval_SVM for all videos.

function runAll_segEval_SVM2()

    videos = {'girl', 'birdfall2','cheetah', 'monkeydog', 'parachute', 'penguin' };
    extension1 = {'bmp', 'png','bmp', 'bmp', 'png', 'bmp' };
    extension2 = {'bmp', 'png','png', 'png', 'png', 'png' };
    num_videos = length(videos);

    file_out = fullfile(strcat('scoresErrors','.SVM2'));
    fid =  fopen(file_out,'w+');
    
    for i=1:num_videos
        
        errorScore = segEval_SVM(videos{i},2, extension1{i},extension2{i},false );
        
        cur_row =  sprintf('%s,%d\n',videos{i}, errorScore);
        fprintf(fid, cur_row);
        fprintf('** Avg. Error Score SegTrack for video %s = %d\n',videos{i},errorScore);
    end

fclose(fid);
end