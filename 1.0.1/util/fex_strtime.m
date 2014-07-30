function str = fex_strtime(sec)
%
% str = fex_strtime(sec)
%
% Transforms a double "sec", into a string "hh:mm:ss.msc." Alternatively,
% transforms a string of the form "hh:mm:ss.msc" into a double. 
%
% "sec" can be a char, a cell, a double, or a vector.
%
%
%_______________________________________________________________________
%
%
% Copiright: Filippo Rossi, Institute for Neural Computation, University
% of California, San Diego.
%
% email: frossi@ucsd.edu
%
% Version: 06/14/14.


if isa(sec,'char')
    str = str2double(strsplit(sec,':'))*[60^2,60,1]';
elseif isa(sec,'cell')
    conrt = @(t)str2double(strsplit(t,':'));
    st = cellfun(conrt,sec,'UniformOutput',false);
    str = cell2mat(st)*[60^2,60,1]';
elseif isa(sec,'double')
    conrt = @(t) sprintf('%.2d:%.2d:%.3f',...
        floor(t/3600),floor(mod(t/60,60)),mod(t,60));
    str = cellfun(conrt,num2cell(sec),'UniformOutput',false);
end
         