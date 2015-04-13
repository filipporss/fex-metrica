classdef fexvideoc < handle
%
% FEXVIDEO - FexMetrica 1.0.1 video utility object.
%
% Use information from FEXC file or video file, and allow a set of
% operations, including:
%
%
% CROP - Crop video (with/without UI);
% RGBSEP - Separate RGB channels;
% ENCDE - Re-encode video;
% HRE - Estimate heart-rate from video;
% PDE - Estimates pupil dilatation.
%
%
% Copyright (c) - 2014-2015 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 12-Apr-2015.

properties
    video
    exec
    flag
    face
end


methods
function self = fexvideoc(varargin)
%
% FEXVIDEOC - Constructor for FEX video utilities objec.

self.execset();

if isempty(varargin)
    return
elseif isa(varargin{1},'char')
    self.flag  = 1;
    self.video = 'char';
    self.face  = [];
elseif isa(varargin{1},'fexc')
    self.flag  = 2;
    self.video = varargin{1}.video;
    self.face  = varargin{1};
else
    warning('Not recognized argument.');
end
    
if ~exist(self.video,'file')
    error('Video Not found.');
end


end

% ==============================================


function self = execset(self,varargin)
%
% EXECSET - Set up executable cmd used.

if strcmp(computer,'GLNXA64')
    self.exec = 'avconv';
else
    self.exec = 'ffmpeg';
end
    
    
end

% ==============================================


function self = hre(self,varargin)
%
% HRE - Estimate heart rate response -- 
%
% Lock / Scale Forehead;
% Extract / Scale Green Channel Values;
% Estimate HR on Sample 30 sec.
% Measure HR for video.


    
end

% ==============================================

end

end