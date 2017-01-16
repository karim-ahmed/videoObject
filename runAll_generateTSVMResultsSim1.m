% Run all for Method1
% call function generateTSVMResultsSim for all videos.

function runAll_generateTSVMResultsSim1()
    
videos = {'girl', 'birdfall2','cheetah', 'monkeydog', 'parachute', 'penguin' };
num_videos = length(videos);

for i=1:num_videos
    fprintf('** Generating File Sim for video = %s\n',videos{i});
    generateTSVMResultsSim(videos{i},1);
end


end