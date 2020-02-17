function tlabel(varargin)
%TLABEL   Full date formatted tick labels with ZOOM, PAN and LINKAXES.
%
%   SYNTAX:
%     tlabel
%     tlabel(...,TICKAXIS)
%     tlabel(...,DATEFORM)
%     tlabel(...,'keeplimits')  vs  'freelimits'
%     tlabel(...,'keepticks')   vs  'freeticks'
%     tlabel(...,PRO,VAL,...)
%     tlabel(AX,...)
%     tlabel(...);
%
%   INPUT: (all optionals)
%     TICKAXIS     - Date axis. One of 'x', 'y' or 'z'.
%                    DEFAULT: 'x'
%     DATEFORM     - Numerical or string date format to be used on the
%                    ticks. See DATESTR for details. 
%                    DEFAULT: (as DATETICK, see NOTE below)
%     'keeplimits' - Preserves the axis limits or 'freelimits' to not.
%                    DEFAULT: (does it if axis limit mode is 'manual')
%     'keepticks'  - Preserves the ticks locations or 'freeticks' to not.
%                    DEFAULT: (does it if axis tick mode is 'manual')
%     PRO,VAL      - Property/value extra inputs.
%                    DEFAULT: (see TABLE below for details)  
%     AX           - Uses the specified axis, rather than the current axis.
%                    Axes are automatically linked if more than one were
%                    specified. May include figure handles see NOTE below
%                    for details.
%                    DEFAULT: gca
%
%   DESCRIPTION:
%     This program works as DATETICK but with ZOOM, PAN and LINK
%     functionalities.
%      
%     It's a mayor modification of DATETICKZOOM function by Lauwerys, by
%     including the LINK functionality and includes in the date axis Label
%     the part of the date that was left out by the TickLabels, allowing
%     the user to know the full date no matter the zooming in.
%
%     Besides, it includes some extra functionalities that the user may use
%     as usual Property/Value pair inputs, which are:
%
%      PROPERTY        POSSIBLE VALUES            DESCRIPTION
%     ---------------------------------------------------------------------
%      'Language'      'local' or 'en_us'         Sets months language.
%                      DEFAULT: 'local'          
%
%      'LinkOthers'    false, true, or            Links other axes besides
%                      the specified ones         time?
%                      ('yz' for example)
%                      DEFAULT: false
%
%      'WhichAxes'     'all', 'none', 'first',    Specifies on which axes
%                      'last', or the             to display the dates.
%                      specified axes handles
%                      DEFAULT: 'all'
%
%      'FixLow'        An integer or zero.        Indicates if more ticks
%                      DEFAULT: 4                 should be included when
%                                                 when less than 4 are
%                                                 displayed.
%
%      'FixHigh'       An integer or zero.        Indicates if less ticks
%                      DEFAULT: 11                should be used when more
%                                                 than 11 are displayed.
%
%      'NumFmtNN'      User custom (see NOTE      Change the MATLAB
%                      below for details)         default numeric date
%                      DEFAULT: by DATETICK       format: 'NN' by the 
%                                                 specified one.
%
%      'Reference'     'middle', 'first',         Specifies the date on
%                      'last' or 'none'           the time axis to be used
%                      DEFAULT: 'middle'          as reference for the
%                                                 whole date.
%
%      'LabelY'        DEFAULT: 'yyyy'            Numeric or string format
%                                                 on axis label when only
%                                                 year is displayed.
%
%      'LabelYM'       DEFAULT: 'mmm yyyy'        Numeric or string format
%                                                 on axis label when year
%                                                 and month are displayed.
%
%      'LabelYMD'      DEFAULT: 'dd/mmm/yyyy'     Numeric or string format
%                                                 on axis label when only
%                                                 year is displayed.
%     ---------------------------------------------------------------------
%    
%   NOTE:
%     * Optional inputs use its DEFAULT value when not given or [].
%     * For example, by default pairwise options: ('NumFmt6','dd/mmm') and
%       ('NumFmt17',12) are used. See DATETICK for details on the numeric
%       formats.
%     * Except from the optional AX input which must be the first one,
%       all other inputs arguments may be entered in any other position
%       (keeping the pairs always toghether, of course).
%     * The string inputs may be as short as posible, except for its value.
%       Besides, upper cases are ignored (try 'keepl' instead of
%       'KeepLimits').
%     * If DATEFORMAT is used, it will be used even after any ZOOM.
%     * 'keepticks' and 'keeplimits' are used by default if the TICKAXIS
%       ticks and limits mode is 'manual'. So, limits are preserved if
%       before TLABEL, axis tight was used.
%     * Use 'Reference','none' to avoid the using of the label axis.
%     * ADDITIONAL NOTES are included inside this file.
%
%   EXAMPLE:
%     tini = datenum([2009 05 29 12 00 00]);
%     dt   = 20/60/24;
%     N    = 100;
%     t    = (0:N-1)'*dt + tini;
%     figure(1), clf
%      subplot(311)
%       plot(t,3*cos(2*pi*t/12*24))
%      subplot(312)
%       plot(t,5*cos(2*pi*t/6*24))
%      subplot(313)
%       plot(t,8*cos(2*pi*t/3*24))
%      axis(findobj(gcf,'Type','axes'),'tight')
%     tlabel(gcf,'keepl','W','last')   % Dates printed only on last plot!
%     zoom on
%
%   SEE ALSO:
%     DATETICK, DATESTR, DATENUM
%     and
%     DATETICKZOOM by Christophe Lauwerys and LINKZOOM by Carlos Vargas
%     at http://www.mathworks.com/matlabcentral/fileexchange
%
%
%   ---
%   MFILE:   tlabel.m
%   VERSION: 2.6.1 (Sep 30, 2009) (<a href="matlab:web('http://www.mathworks.com/matlabcentral/fileexchange/authors/11258')">download</a>) 
%   MATLAB:  7.7.0.471 (R2008b)
%   AUTHOR:  Carlos Adrian Vargas Aguilera (MEXICO)
%   CONTACT: nubeobscura@hotmail.com

%   ADDITIONAL NOTES:
%     * The extra option 'WhichAxes' is helpful when the user wants to link
%       all the subplots in a figure, but with the date displayed only on
%       the lower ones, to avoid repetition.
%     * The program creates an application data (see SETAPPDATA) on each
%       axes called 'tlabel' (besides of 'axesLimAndTickLink',
%       'axesTickLabelLink' and 'labelStringLink' when linking axes) with
%       some stuff used by the program after zooming or panning. For
%       example, to retrieve the date format used on the current axes after
%       TLABEL was used, do the following: 
%         >> data = getappdata(gca,'tlabel');
%         >> data.TicksFmt

