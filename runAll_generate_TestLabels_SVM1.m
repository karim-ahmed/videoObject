% Run all for segEval_TSVM
% call function segEval_TSVM for all videos.

function runAll_generate_TestLabels_TSVM1()

    videos = {'girl', 'birdfall2','cheetah', 'monkeydog', 'parachute', 'penguin' };
    extension1 = {'bmp', 'png','bmp', 'bmp', 'png', 'bmp' };
    extension2 = {'bmp', 'png','png', 'png', 'png', 'png' };
    num_videos = length(videos);

    
    for i=1:num_videos
        
        generate_TestLabels_TSVM(videos{i},1, extension1{i},extension2{i},false );
      
    end

 
end