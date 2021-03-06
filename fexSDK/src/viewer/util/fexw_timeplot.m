function h = fexw_timeplot(fexObj,varargin)
%
% FEXW_TIMEPLOT generates plots of emotion timeseries.
%
% h = FEXW_TIMEPLOT(fexObj)
% h = FEXW_TIMEPLOT(fexObj,k)
% h = FEXW_TIMEPLOT(fexObj,k, ActionVal)
%
% fexObj is a FEXC object. Note that if fexObj is a stuck of FEXC objects,
% only the kth is shown. You can indicate which object to show entering the
% k argument (a scalar between 1 and length(fexObj). Default is 1.
% 
% The optional argument ActionVal is a string that indicate what to do with
% the image. Acceptable values are '-show', '-save'. Default is '-show.'
% When ActionVal is set to '-save,' no image is displayed.
%
% h is an handle to the figure if ActionVal is set to '-show,' and it is a
% string whith the path to the image if '-save' is used. Images are saved
% in a subfolder in the current directory. The subfolder is called
% 'fexwplots' (the directory will be created if it doesn't exist). The
% name of the image saved is obtained from the name of the video (i.e.
% fexObj.video). No image is overwritten, and a count is attached at the
% end of the name of the file. If the field fexObj.video is empty, the
% image is saved with the generic name fexwtimeplot_%2.d.pdf.
%
%
% See also FEXC, FEX_GETCOLORS, FEX_STRTIME.
%
%
% Copyright (c) - 2014 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 15-Dec-2014.

if nargin == 0
    error('You need to provide a FEXC argument.')
elseif ~isa(fexObj,'fexc')
    error('The first argument must be a FEXC object.');
end

% Read k argument
ind = cellfun(@isnumeric,varargin);
if isempty(ind) || sum(ind) == 0
    k = 1;
else
    k = varargin{ind};
    if k > length(fexObj)
        error('The argument k is bigger than fexObj.');
    end
end

% Change color pattern when you save
if sum(strcmpi('-save',varargin)) > 0
    base_color = [1,1,1];
    txt_color  = [0,0,0];
    sent_color = {'m','b'};
    line_color = '--k';
else
    base_color = [0,0,0];
    txt_color  = [1,1,1];
    sent_color = {'w','r'};
    line_color = '--w';
end

% Gather the data needed for the plots.
T = fexObj(k).time.TimeStamps;
Y = get(fexObj(k),'emotions');
YHDR = Y.Properties.VarNames;
I = ~isnan(sum(double(Y),2));
Y = double(Y(I == 1,:));
T = T(I == 1,:);

% Grab/Derive sentiments when not provided
if isempty(fexObj(k).sentiments)
    fexObj(k).derivesentiments;
end
S = fexObj(k).sentiments;

% Get colors for emotions
CLR = fex_getcolors(size(Y,2));

% Get name for the image
if isempty(fexObj(k).video)
    if isempty(fexObj(k).name)
        name = sprintf('plot %s',datestr(now,'HHMMSS'));
    else
        name  = fexObj(k).name;
    end
else
   [~,name] = fileparts(fexObj(k).video);
end

% Initialize the image with some costume properties
pos = [0,0, 9.27 11.69];
h = figure('Units','inches','Position',pos,'Visible','off','Name',name);
set(h,'Color',base_color,'ToolBar','none','MenuBar','none','NumberTitle','off');
axis tight

% Generate the sentiments plot
lims = max(2,max(abs(S.Combined)));
subplot(7,2,1:4),hold on, box on    
set(gca,'OuterPosition',[.025,.69,.994,.300],'Color',base_color); % [.001,.69,.994,.315]
set(gca,'XColor',txt_color,'YColor',txt_color,'LineWidth',2,'fontsize',12);
if size(T,1) < 1e4
    hh1 = area(T,S.Positive,'FaceColor',sent_color{1},'LineWidth',2,'EdgeColor',sent_color{1});
    hh2 = area(T,-1*S.Negative,'FaceColor',sent_color{2},'LineWidth',2,'EdgeColor',sent_color{2});
    alpha(.4);
else
    hh1 = plot(T,S.Positive,sent_color{1},'LineWidth',2);
    hh2 = plot(T,-1*S.Negative,sent_color{2},'LineWidth',2);
end

ylim([-lims,lims]); xlim([T(1),T(end)]);    
set(gca,'XTickLabel',fex_strtime(get(gca,'XTick'),'short'));
ylabel('Sentiment Scores','fontsize',12,'Color',txt_color);
legend([hh1,hh2],{'Positive','Negative'},'TextColor',txt_color,'Box','off','Location','NorthEastOutside');
title('Sentiments','fontsize',18);

% Generate the emotion plots
lims = [min(reshape(Y,numel(Y),1)),max(reshape(Y,numel(Y),1))];
lims(1) = min(lims(1),0);

for n = 1:size(Y,2)
    subplot(7,2,n+4), hold on
    set(gca,'Tag','EmoAx','box','on')
    if size(T,1) < 1e4
        area(T,Y(:,n),'basevalue',lims(1),'FaceColor',CLR(n,:),'LineWidth',2,'EdgeColor',CLR(n,:));
        alpha(.4)
    else
        plot(T,Y(:,n),'LineWidth',2,'Color',CLR(n,:));
    end
    ylim([lims(1),max(lims(2),2)]); xlim([T(1),T(end)]);
    plot(T,zeros(size(T)),line_color,'LineWidth',2);
    ylabel(YHDR{n},'fontsize',12,'Color',txt_color);
end
% Update common properties
he = findobj(h,'Tag','EmoAx');
x  = linspace(T(1),T(end),5);  
set(he,'Color',base_color,'XColor',txt_color,'YColor',txt_color,'XTick',...
    x,'XTickLabel',fex_strtime(x,'short'),'LineWidth',2);

% Saving/Showing image step
if sum(strcmpi('-save',varargin)) > 0
    if isempty(fexObj(k).get('dirout'))
        SAVE_TO = pwd;
    else
        SAVE_TO = char(fexObj(k).get('dirout'));
    end
    if ~exist([SAVE_TO,'/fexwplots'],'dir')
        mkdir([SAVE_TO,'/fexwplots']);
    end
    name = sprintf('%s/fexwplots/%s_i',SAVE_TO,name); q=1;
    while exist(sprintf('%s%.3d.pdf',name,q),'file')
        q = q + 1;
    end
    name = sprintf('%s%.3d.pdf',name,q);
    fprintf('Saving image %s ... ',name);
    print(h,'-dpdf','-r350',name);
    delete(h); h = name;
    fprintf('\n');
else
    set(h,'Visible','on');
end
  