%   REVISIONS:
%   1.0      Released. (Apr 24, 2008)
%   2.0      Rewritten code. Mayor changes with inputs and link axes. No
%            more outputs allowed. (Jun 08, 2009) 
%   2.1      When 'keepticks' are used, now they are revised by the
%            fixTicks subfunction. If the user changes manually the axes
%            limits or ticks of the first axes handle, the 'keepticks' and
%            'keeplimits' are changed accordingly. (Jun 30, 2009).
%   2.1.1    Fixed small BUG with this new 'keep's options thanks to Ayal
%            Anis. (Jul 03, 2009)
%   2.1.2    Fixed another smaller BUG with this new 'keep's options. (Jul
%            14, 2009)
%   2.2      Finally fixed BUG with 'keep's options. Fixed bugs with
%            temporal figure creation. New 'none' option for 'Reference'.
%            Fixed BUG with Double-Click. Changed application data name
%            from 'tlabeldata' to 'tlabel'. (Jul 29, 2009)
%   2.3      Fixed BUG when using PLOTYY. Fixed BUG with 'WhichAxes' and
%            'Reference' parse inputs, besides this latter option now moves
%            the label to the selected reference (as observed and suggested
%            by Giles Lesser). (Aug 20, 2009)
%   2.4      Fixed BUG when displaying years. Fixed BUG with numeric format
%            (thanks to Roger Parkyn). Added 'freeticks' and 'freelimits'
%            options. (Aug 21, 2009)
%   2.5      Fixed BUG with year ticks and not empty label. Fixed BUG with
%            a unique DATETICK tick (thanks to Kelly Kearney). (Aug 21,
%            2009)
%   2.6      Fixed bugs with a unique tick (thanks to Mary-Louise
%            Timmermans). (Sep 07, 2009)
%   2.6.1    Fixed small bug with 'middle' reference (thanks to Ayal Anis).
%            (Sep 30, 2009)

%   DISCLAIMER:
%   tlabel.m is provided "as is" without warranty of any kind, under the
%   revised BSD license.

%   Copyright (c) 2008,2009 Carlos Adrian Vargas Aguilera

% -------------------------------------------------------------------------
% MAIN
% -------------------------------------------------------------------------

% Parameters.
myAppName   = 'tlabel';
zoomAppName = 'zoom_zoomOrigAxesLimits';
secPause    = 0.25; % Pauses for this seconds to check double-click

