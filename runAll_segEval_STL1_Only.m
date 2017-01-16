% Run all for segEval_STL1_Only
% call function segEval_STL1_Only for all videos.

function runAll_segEval_STL1_Only()

    videos = {'girl', 'birdfall2','cheetah', 'monkeydog', 'parachute', 'penguin' };
    extension1 = {'bmp', 'png','bmp', 'bmp', 'png', 'bmp' };
    extension2 = {'bmp', 'png','png', 'png', 'png', 'png' };
    num_videos = length(videos);

    file_out = fullfile(strcat('scoresErrors','.STL1_only'));
    fid =  fopen(file_out,'w+');
    for i=1:num_videos
        
        errorScore = segEval_STL1_Only(videos{i}, extension1{i},extension2{i},false );
        cur_row =  sprintf('%s,%d\n',videos{i}, errorScore);
        fprintf(fid, cur_row);
        fprintf('** Avg. Error Score SegTrack for video %s = %d\n',videos{i},errorScore);
    end

fclose(fid);
end