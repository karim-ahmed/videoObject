

videos = {'girl', 'birdfall2','cheetah', 'monkeydog', 'parachute', 'penguin' };
extensions = {'bmp', 'png','bmp', 'bmp', 'png', 'bmp' };

listVar = [];
for v=1:length(videos)
    
     fprintf('Training %s\n', videos{v})
    data_path = '/home/karim/MyCode/video_objectness/';
    src_path = fullfile(data_path, 'test_data/segtrackv1/',videos{v}); % source
    
    
    src_imgs = dir( fullfile( src_path ,strcat('*.', extensions{v} )));
    
    


avgVar = 0;
for i = 1: 1
        fprintf('Labeleing %s\n', src_imgs(i).name);
    img = rgb2gray(imread( fullfile( src_path, src_imgs(i).name )));
    vr = var(double(img(:)))/ norm(double(img(:)));
      avgVar = avgVar + vr;  
    
    
end

avgVar = avgVar; %/length(src_imgs);
listVar = [listVar ; avgVar];


end