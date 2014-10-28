%% Notes on streaming a video

close all
videoFReader = vision.VideoFileReader('test.mov','AudioOutputPort',true);
videoPlayer = vision.VideoPlayer();
flag = true;
while flag
    try 
        [videoFrame,Audio] = step(videoFReader);
        step(videoPlayer, videoFrame);
    catch
        flag = false;
    end
end
release(videoPlayer);
release(videoFReader);

%% Test the example

addpath(genpath('~/Documents/code/GitHub/fex-metrica/1.0.1/'))
fexObj = importdata('/Users/filippo/Documents/code/GitHub/fex-metrica/1.0.1/examples/data/E002/fexObj.mat');
note = fexnotes(fexObj);

%% Some notes on frame reader


vr = VideoReader(fexObj.video);
tic;
F = read(vr,[1,100]);
t = toc;