if ~((nargin==2) && isstruct(varargin{2}))
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % TLABEL called from command window or a M-file
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 % Sets defaults.
 data.AX         = gca;             % Gets axis handle.
 data.TICKAXIS   = 'x';             % Sets date axis.
 data.DATEFORM   = [];              % Fixed date format.
 data.FixLow     = 4;               % Adds ticks if there are < it.
 data.FixHigh    = 11;              % Delets ticks if there are > it.
 data.Which      = true;            % Writes Labels on date axis?
 data.KeepTicks  = false;           % Keeps original date axis ticks?
 data.KeepLimits = false;           % Keeps original ticks?
 data.LabelFmt   = [];              % Sets date label format.
 data.LabelY     = 'yyyy';          % Sets date format for years.
 data.LabelYM    = 'mmm yyyy';      %   ... for years and months.
 data.LabelYMD   = 'dd/mmm/yyyy';   %   ... for years, months and days.
 data.Language   = 'local';         % Sets laguage for string months.
 data.LinkOthers = false;           % Links other axes besides date?
 data.NumFmt     = ...
  mat2cell([1:31 0]',ones(1,32),1); % Change the 32 MATLAB date formats?
 data.NumFmt{6}  = 'dd/mmm';        %   Note: {32} is format 0. 
 data.NumFmt{17} = 12;
 data.Reference  = 'middle';        % Sets date label reference.
 data.TicksFmt   = [];              % Sets date ticks format.
 data.WhichAxes  = 'all';           % Sets where to write the ticks.
 
 % Gets inputs and/or defaults.
 data = parseInputs(data,varargin{:});
 
 % Checks the axes to be printed.
 data.Which = getWhichAxes(data.Which,data.WhichAxes,data.AX);
 
 % Writes labels and saves application data.
 writeLabels(data.AX(1),data,false,myAppName,zoomAppName)
 
 % Links the axes and labels and resets the ZOOM.
 linkAxes(data)
 
 % Sets the ZOOM and PAN functionality.
 for k = 1:length(data.AX)
  xa = data.AX(k);
  zh = zoom(xa);
  ph = pan(ancestor(xa,{'figure','uipanel'}));
  set(zh,'ActionPostCallback',@tlabel) 
  set(ph,'ActionPostCallback',@tlabel)
 end
 
else
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % TLABEL called after ZOOM or PAN
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 try
  
  % Gets input axes handle and check it. Fixed BUG, Aug 2009
  if ~isfield(varargin{2},'Axes'), return, end
  AX = varargin{2}.Axes(1); % In case it is a group.
  if ~ishandle(AX) || ~strcmp(get(AX,'Type'),'axes'), return, end
  if ~isappdata(AX,myAppName), return, end
   
  % Retrieves application data.
  data = getappdata(AX,myAppName);   
  
  % Eliminates closed axes.
  ind = false(1,length(data.AX));
  for k = 1:length(data.AX)
   if ~ishandle(data.AX(k))
    ind(k) = true;
   end
  end
  data.AX(ind)    = [];
  data.Which(ind) = [];
  
  % Check double-click. Fixed BUG, Jul 2009
  pause(secPause)
  drawnow
  doubleClick = strcmp('open',...
                   get(ancestor(AX,{'figure','uipanel'}),'SelectionType'));
  
  % Writes labels and saves application data.
  writeLabels(AX,data,doubleClick,myAppName,zoomAppName);
  
  % Checks if double-click or zoom out on current axes.
  if doubleClick || all(axis(AX)==getappdata(AX,zoomAppName))
   % Zooms out all axes.
   for k = 1:length(data.AX)
    axis(data.AX(k),getappdata(data.AX(k),zoomAppName))
   end
  end
  
 catch
  % Do not sets an error during execution, only displays it as a warning.
  warning('CVARGAS:tlabel:errorDuringZoomOrPanExecution',lasterr)
 end

end 

% =========================================================================
% SUBFUNCTIONS
% -------------------------------------------------------------------------

function writeLabels(AX,data,doubleClick,myAppName,zoomAppName)
% Writes ticks to be used.

% Get axis limits, ticks and number of ticks within.
[data,ticks,tlim] = useDatetick(AX,data,doubleClick,zoomAppName);

% Fixes ticks.
if ~isempty(data.TicksFmt) % Fixed BUG, Jun 2009
 [ticks,data] = fixTicks(ticks,tlim,data);
end

% Change numerical date format?
if isempty(data.DATEFORM) && ~isempty(data.TicksFmt)
 if data.TicksFmt==0, data.TicksFmt = 32; end
 data.TicksFmt = data.NumFmt{data.TicksFmt};
end

% Generates the labels.
if     ~isempty(data.DATEFORM)
 % Fixed formatted date.
 STicks = datestr(ticks,data.DATEFORM,data.Language);
 [SLabel,RLabel] = dateLabel(tlim,...
          data.LabelFmt,data.Reference,data.Language);
elseif ~isempty(data.TicksFmt)
 % Default formmated date.
 STicks = datestr(ticks,data.TicksFmt,data.Language);
 [SLabel,RLabel] = dateLabel(tlim,...
          data.LabelFmt,data.Reference,data.Language);
else
 % No date at all.
 STicks = num2str(ticks);
 SLabel = '';
 RLabel = [];
end
         
% Write new ticks and label.
for k = 1:length(data.AX)
 xa = data.AX(k);
 lh = get(xa,[data.TICKAXIS 'Label']);
  set(xa,[data.TICKAXIS 'Lim' ],tlim);
  set(xa,[data.TICKAXIS 'Tick'],ticks);
 if data.Which(k)
  set(xa,[data.TICKAXIS 'TickLabel'],STicks);
  set(lh,'String',SLabel) % Fixed bug, Aug 2009 (thanks to Kelly Kearney)
  if ~isempty(RLabel) % New feature, Aug 2009 (suggested by Giles Lesser)
   temp = get(lh,'Units');
   set(lh,'Units','data')
   PLabel = get(lh,'Position');
   PLabel(1*(strcmp(data.TICKAXIS,'x')) + ...
          2*(strcmp(data.TICKAXIS,'y')) + ...
          3*(strcmp(data.TICKAXIS,'z'))) = RLabel;
   set(lh,'Position',PLabel)
   set(lh,'Units',temp)
  end
 else
  set(xa,[data.TICKAXIS 'TickLabel'],[]);
 end
 % Saves data on each axes.
 setappdata(xa,myAppName,data);
end

function [data,ticks,tlim] = useDatetick(AX,data,doubleClick,zoomAppName)
% Gets ticks by using MATLAB's DATETICK.

% Gets date limits.
tlim = get(AX,[data.TICKAXIS 'Lim']);

% Generate a temporal invisible axes.
hf    = ancestor(AX,{'figure','uipanel'});
tempF = get(0    ,'CurrentFigure');
tempA = get(tempF,'CurrentAxes');
tf = figure(...
 'Visible'             ,'off',...
 'Units'               ,get(hf,'Units'),...
 'Position'            ,get(hf,'Position'));
xa = axes(...
 'Parent'              ,tf,...
 'Units'               ,get(AX,'Units'),...
 'Position'            ,get(AX,'Position'),...
 [data.TICKAXIS 'Lim'] ,tlim,...
 [data.TICKAXIS 'Tick'],get(AX,[data.TICKAXIS 'Tick']));
set(0    ,'CurrentFigure',tempF);
set(tempF,'CurrentAxes'  ,tempA);

% Optional DATETICK arguments.
opt = {};
if data.KeepLimits, opt{end+1} = 'keeplimits'; end
if data.KeepTicks,  opt{end+1} = 'keepticks'; end

% Generates new TickLabels with DATETICK.
if ~isempty(data.DATEFORM)
 % Manual DATEFORM.
 try
  datetick(xa,data.TICKAXIS,data.DATEFORM,opt{:})  
 catch
  % Unknown DATEFORM. Uses DATESTR latter.
  if isequal(data.LabelFmt,data.LabelY)
   datetick(xa,data.TICKAXIS,3,opt{:}) % 'mmm'
  elseif isequal(data.LabelFmt,data.LabelYM)
   datetick(xa,data.TICKAXIS,7,opt{:}) % 'dd'
  elseif isequal(data.LabelFmt,data.LabelYMD)
   datetick(xa,data.TICKAXIS,15,opt{:}) % 'HH:MM'
  elseif isnumeric(data.DATEFORM)
   datetick(xa,data.TICKAXIS,10,opt{:}) % 'yyyy'
  else
   datetick(xa,data.TICKAXIS,opt{:})
  end
 end
else
 % Auto DATEFORM.
 datetick(xa,data.TICKAXIS,opt{:})
end

% Checks if Double-Click.
if doubleClick && isappdata(AX,zoomAppName)
 axis(xa,getappdata(AX,zoomAppName))
 tlim = get(xa,[data.TICKAXIS 'Lim']);
 set(hf,'SelectionType','normal')
end

% Gets new date limits.
if ~data.KeepLimits
 tlim            = get(xa,[data.TICKAXIS 'Lim']);
 data.KeepLimits = true; % All zooms preserves the new limits.
end

% Gets parameter from date axis.
ticks   = get(xa,[data.TICKAXIS 'Tick']);
inticks = (ticks>=tlim(1)) & (ticks<=tlim(2));
if ~data.KeepTicks && sum(inticks(inticks))<2
 % Try again. Maybe something wrong with DATEFORM.
 datetick(xa,data.TICKAXIS,opt{:})
 ticks  = get(xa,[data.TICKAXIS 'Tick']);
 inticks = (ticks>=tlim(1)) & (ticks<=tlim(2));
 if sum(inticks(inticks))<2
  % Try again. Maybe is the axes size. Use defaut size.
  close(tf)
  tf = figure(...
   'Visible'             ,'off');
  xa = axes(...
   'Parent'              ,tf,...
   [data.TICKAXIS 'Lim'] ,tlim,...
   [data.TICKAXIS 'Tick'],get(AX,[data.TICKAXIS 'Tick']));
  set(0    ,'CurrentFigure',tempF);
  set(tempF,'CurrentAxes'  ,tempA);
  datetick(xa,data.TICKAXIS,opt{:})
  ticks  = get(xa,[data.TICKAXIS 'Tick']);
  inticks = (ticks>=tlim(1)) & (ticks<=tlim(2));
 end
end

% Checks ticks (seems to solve a problem with Double-Click).
if length(ticks)>1 && ~data.KeepTicks
 inticks = find(inticks);
 dticks  = diff(ticks([1 2]));
 if (dticks < (ticks(inticks(1))-tlim(1)))   || ...
    (dticks < (tlim(2)-ticks(inticks(end)))) 
  datetick(xa,data.TICKAXIS,'keeplimits')
  ticks = get(xa,[data.TICKAXIS 'Tick']);
  tlim  = get(xa,[data.TICKAXIS 'Lim']);
 end
end

% Finds datetick and label format.
tlab = get(xa,[data.TICKAXIS 'TickLabel']);
data = findFormat(ticks(1),tlab(1,:),data);

% Clear temporal axes and figure
delete(tf)

function [labeltext,labelref] = dateLabel(tlim,LabelFmt,Reference,Language)
% Set label text.
labeltext = '';
labelref  = [];
if ~isempty(LabelFmt)
 switch lower(Reference(1))
  case 'm'
   date0 = mean(tlim);
  case 'f'
   date0 = tlim(1);
  case 'l'
   date0 = tlim(2);
  case 'n'
   return
 end
 labeltext = datestr(date0,LabelFmt,Language); 
 labelref  = date0; % Fixed bug, Sep 2009. Thanks to Ayal Anis.
end

function Which = getWhichAxes(Which,WhichAxes,AX)
% Finds out the axes to be printed.
if ischar(WhichAxes)
 % Specifyed as a char.
 switch lower(WhichAxes)
  case 'all'
   % continue
  case 'none'
   Which(:)       = false;
  case 'first'
   Which(2:end)   = false;
  case 'last'
   Which(1:end-1) = false;
 end
else
 % Specifyed from axes handle.
 Which(:) = false;
 for k = 1:length(WhichAxes)
  [a,b] = ismember(WhichAxes(k),AX);
  if a
   Which(b) = true; 
  end
 end
end

function linkAxes(data)
% Links the time axes.

% Gets labels handles.
LH = get(data.AX,[data.TICKAXIS 'Label']);
if iscell(LH)
 LH = cell2mat(LH);
end
% Links Limits.
axesLimAndTickLink = linkprop(data.AX,...
 {[data.TICKAXIS 'Lim'],...
  [data.TICKAXIS 'Tick']});
% Links labels.
if any(data.Which)
 axesTickLabelLink = linkprop(data.AX(data.Which),...
  [data.TICKAXIS 'TickLabel']);
 labelStringLink = linkprop(LH(data.Which),'String');
else
 axesTickLabelLink = [];
 labelStringLink   = [];
end
% Links other axes Limits?
if (islogical(data.LinkOthers) && data.LinkOthers) || ...
 (isnumeric(data.LinkOthers) && data.LinkOthers)
 xyz = 'xyz';
elseif ischar(data.LinkOthers)
 xyz = data.LinkOthers;
else
 xyz = '';
end
xyz = xyz(xyz~=data.TICKAXIS);
while ~isempty(xyz)
 addprop(axesLimAndTickLink,[xyz(1) 'Lim'])
 xyz(1) = [];
end
% Saves Link on axes and resets its zoom.
for k = 1:length(data.AX)
 zoom(      data.AX(k),'reset')
 setappdata(data.AX(k),'axesLimAndTickLink',axesLimAndTickLink);
 setappdata(data.AX(k),'axesTickLabelLink' ,axesTickLabelLink);
 setappdata(     LH(k),'labelStringLink'   ,labelStringLink);
end
% Clears specified axes.
iclear = find(~data.Which);
if ~isempty(iclear)
 for h = data.AX(iclear).'
  set(    h,[data.TICKAXIS 'TickLabelMode'],'manual')
  set(    h,[data.TICKAXIS 'TickLabel'],[])
  set(get(h,[data.TICKAXIS 'Label']),'String','')
 end
end

function data = findFormat(tick,tlab,data)
% Gets date format from DATETICK ticks and sets the format for ticks and
% label of TLABEL. If date.TicksFmt is empty, then if date.DATEFORM is
% empty then DATETICKS won't be used, else the latter DATEFORM is used, by
% Carlos Vargas.

% Get dateformats that not include year (and months (and days)).
%    0 'dd-mmm-yyyy HH:MM:SS'    15 'HH:MM'               
%    1 'dd-mmm-yyyy'             16 'HH:MM PM'            
%    2 'mm/dd/yy'                17 'QQ-YY'               
%    3 'mmm'                     18 'QQ'                  
%    4 'm'                       19 'dd/mm'               
%    5 'mm'                      20 'dd/mm/yy'            
%    6 'mm/dd'                   21 'mmm.dd,yyyy HH:MM:SS'
%    7 'dd'                      22 'mmm.dd,yyyy'         
%    8 'ddd'                     23 'mm/dd/yyyy'          
%    9 'd'                       24 'dd/mm/yyyy'          
%   10 'yyyy'                    25 'yy/mm/dd'            
%   11 'yy'                      26 'yyyy/mm/dd'          
%   12 'mmmyy'                   27 'QQ-YYYY'             
%   13 'HH:MM:SS'                28 'mmmyyyy'             
%   14 'HH:MM:SS PM'             29 'yyyy-mm-dd'
%                                30 'yyyymmddTHHMMSS'
%                                31 'yyyy-mm-dd HH:MM:SS'
f{1} = [3:6 18:19];          % not years
f{2} = 7:9;                  % not (years +) month
f{3} = 13:16;                % not ((years +) month +) days
f{4} = [0:2 10:12 17 20:31]; % includes years

% Gets label length.
Nlab = length(tlab);

% Gets DATETICK format and sets label format.
for k = 1:length(f) % Fixed bug, Aug 2009
 % Searches in null, -y, -y-m or -y-m-d format.
 for m = f{k}
  nlab = datestr(tick,m);
  if (Nlab==length(nlab)) && strcmp(tlab,nlab)
   % Sets the DateFormat given by datetick.
   data.TicksFmt = m;
   % Search and write the DateFormat for Labels (if any). 
   if     k==1   % puts year
    data.LabelFmt = data.LabelY;
   elseif k==2   % puts year and month
    data.LabelFmt = data.LabelYM;
   elseif k==3   % puts year, month and day
    data.LabelFmt = data.LabelYMD;
   else
    data.LabelFmt = [];  % Fixed bug, Aug 2009
   end
   break
  end
 end
end
 
% Gets given DATEFORM and sets label format.
if isempty(data.DATEFORM) 
 % continue
elseif ischar(data.DATEFORM)  
 % Date format given as a string.
 % Checks if is some default format.
 switch data.DATEFORM
  case 'dd-mmm-yyyy HH:MM:SS', data.DATEFORM = 0;
  case 'dd-mmm-yyyy'         , data.DATEFORM = 1;
  case 'mm/dd/yy'            , data.DATEFORM = 2;
  case 'mmm'                 , data.DATEFORM = 3;
  case 'm'                   , data.DATEFORM = 4;
  case 'mm'                  , data.DATEFORM = 5;
  case 'mm/dd'               , data.DATEFORM = 6;
  case 'dd'                  , data.DATEFORM = 7;
  case 'ddd'                 , data.DATEFORM = 8;
  case 'd'                   , data.DATEFORM = 9;
  case 'yyyy'                , data.DATEFORM = 10;
  case 'yy'                  , data.DATEFORM = 11;
  case 'mmmyy'               , data.DATEFORM = 12;
  case 'HH:MM:SS'            , data.DATEFORM = 13;
  case 'HH:MM:SS PM'         , data.DATEFORM = 14;
  case 'HH:MM'               , data.DATEFORM = 15;
  case 'HH:MM PM'            , data.DATEFORM = 16;
  case 'QQ-YY'               , data.DATEFORM = 17;
  case 'QQ'                  , data.DATEFORM = 18;
  case 'dd/mm'               , data.DATEFORM = 19;
  case 'dd/mm/yy'            , data.DATEFORM = 20;
  case 'mmm.dd,yyyy HH:MM:SS', data.DATEFORM = 21;
  case 'mmm.dd,yyyy'         , data.DATEFORM = 22;
  case 'mm/dd/yyyy'          , data.DATEFORM = 23;
  case 'dd/mm/yyyy'          , data.DATEFORM = 24;
  case 'yy/mm/dd'            , data.DATEFORM = 25;
  case 'yyyy/mm/dd'          , data.DATEFORM = 26;
  case 'QQ-YYYY'             , data.DATEFORM = 27;
  case 'mmmyyyy'             , data.DATEFORM = 28;
  case 'yyyy-mm-dd'          , data.DATEFORM = 29;
  case 'yyyymmddTHHMMSS'     , data.DATEFORM = 30;
  case 'yyyy-mm-dd HH:MM:SS' , data.DATEFORM = 31;
  otherwise
   %continue
 end
 % Now sets the label format.
 if isnumeric(data.DATEFORM)
  % Search and write the DateFormat for Labels (if any). 
  if     ismember(data.DATEFORM,f{1})   % puts year
   data.LabelFmt = data.LabelY;
  elseif ismember(data.DATEFORM,f{2})   % puts year and month
   data.LabelFmt = data.LabelYM;
  elseif ismember(data.DATEFORM,f{3})   % puts year, month and day
   data.LabelFmt = data.LabelYMD;
  else
   data.LabelFmt = []; % Just clears the label
  end
 else
  % Searches for label format from the string DATEFORM.
  if     ~isempty(strfind(data.DATEFORM,'yy'))
   data.LabelFmt = [];
  elseif ~isempty(strfind(data.DATEFORM,'mm'))
   data.LabelFmt = data.LabelY;
  elseif ~isempty(strfind(data.DATEFORM,'dd'))
   data.LabelFmt = data.LabelYM;
  elseif ~isempty(strfind(data.DATEFORM,'HH'))
   data.LabelFmt = data.LabelYMD;
  elseif ~isempty(strfind(data.DATEFORM,'MM'))
   data.LabelFmt = [data.LabelYMD ' HH'];
  elseif ~isempty(strfind(data.DATEFORM,'SS'))
   data.LabelFmt = [data.LabelYMD ' HH:MM'];
  else
   data.LabelFmt = []; % Just clears the label
  end
 end
else % isnumeric(data.DATEFORM)
 % DateFormat given in numeric form.
 % Search and write the DateFormat for Labels (if any). 
 if     ismember(data.DATEFORM,f{1})   % puts year
  data.LabelFmt = data.LabelY;
 elseif ismember(data.DATEFORM,f{2})   % puts year and month
  data.LabelFmt = data.LabelYM;
 elseif ismember(data.DATEFORM,f{3})   % puts year, month and day
  data.LabelFmt = data.LabelYMD;
 else
  data.LabelFmt = []; % Just clears the label
 end
end

function [ticks,data] = fixTicks(ticks,tlim,data)
%   Adds some ticks when DATETICKS puts just a few or deletes some if it
%   puts too many. The quantities are specified by data.FixLow and
%   data.FixHigh. Use 0 quantity if adjust is not required. By Carlos
%   Vargas

% Sets minimum and maximum number of ticks.
MinDayTicks = 4;
if data.KeepTicks
 MinDayTicks = length(ticks);
elseif (data.FixLow==0)
 MinDayTicks = -Inf;
elseif data.FixLow>1
 MinDayTicks = data.FixLow;
end
MaxDayTicks = 11;
if data.KeepTicks
 MaxDayTicks = length(ticks);
elseif (data.FixHigh==0)
 MaxDayTicks = Inf;
elseif data.FixHigh>1
 MaxDayTicks = data.FixHigh;
end
if MaxDayTicks <= MinDayTicks
 MaxDayTicks = MinDayTicks;
end

% Checks maximum number of ticks.
inticks = sum((ticks>=tlim(1)) & (ticks<=tlim(2)));
if (data.FixHigh~=0)
 ticks2   = ticks;
 inticks2 = inticks;
 k        = 0;
 while (inticks2>max(MaxDayTicks,1)) && (k<3) % Fixed bug, Aug 2009
  k        = k+1;
  ticks2   = ticks2(1:2:end);
  inticks2 = sum((ticks2>=tlim(1)) & (ticks2<=tlim(2)));
 end
 ticks   = ticks2;
 inticks = inticks2;
end

% Checks minimum number of ticks and its format.
if data.FixLow~=0
 kmax = 4;
 k    = 0;
 if data.KeepTicks
  tickskeep = ticks;
 end
 if ~isempty(data.DATEFORM)
  LabelFmt = data.LabelFmt;
 end
 % Tries to increase the number of ticks after some trials.
 while (k<kmax) && ((inticks<MinDayTicks) || data.KeepTicks)
  k = k+1;
  
  %    0 'dd-mmm-yyyy HH:MM:SS'    15 'HH:MM'               
  %    1 'dd-mmm-yyyy'             16 'HH:MM PM'            
  %    2 'mm/dd/yy'                17 'QQ-YY'               
  %    3 'mmm'                     18 'QQ'                  
  %    4 'm'                       19 'dd/mm'               
  %    5 'mm'                      20 'dd/mm/yy'            
  %    6 'mm/dd'                   21 'mmm.dd,yyyy HH:MM:SS'
  %    7 'dd'                      22 'mmm.dd,yyyy'         
  %    8 'ddd'                     23 'mm/dd/yyyy'          
  %    9 'd'                       24 'dd/mm/yyyy'          
  %   10 'yyyy'                    25 'yy/mm/dd'            
  %   11 'yy'                      26 'yyyy/mm/dd'          
  %   12 'mmmyy'                   27 'QQ-YYYY'             
  %   13 'HH:MM:SS'                28 'mmmyyyy'             
  %   14 'HH:MM:SS PM'             29 'yyyy-mm-dd'
  %                                30 'yyyymmddTHHMMSS'
  %                                31 'yyyy-mm-dd HH:MM:SS'  
  
  % Checks the date part icluded in the format.
  isformat = [0 0 0 0 0 0];
  if     ismember(data.TicksFmt,[0 13:14 21 30:31]) % Seconds
   isformat(6) = 1;
  elseif ismember(data.TicksFmt,15:16)            % Hours and minutes
   isformat(4) = 1;
  elseif ismember(data.TicksFmt,[1:2 6:9 19:26 29]) % Days
    isformat(3) = 1;
  elseif ismember(data.TicksFmt,[3:5 12 28])     % Months
   isformat(2) = 1;
  elseif ismember(data.TicksFmt,10:11)           % Years
   isformat(1) = 1;
  end
  
  % Now adds ticks corresponding to the format.
 
  % SECONDS ===============================================================
  if isformat(6)
   % Checks size.
   if length(ticks)<2, continue, end
   % Changes serial date to vector.
   ticks = datevec(ticks+0.1/86400); ticks(:,6) = round(ticks(:,6));
   % Gets date interval in seconds.
   dt = round((datenum(ticks(2,1:6))-datenum(ticks(1,1:6)))*86400);
   % Gets increase factor from factorization.
   dtf = factor(dt); dtf = dtf(1);
   % Gets new date interval.
   dt = dt/dtf; 
   % Gets new number of ticks. 
   nticks = (size(ticks,1)+1)*dtf;
   % Generates new ticks.
   yyt   = repmat(ticks(1,1),nticks,1);
   mmt   = repmat(ticks(1,2),nticks,1);
   ddt   = repmat(ticks(1,3),nticks,1);
   HHt   = repmat(ticks(1,4),nticks,1);
   MMt   = repmat(ticks(1,5),nticks,1);
   SSt   = ((0:nticks-1)'-dtf)*dt + ticks(1,6);
   ticks = datenum([yyt mmt ddt HHt MMt SSt]);
   % Checks ticks outside limits.
   inticks = (ticks>=tlim(1)) & (ticks<=tlim(2));
   ticks(~inticks)   = [];
   inticks(~inticks) = [];
   inticks = sum(inticks(inticks));
   if inticks<2, continue, end
   % Checks maximum number of ticks.
   if data.FixHigh
    l = 0;
    while (inticks>MaxDayTicks) && (l<3)
     l = l+1;
     tempticks = ticks;
     ticks     = ticks(1:2:end);
     inticks   = sum((ticks>=tlim(1)) & (ticks<=tlim(2)));
     if inticks<MinDayTicks
      ticks = tempticks;
      k = Inf;
      break
     end
    end
   end
   % Checks if seconds were not used. 'HH:MM' to be used.
   ticks2 = datevec(ticks(1:2)+0.1/86400);
   if round(ticks2(1,6))==round(ticks2(2,6))
    data.TicksFmt = 15;
   end 
       
  % HOURS or MINUTES ======================================================
  elseif isformat(4) || isformat(5)
   % Checks size. 'HH:MM:SS' to be used?
   if length(ticks)<2, k = k-1; data.TicksFmt = 13; continue, end
   % Changes serial date to vector.
   ticks    = datevec(ticks+0.1/86400);
   if ticks(2,5)~=ticks(1,5)
    % MINUTES.
    % Gets date interval in minutes.
    dt = round((datenum([ticks(2,1:5) 0])-datenum([ticks(1,1:5) 0]))*1440);
   else % ((ticks(1,4)+ticks(2,4))==0) || (ticks(2,4)~=ticks(1,4))
    % HOURS
    % Gets date interval in hours.
    dt = round((datenum([ticks(2,1:4) 0 0]) - ...
                datenum([ticks(1,1:4) 0 0]))*24);
   end
   % 'HH:MM:SS' to be used?
   if dt==0
    ticks = datenum(ticks);
    k = k-1;
    data.TicksFmt = 13;
    continue
   end
   % Gets increase factor from factorization.
   dtf = factor(dt); dtf = dtf(1);
   % Gets new date interval.
   dt = dt/dtf;
   % Gets new number of ticks. 
   nticks = (size(ticks,1)+1)*dtf;
   % Generates new ticks.
   yyt = repmat(ticks(1,1),nticks,1);
   mmt = repmat(ticks(1,2),nticks,1);
   ddt = repmat(ticks(1,3),nticks,1);
   if ticks(2,5)~=ticks(1,5)
    % MINUTES.
    HHt = repmat(ticks(1,4),nticks,1);
    MMt = ((0:nticks-1)'-dtf)*dt + ticks(1,5);
    SSt = zeros(nticks,1);
   else % ((ticks(1,4)+ticks(2,4))==0) || (ticks(2,4)~=ticks(1,4))
    % HOURS
    HHt = ((0:nticks-1)'-dtf)*dt + ticks(1,4);
    MMt = zeros(nticks,1);
    SSt = MMt;
   end
   ticks = datenum([yyt mmt ddt HHt MMt SSt]);
   % Checks ticks outside limits.
   inticks = (ticks>=tlim(1)) & (ticks<=tlim(2));
   % 'HH:MM:SS' to be used?
   if sum(inticks(inticks))<2 
    k = k-1; 
    data.TicksFmt = 13;
    inticks = sum(inticks(inticks));
    continue
   end
   % Clears bad ticks.
   ticks(~inticks) = [];
   inticks = sum(inticks(inticks));
   % Checks maximum number of ticks.
   if data.FixHigh
    l = 0;
    while (inticks>MaxDayTicks) && (l<3)
     l = l+1;
     tempticks = ticks;
     ticks     = ticks(1:2:end);
     inticks   = sum((ticks>=tlim(1)) & (ticks<=tlim(2)));
     if inticks<MinDayTicks
      ticks = tempticks;
      k = Inf;
      break
     end
    end
   end
   % Checks if seconds are used or if minutes/hours are not used.
   ticks2 = datevec(ticks(1:2)+0.1/86400);
   if round(ticks2(1,6))~=round(ticks2(2,6))
    % 'HH:MM:SS' to be used.
    data.TicksFmt = 13;
   elseif (round(ticks2(1,5))==round(ticks2(2,5))) && ...
           round(ticks2(1,4))==round(ticks2(2,4))
    % Minutes/hours not used. 'mm/dd' to be used.
     data.TicksFmt = 6; 
     data.LabelFmt = data.LabelY;
   elseif (k==kmax) && (inticks<MinDayTicks)
    k = 0;
    % 'HH:MM:SS' to be used.
    data.TicksFmt = 13;
   end 
      
  % DAYS ==================================================================
  elseif isformat(3)
   % Checks size. 'HH:MM' to be used?
   if length(ticks)<2 
    k = k-1; 
    data.TicksFmt = 15; 
    data.LabelFmt = data.LabelYMD; 
    continue 
   end
   % Changes serial date to vector.
   ticks   = datevec(ticks);
   % Gets date interval in days.
   dt      = datenum([ticks(2,1:3) 0 0 0])-datenum([ticks(1,1:3) 0 0 0]);
   if dt==0
    ticks = datenum(ticks);
    k = k-1;
    % 'HH:MM' to be used.
    data.TicksFmt = 15;
    data.LabelFmt = data.LabelYMD;
    continue
   end
   if dt>27 && dt<32
    % One month interval, decreased to 15 days.
    nticks = 2*size(ticks,1);
    % Generates new ticks.
    yyt    = ticks(:,1);
    mmt    = ticks(:,2);
    yyt    = [yyt yyt].'; yyt = yyt(:);
    mmt    = [mmt mmt].'; mmt = mmt(:);
    ddt    = [ones(nticks/2,1) repmat(15,nticks/2,1)].'; ddt = ddt(:);
   else
    % Just increases the old interval
    % Gets increase factor from factorization.
    dtf    = factor(round(dt)); dtf = dtf(1);
    % Gets new date interval.
    dt     = dt/dtf;
    % Gets new number of ticks. 
    nticks = size(ticks,1); nticks = dtf*(nticks+1); 
    % Generates new ticks.
    yyt    = repmat(ticks(1,1),nticks,1);
    mmt    = repmat(ticks(1,2),nticks,1);
    ddt    = ((0:nticks-1)'-dtf)*dt + ticks(1,3);
   end
   HHt     = zeros(nticks,1);
   MMt     = HHt;
   SSt     = MMt;
   ticks   = datenum([yyt mmt ddt HHt MMt SSt]);
   % Checks ticks outside limits.
   inticks = (ticks>=tlim(1)) & (ticks<=tlim(2));
   % 'HH:MM' to be used?
   if sum(inticks(inticks))<2
    k = k-1; 
    data.TicksFmt = 15; 
    data.LabelFmt = data.LabelYMD;
    inticks = sum(inticks(inticks));
    continue 
   end
   % Clears bad ticks.
   ticks(~inticks)   = [];
   inticks = sum(inticks(inticks));
   % Checks maximum number of ticks.
   if data.FixHigh
    l = 0;
    while (inticks>MaxDayTicks) && (l<3)
     l = l+1;
     tempticks = ticks;
     ticks     = ticks(1:2:end);
     inticks   = sum((ticks>=tlim(1)) & (ticks<=tlim(2)));
     if inticks<MinDayTicks
      ticks = tempticks;
      k = Inf;
      break
     end
    end
   end
   % Checks if hours are used or if days are not used.
   ticks2 = datevec(ticks(1:2)+0.1/86400);
   if round(ticks2(1,4))~=round(ticks2(2,4))
    % Hours used.
    data.TicksFmt = 15; % 'HH:MM'
    data.LabelFmt = data.LabelYMD;
   elseif round(ticks2(1,3))==round(ticks2(2,3))
    % Days not used.
     data.TicksFmt = 3; % 'mmm'
     data.LabelFmt = data.LabelY;
   elseif (k==kmax) && (inticks<MinDayTicks)
    k = 0;
    % Hours to be used.
    data.TicksFmt = 15; % 'HH:MM'
    data.LabelFmt = data.LabelYMD;
   end
   
  % MONTHS ================================================================
  elseif isformat(2) % Adds months
   % Checks size. 'mm/dd' to be used?
   if length(ticks)<2, k = k-1; data.TicksFmt = 6; continue, end
   % Changes serial date to vector.
   ticks = datevec(ticks);
   % Gets date interval in months.
   dt = ticks(2,2) - (ticks(1,2))+12*(ticks(2,1)-ticks(1,1));
   if dt==0
    ticks = datenum(ticks);
    k = k-1;
    % 'mm/dd' to be used.
    data.TicksFmt = 6;
    continue
   end
   % Gets increase factor from factorization.
   dtf = factor(round(dt)); dtf = dtf(1);
   % Gets new date interval.
   dt = dt/dtf;
   % Gets new number of ticks. 
   nticks = (size(ticks,1)+1)*dtf;
   % Generates new ticks.
   yyt     = repmat(ticks(1,1),nticks,1);
   mmt     = ((0:nticks-1)'-dtf)*dt + ticks(1,2);
   ineg    = mmt<=0;
   while any(ineg)
    yyt(ineg) = yyt(ineg)-1;
    mmt(ineg) = mmt(ineg)+12;
    ineg      = mmt<=0;
   end
   ddt     = ones(nticks,1);
   HHt     = zeros(nticks,1);
   MMt     = HHt;
   SSt     = MMt;
   ticks   = datenum([yyt mmt ddt HHt MMt SSt]);
   % Checks ticks outside limits.
   inticks = (ticks>=tlim(1)) & (ticks<=tlim(2));
   % 'mm/dd' to be used?
   if sum(inticks(inticks))<2 
    k = k-1; 
    data.TicksFmt = 6; 
    inticks = sum(inticks(inticks));
    continue 
   end
   % Clears bad ticks.
   ticks(~inticks) = [];
   inticks = sum(inticks(inticks));
   % Checks maximum number of ticks.
   if data.FixHigh
    l = 0;
    while (inticks>MaxDayTicks) && (l<3)
     l = l+1;
     tempticks = ticks;
     ticks     = ticks(1:2:end);
     inticks   = sum((ticks>=tlim(1)) & (ticks<=tlim(2)));
     if inticks<MinDayTicks
      ticks = tempticks;
      k = Inf;
      break
     end
    end
   end
   % Checks if days are used or if months are not used.
   ticks2 = datevec(ticks(1:2)+0.1/86400);
   if round(ticks2(1,3))~=round(ticks2(2,3))
    % 'mm/dd' to be used.
    data.TicksFmt = 6;
   elseif round(ticks2(1,2))==round(ticks2(2,2))
    % Months not used. 'yyyy' to be used.
     data.TicksFmt = 10;
     data.LabelFmt = '';
   elseif (k==kmax) && (inticks<MinDayTicks)
    k = 0;
    % 'mm/dd' to be used.
    data.TicksFmt = 6;
    data.LabelFmt = data.LabelY;
   end  
      
  % YEARS =================================================================
  elseif isformat(1) % Adds years
   % Checks size. 'mmm' to be used?
   if length(ticks)<2 
    k = k-1; 
    data.TicksFmt = 3; 
    data.LabelFmt = data.LabelY;
    continue 
   end
   % Changes serial date to vector.
   ticks = datevec(ticks);
   % Gets date interval in years.
   dt = ticks(2,1) - ticks(1,1);
   if dt==0
    ticks = datenum(ticks);
    k = k-1;
    % 'mmm' to be used.
    data.TicksFmt = 3;
    data.LabelFmt = data.LabelY;
    continue
   end
   % Gets increase factor from factorization.
   dtf = factor(round(dt)); dtf = dtf(1);
   % Gets new date interval.
   dt = dt/dtf; 
   % Gets new number of ticks. 
   nticks = (size(ticks,1)+1)*dtf;
   % Generates new ticks.
   yyt       = ((0:nticks-1)'-dtf)*dt + ticks(1,1);
   mmt       = ones(nticks,1);
   ddt       = mmt;
   HHt       = zeros(nticks,1);
   MMt       = HHt;
   SSt       = MMt;
   ineg      = yyt<0;
   yyt(ineg) = [];
   mmt(ineg) = [];
   ddt(ineg) = [];
   HHt(ineg) = [];
   MMt(ineg) = [];
   SSt(ineg) = [];
   ticks     = datenum([yyt mmt ddt HHt MMt SSt]);
   % Checks ticks outside limits.
   inticks = (ticks>=tlim(1)) & (ticks<=tlim(2));
   % 'mmm' to be used?
   if sum(inticks(inticks))<2 
    k = k-1; 
    data.TicksFmt = 3; 
    data.LabelFmt = data.LabelY;
    inticks = sum(inticks(inticks));
    continue 
   end
   % Clears bad ticks.
   ticks(~inticks) = [];
   inticks = sum(inticks(inticks));
   % Checks maximum number of ticks.
   if data.FixHigh
    l = 0;
    while (inticks>MaxDayTicks) && (l<3)
     l = l+1;
     tempticks = ticks;
     ticks     = ticks(1:2:end);
     inticks   = sum((ticks>=tlim(1)) & (ticks<=tlim(2)));
     if inticks<MinDayTicks
      ticks = tempticks;
      k = Inf;
      break
     end
    end
   end
   % Checks if months are used.
   ticks2 = datevec(ticks(1:2)+0.1/86400);
   if round(ticks2(1,2))~=round(ticks2(2,2))
    % 'mmm' to be used.
    data.TicksFmt = 3;
    data.LabelFmt = data.LabelY;
   elseif (k==kmax) && (inticks<MinDayTicks)
    k = 0;
    % 'mmm' to be used.
    data.TicksFmt = 3;
    data.LabelFmt = data.LabelY;
   end 
  end
 end
 if data.KeepTicks
  ticks = tickskeep;
 end
 if ~isempty(data.DATEFORM)
  data.LabelFmt = LabelFmt;
 end
end

function data = parseInputs(data,varargin)
% Retrieves inputs.

% Looks for axes handles.
if nargin>1 && ~isempty(varargin{1}) && all(ishandle(varargin{1}))
 data.AX = [];
 for k = 1:length(varargin{1})
  switch get(varargin{1}(k),'type')
  case {'figure','uipanel'}
   % Find axes on figures.
   ax = sort(findobj(varargin{1}(k),'-depth',1,'Type','axes',...
    '-not','Tag','Colorbar','-not','Tag','legend'));
  case 'axes'
   % Directc from axes.
   ax = varargin{1}(k);
  otherwise
   error('CVARGAS:tlabel:incorrectHandleInput', ...
         'Input handle must be from figures, uipanels or axes.')
  end
  data.AX = [data.AX; ax(:)];
 end
 if isempty(data.AX)
   error('CVARGAS:tlabel:incorrectHandleInput', ...
         'Input handle must be from figures, uipanels or axes.')
 end
 varargin(1) = [];
end

% Initializes Which.
data.Which = ishandle(data.AX);

% Parses all other inputs.
givenKeepTicks  = false;
givenKeepLimits = false;
while ~isempty(varargin)
 
 if isempty(varargin{1})
  % continue
 elseif ischar(varargin{1})
  % Look for strings inputs.
  
  switch lower(varargin{1})
   case {'keeplimits','keeplimit','keeplimi','keeplim','keepli','keepl'}
    data.KeepLimits = true;
    givenKeepLimits = true;
   case {'keepticks','keeptick','keeptic','keepti','keept'}
    data.KeepTicks = true; 
    givenKeepTicks = true;
   case {'freelimits','freelimit','freelimi','freelim','freeli','freel'}
    data.KeepLimits = false;
    givenKeepLimits = true;
   case {'freeticks','freetick','freetic','freeti','freet'}
    data.KeepTicks = false; 
    givenKeepTicks = true;
   case 'x'
    data.TICKAXIS = 'x';
   case 'y'
    data.TICKAXIS = 'y';
   case 'z'
    data.TICKAXIS = 'z';
   case {'language','languag','langua','langu','lang','lan','la'}
    if length(varargin)>1 && ...
       (strcmpi(varargin{2},'local') || strcmpi(varargin{2},'en_us'))
     data.Language = varargin{2};
    else
     warning('CVARGAS:tlabel:incorrectLanguageInput', ...
      '''Language'' must be one of ''local'' or ''en_us''. Default used.')
    end
    varargin(1) = []; % Clear property name
   case {'linkothers','linkother','linkothe','linkoth','linkot','linko',...
         'link','lin','li'}
    if (length(varargin)>1) && ((ischar(varargin{2}) && ...
       (length(varargin{2})<3) && ...
       (strcmpi(varargin{2},'x')  || strcmpi(varargin{2},'y')  || ...
        strcmpi(varargin{2},'z')  || strcmpi(varargin{2},'xy') || ...
        strcmpi(varargin{2},'yx') || strcmpi(varargin{2},'yz') || ...
        strcmpi(varargin{2},'zy') || strcmpi(varargin{2},'xz') || ...
        strcmpi(varargin{2},'zx'))) || islogical(varargin{2}))
     data.LinkOthers = varargin{2};
    else
     warning('CVARGAS:tlabel:incorrectLinkothersInput', [...
      '''LinkOthers'' must be one of ''x'', ''y'', ''z'', or a ' ...
      'combination, or a logical. Default used.'])
    end
    varargin(1) = []; % Clear property name
   case {'whichaxes','whichaxe','whichax','whicha','which','whic','whi',...
         'wh','w'} % Fixed BUG, Aug 2009 (thanks to Giles Lesser)
    if (length(varargin)>1) && ((ischar(varargin{2}) && ...
     (strcmpi(varargin{2},'all')   || strcmpi(varargin{2},'none') || ...
      strcmpi(varargin{2},'first') || strcmpi(varargin{2},'last'))) || ...
      all(ishandle(varargin{2})))
    data.WhichAxes = varargin{2};
    else
     warning('CVARGAS:tlabel:incorrectWhichaxesInput', [...
      '''WhichAxes'' must be one of ''all'', ''none'', ''first'', '...
      '''last'' or specific axes handles. Default used.'])
    end
    varargin(1) = []; % Clear property name
   case {'fixlow','fixlo','fixl'}
    if (length(varargin)>1) && (numel(varargin{2})==1) && ...
        isfinite(varargin{2})
     data.FixLow = round(abs(varargin{2})); % Forces integer
    else
     warning('CVARGAS:tlabel:incorrectFixlowInput', ...
      '''FixLow'' must be a positive integer or zero. Default used.')
    end
    varargin(1) = []; % Clear property name
   case {'fixhigh','fixhig','fixhi','fixh'}
    if (length(varargin)>1) && (numel(varargin{2})==1) && ...
        isfinite(varargin{2})
     data.FixHigh = varargin{2};
    else
     warning('CVARGAS:tlabel:incorrectFixHighInput', ...
      '''FixHigh'' must be a positive integer or zero. Default used.')
    end
    varargin(1) = []; % Clear property name
   case {'reference','referenc','referen','refere','refer','refe','ref',...
     're','r'} % Fixed BUG, Aug 2009 (tanhks to Giles Lesser)
    if (length(varargin)>1) && (ischar(varargin{2}) &&...
       (strcmpi(varargin{2},'middle') || strcmpi(varargin{2},'first') ||...
        strcmpi(varargin{2},'last')) || strcmpi(varargin{2},'none'))
    data.Reference = varargin{2};
    else
     warning('CVARGAS:tlabel:incorrectReferenceInput', [...
      '''Reference'' must be one of ''middle'', ''first'', ''last'' or '...
      '''none''. Default used.'])
    end
    varargin(1) = []; % Clear property name
   case 'labely'
    try
     datestr(1,varargin{2});
     data.LabelY = varargin{2};
    catch
     warning('CVARGAS:tlabel:incorrectLabelyInput', ...
      '''LabelY'' must be a valid date format. Default used.')
    end
    varargin(1) = []; % Clear property name
   case 'labelym'
    try
     datestr(1,varargin{2});
     data.LabelYM = varargin{2};
    catch
     warning('CVARGAS:tlabel:incorrectLabelymInput', ...
      '''LabelYM'' must be a valid date format. Default used.')
    end
    varargin(1) = []; % Clear property name
   case 'labelymd'
    try
     datestr(1,varargin{2});
     data.LabelYMD = varargin{2};
    catch
     error('CVARGAS:tlabel:incorrectLabelymdInput', ...
      '''LabelYMD'' must be a valid date format. Default used.')
    end
    varargin(1) = []; % Clear property name
 
   otherwise
    % A different char input.
    
    if length(varargin{1})>6 && strcmpi(varargin{1}(1:6),'numfmt')
     % Look for NumFmtNN input.
     
     numfmt = str2double(varargin{1}(7:end));
     if ismember(numfmt,0:31)
      if numfmt==0, numfmt = 32; end
      try
       datestr(1,varargin{2});
       data.NumFmt{numfmt} = varargin{2};
      catch
       warning('CVARGAS:tlabel:incorrectNumfmtnnStringInput', ...
        '''NumFmtNN'' must be a valid date format. Default used.')
      end
     else
      warning('CVARGAS:tlabel:incorrectNumfmtnnNumericInput', ...
       ['''NN'' in ''NumFmtNN'' must be an integer from ''0'' to '...
        '''31''. Default used.'])
     end
     varargin(1) = []; % Clear property name

    else
     % Look for DATEFORM string input.
     try
      datestr(1,varargin{1});
      data.DATEFORM = varargin{1};
     catch
      warning('CVARGAS:tlabel:incorrectDateformStringInput', ...
       ['String ''DATEFORM'' must be a valid date format or a not ' ...
        'recognized property were given. Default used.'])
     end
    end
    
  end

 else
  % Numeric DATEFORM input?
  if isnumeric(varargin{1}) && isfinite(varargin{1}) && ...
    (numel(varargin{1})==1) && ismember(varargin{1},0:31) % Fixed bug, Aug 2009
   data.DATEFORM = varargin{1};
  else
   warning('CVARGAS:tlabel:incorrectDateformNumericInput', ...
    'Numeric ''DATEFORM'' must be an integer from 0 to 31. Default used')
  end
 end
 
 % Deletes readed input:
 varargin(1) = []; % Clear property value
 
end

% Fixed BUG (3rd time!), Jul 2009. Thanks to Ayal Anis.
if ~givenKeepTicks && ~data.KeepTicks && ...
 all(strcmp(get(data.AX,[data.TICKAXIS 'TickMode']),'manual'))
 data.KeepTicks = true;
end
if ~givenKeepLimits && ~data.KeepLimits && ...
 all(strcmp(get(data.AX,[data.TICKAXIS 'LimMode']),'manual'))
 data.KeepLimits = true;
end


% [EOF]   tlabel.m