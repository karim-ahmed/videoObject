% Run all for segEval_TSVM
% call function segEval_TSVM for all videos.

function runAll_segEval_TSVM1()

    videos = {'girl', 'birdfall2','cheetah', 'monkeydog', 'parachute', 'penguin' };
    extension1 = {'bmp', 'png','bmp', 'bmp', 'png', 'bmp' };
    extension2 = {'bmp', 'png','png', 'png', 'png', 'png' };
    num_videos = length(videos);

    
    file_out = fullfile(strcat('scoresErrors','.TSVM1'));
    fid =  fopen(file_out,'w+');
    
    for i=1:num_videos
        
        errorScore = segEval_TSVM(videos{i},1, extension1{i},extension2{i},false );
        cur_row =  sprintf('%s,%d\n',videos{i}, errorScore);
        fprintf(fid, cur_row);
        fprintf('** Avg. Error Score SegTrack for video %s = %d\n',videos{i},errorScore);
    end

 fclose(fid);
end