%%surfacePlotter
    %Visualizes ASOS 5-minute data on two figures. One is a timeseries of
    %temperature, dewpoint, pressure, and relative humidity on a standard
    %xy plot with wind shown using barbs. The second is an abacus plot of
    %precipitation type, which is only shown if precipitation, fog, or mist
    %occurred in the input time. Additionally, returns the subset of the
    %input data structure corresponding to the requested times.
    %
    %General form: [surfaceSubset] = surfacePlotter(startDatetime,endDatetime,ASOS)
    %
    %Output:
    %surfaceSubset: a subset of ASOS data corresponding to the input times.
    %
    %Inputs:
    %startDatetime: datetime created with datetime(Y,M,D,H,m,S)
    %endDatetime: datetime created with datetime(Y,M,D,H,m,S)
    %ASOS: structure of ASOS data
    %
    %Figures:
    %surface conditions: three-axis timeseries displaying humidity,
    %   surface pressure, and temperature/dewpoint, with wind and wind
    %   character velocity displayed as barbs
    %precipitation: abacus plot timeseries of weather codes as wires, with
    %   beads representing the current precipitation type(s)
    %
    %Requires external functions tlabel, addaxis, and windbarb
    %   Be sure to add the addaxis6 folder to the path before running
    %   surfacePlotter.
    %
    %Ideas for future development: display precipitation intensity on abacus plot
    %
    %Written by: Daniel Hueholt
    %North Carolina State University
    %Undergraduate Research Assistant at Environment Analytics
    %Version date: 5/27/2020
    %Last major revision: 5/27/2020
    %
    %tlabel written by Carlos Adrian Vargas Aguilera, last updated 9/2009,
    %   found on the MATLAB File Exchange. License information in repo.
    %addaxis written by Harry Lee, last updated 7/7/2016, found on the
    %   MATLAB File Exchange. License information in repo and in addaxis6
    %   folder.
    %windbarb written by Laura Tomkins, last updated 5/2017, found on
    %   Github at user profile @lauratomkins. Used by permission.
    %
    %
    %See also ASOSdownloadFiveMin, ASOSimportFiveMin
    %
    
function [surfaceSubset] = surfacePlotter(startDatetime,endDatetime,ASOS)
%% Check inputs
if startDatetime > endDatetime
    timeErrMsg = 'Start of period must be earlier than end! Check inputs and try again.';
    error(timeErrMsg)
end

if ~isequal(startDatetime.Second,0) || ~isequal(endDatetime.Second,0)
    secondWarning = 'ASOS does not record to second precision! Correcting input to zero...';
    warning(secondWarning)
    startDatetime.Second = 0;
    endDatetime.Second = 0;
    disp(['Corrected start time is: ' datestr(startDatetime)])
    disp(['Corrected start time is: ' datestr(endDatetime)])
else
    disp(['Start time is: ' datestr(startDatetime)])
    disp(['End time is: ' datestr(endDatetime)])
end

if mod(startDatetime.Minute,5) ~= 0 || mod(endDatetime.Minute,5) ~=0
    minuteWarning = 'Observations available at five-minute intervals only. Flooring minute to nearest 5...';
    warning(minuteWarning)
    startDatetime.Minute = 5*floor(startDatetime.Minute./5);
    endDatetime.Minute = 5*floor(endDatetime.Minute./5);
    disp(['Corrected start time is: ' datestr(startDatetime)])
    disp(['Corrected start time is: ' datestr(endDatetime)])
end

%% Locate the requested data
extractDt = [ASOS.Datetime]; %Bracket is required to form an array instead of a list
logicalDt = logical(extractDt==startDatetime | extractDt==endDatetime);
dtIndices = find(logicalDt~=0);

if isempty(nonzeros(logicalDt))
    noDataMsg = 'No data from input times present in structure!';
    error(noDataMsg)
end

surfaceSubset = ASOS(dtIndices(1):dtIndices(2)); %Extract the requested data from the structure

%% Plot Td, T, RH, P, wind data
dewpoint = [surfaceSubset.Dewpoint]; %Dewpoint data
temperature = [surfaceSubset.Temperature]; %Temperature data
humidity = [surfaceSubset.RelativeHumidity]; %Humidity
pressureInHg = [surfaceSubset.Altimeter]; %Pressure
pressure = pressureInHg.*33.8639; %Convert pressure from the default inches of mercury to the more useful hPa

serialTimes = datenum([surfaceSubset.Datetime]); %Make times into datenumbers
% While datetimes are generally better, the coordinate calculations in
% windbarb fail on datetimes and work with datenums.

minDegC = nanmin(dewpoint); %Minimum Td will be min for both T and Td, since Td is always less than T
maxDegC = nanmax(temperature); %Maximum T will be max for both T and Td, since T is always greater than Td
minHum = nanmin(humidity);
maxHum = 100.02; %Maximum humidity usually close to 100 in winter storms, so set to just above 100 to make figures consistent while not cutting off values at 100 when saving
minPre = nanmin(pressure);
maxPre = nanmax(pressure);
font = 'Lato Bold'; %Downloadable from Google Fonts
labelTxt = 16;
axTxt = 16;

figure;
%Line colors are from the Okabe-Ito palette
%Okabe, M., and K. Ito. 2008. Color Universal Design (CUD): How to Make
%Figures and Presentations That Are Friendly to Colorblind People.
%http://jfly.iam.u-tokyo.ac.jp/color/.
tempPlot = plot(serialTimes,temperature); %Plot temperature and dewpoint in deg C
tempPlot.Color = [86 180 233]./255; %sky blue
tempPlot.LineWidth = 2.3;
hold on
dewPlot = plot(serialTimes,dewpoint);
dewPlot.Color = [0 158 115]./255; %bluish green
dewPlot.LineWidth = 2.3;
ylim([minDegC-4 maxDegC+1]) %Set ylim according to max/min degree; the min limit is offset by -3 instead of -1 in order to make room for the wind barbs
celsiusLabelHand = ylabel([char(176) 'C']);
set(celsiusLabelHand,'FontName',font); set(celsiusLabelHand,'FontSize',labelTxt);
degCaxis = gca; %Grab axis in order to change color
set(degCaxis,'YColor',[0 112 115]./255); %Teal - note that this is the same axis for temperature (blue) and dewpoint (green)
set(degCaxis,'FontName',font); set(degCaxis,'FontSize',axTxt);
addaxis(serialTimes,pressure,[minPre-0.2 maxPre+0.2],'Color',[230 159 0]./255,'LineWidth',2.3); %Plot pressure in hPa
pressureLabelHand = addaxislabel(2,'hPa');
set(pressureLabelHand,'FontName',font); set(pressureLabelHand,'FontSize',labelTxt);
addaxis(serialTimes,humidity,[minHum-10 maxHum],'Color',[204 121 167]./255,'LineWidth',2.3); %Plot humidity in percent, leaving max at maxHum because it's 100
humidityLabelHand = addaxislabel(3,'%');
set(humidityLabelHand,'FontName',font); set(humidityLabelHand,'FontSize',labelTxt);
legendHand = legend('Dewpoint','Temperature','Pressure','Humidity','AutoUpdate','off'); %Disabling AutoUpdate prevents every windbarb line from receiving a legend entry
set(legendHand,'FontName',font); set(legendHand,'FontSize',14);
allAxes = findall(0,'type','axes');
set(allAxes(2),'FontName',font); set(allAxes(2),'FontSize',axTxt);
set(allAxes(3),'FontName',font); set(allAxes(3),'FontSize',axTxt);

% Plot wind data (on the same figure as above)
windSpd = [surfaceSubset.WindSpeed]; %Wind speed data
windDir = {surfaceSubset.WindDirection}; %Wind direction data
noWindDir = cellfun('isempty',windDir); %'isempty' is faster than @isempty
windDir(noWindDir) = {0}; %Insert 0 into all empty cells, otherwise conversion to double removes blank entries
windDir = cell2mat(windDir); %Convert to double

windCharSpd = [surfaceSubset.WindCharacterSpeed]; %Wind character speed data--currently wind character string (i.e. gust, squall) is not displayed
barbScale = 0.028; %Modifies the size of the wind barbs for both wind character and regular wind barbs

if length(serialTimes)>100 %When plotting over a long period of time, displaying all wind barbs is slow and complicates the figure
    spacer = -5; %This sets skip interval for the following loop when there are many entries
else
    spacer = -1; %When plotting over an interval of a few hours, display all winds
end
for windCount = length(serialTimes):spacer:1 %Loop backwards through winds
    timesPlotWind = serialTimes(windCount);
    windbarb(timesPlotWind,minDegC-2.5,windSpd(windCount),windDir(windCount),barbScale,0.09,'r',1); %#justiceforbarb
    if ~isnan(windCharSpd(windCount))==1 %If there is a wind character entry
        windbarb(timesPlotWind,minDegC-3.5,windCharSpd(windCount),windDir(windCount),barbScale,0.09,[179 77 77]./255,1); %Make barb for wind character as well
    end
    hold on %Otherwise only one barb will be plotted
end

tlabel('x','HH:MM','FixLow',10,'FixHigh',12) %x-axis is date axis; FixLow and FixHigh arguments control the number of ticks that are displayed
xlim([serialTimes(1)-0.02 serialTimes(end)+0.02]); %For the #aesthetic

titleString = pad(['Surface observations data for ' ASOS(1).StationID]);

toString = 'to';
spaceString = {' '}; %The curly brackets are necessary, do NOT remove
windString = 'Upper barbs denote winds; lower barbs denote wind character';
obsDate1 = datestr(serialTimes(1),'mm/dd/yy HH:MM');
obsDate2 = datestr(serialTimes(end),'mm/dd/yy HH:MM');
titleMsg = strcat(titleString,spaceString,datestr(obsDate1),spaceString,toString,spaceString,datestr(obsDate2)); %Builds title message "Surface observations data for mm/dd/yy"
titleAndSubtitle = {cell2mat(titleMsg),windString}; %Adds the above subtitle
surfaceTitleHand = title(titleAndSubtitle);
set(surfaceTitleHand,'FontName','Lato Bold'); set(surfaceTitleHand,'FontSize',16) %Lato downloadable from Google Fonts
xlabelHand = xlabel('Hour');
set(xlabelHand,'FontName','Lato Bold'); set(surfaceTitleHand,'FontSize',16) %Lato downloadable from Google Fonts
hold off

%% Plot weather codes
presentWeather = {surfaceSubset.PresentWeather}; %Weather codes
if isempty(nonzeros(~cellfun('isempty',presentWeather)))==1 %If no precipitation occurs
    emptyMsg = 'No precipitation during requested period! Skipped precipitation type plot.';
    disp(emptyMsg); %Display message at command window and continue function without making a precipitation plot
else
    %Weather codes supported in abacus plot: fog, freezing fog,
    %mist, rain, freezing drizzle, drizzle, freezing rain, sleet, graupel,
    %snow, unknown precipitation, hail, ice crystals, thunder
    %
    %NOTE ABOUT DATA QUALITY: ASOS sometimes misrepresents precipitation type.
    %Especially troublesome types are graupel (which is usually detected
    %as snow), partially melted particles (which is often detected as rain), and
    %slush (which is detected as rain). 
    
    %Initialize variables to check for precipitation type presence
    fogchk = 0; frzfogchk = 0; mistchk = 0; rainchk = 0; frzdrizchk = 0; drizchk = 0; frzrainchk = 0;
    sleetchk = 0; graupchk = 0; snowchk = 0; upchk = 0; hailchk = 0; icchk = 0; thunderchk = 0;
    yplacer = 0;
    figure;
    presentAxis = gca;
    markerSize = 20; %May need to be changed based on how long of a time period is requested
    
    for count = length(presentWeather):-1:1
        %Note that the backwards loop is (slightly) slower than a forward
        %loop would be, but is used to make MATLAB less worried about how
        %the adaptive labels are created.
        if isempty(regexp(presentWeather{count},'(FG){1}','once'))~=1
            if fogchk==0
                fogplace = yplacer+1; %Sets the wire where fog beads will be placed
                yplacer = yplacer+1; %Increments the label placer so each code gets its own wire
                presentLabels{yplacer} = 'Fog';
                fogchk=1; %Ensures the above only happens once, otherwise every entry will receive its own wire
            end
            plot(serialTimes(count),fogplace,'b','Marker','.','MarkerEdgeColor',[128 128 128]./255,'MarkerFaceColor',[128 128 128]./255,'MarkerSize',markerSize); %Gray
            hold on
        end
        if isempty(regexp(presentWeather{count},'(FZFG){1}','once'))~=1
            if frzfogchk==0
                frzfogplace = yplacer+1;
                yplacer = yplacer+1;
                presentLabels{yplacer} = 'Frz Fog';
                frzfogchk=1;
            end
            plot(serialTimes(count),frzfogplace,'b','Marker','.','MarkerEdgeColor',[128 128 128]./255,'MarkerFaceColor',[128 128 128]./255,'MarkerSize',markerSize);
            hold on
        end
        if isempty(regexp(presentWeather{count},'(BR){1}','once'))~=1
            if mistchk==0
                mistplace = yplacer+1;
                yplacer = yplacer+1;
                presentLabels{yplacer} = 'Mist';
                mistchk=1;
            end
            plot(serialTimes(count),mistplace,'b','Marker','.','MarkerEdgeColor',[128 128 128]./255,'MarkerFaceColor',[128 128 128]./255,'MarkerSize',markerSize);
            hold on
        end
        if isempty(regexp(presentWeather{count},'(DZ){1}','once'))~=1 && isempty(regexp(presentWeather{count},'(FZDZ){1}','once'))==1
            if drizchk==0
                dzplace = yplacer+1;
                yplacer = yplacer+1;
                presentLabels{yplacer} = 'Drizzle';
                drizchk=1;
            end
            plot(serialTimes(count),dzplace,'k','Marker','.','MarkerSize',markerSize); %Black
            hold on
        end
        if isempty(regexp(presentWeather{count},'(FZDZ){1}','once'))~=1
            if frzdrizchk==0
                fzdzplace = yplacer+1;
                yplacer = yplacer+1;
                presentLabels{yplacer} = 'Frz Drizzle';
                frzdrizchk=1;
            end
            plot(serialTimes(count),fzdzplace,'k','Marker','.','MarkerSize',markerSize+5);
            hold on
        end
        if isempty(regexp(presentWeather{count},'(RA){1}','once'))~=1 && isempty(regexp(presentWeather{count},'(FZRA){1}','once'))==1
            if rainchk==0
                rainplace = yplacer+1;
                yplacer = yplacer+1;
                presentLabels{yplacer} = 'Rain';
                rainchk=1;
            end
            plot(serialTimes(count),rainplace,'Marker','.','MarkerFaceColor','b','MarkerEdgeColor','b','MarkerSize',markerSize); %Blue
            hold on
        end
        if isempty(regexp(presentWeather{count},'(FZRA){1}','once'))~=1
            if frzrainchk==0
                fzraplace = yplacer+1;
                yplacer = yplacer+1;
                presentLabels{yplacer} = 'Frz Rain';
                frzrainchk=1;
            end
            plot(serialTimes(count),fzraplace,'Marker','.','MarkerFaceColor','b','MarkerEdgeColor','b','MarkerSize',markerSize+5);
            hold on
        end
        if isempty(regexp(presentWeather{count},'(PL){1}','once'))~=1 || isempty(regexp(presentWeather{count},'(PE){1}','once'))~=1
            if sleetchk==0
                sleetplace = yplacer+1;
                yplacer = yplacer+1;
                presentLabels{yplacer} = 'Sleet';
                sleetchk=1;
            end
            plot(serialTimes(count),sleetplace,'o','MarkerEdgeColor',[128 128 128]./255,'MarkerFaceColor',[128 128 128]./255,'MarkerSize',markerSize-6); %Gray
            hold on
        end
        if isempty(regexp(presentWeather{count},'(SG){1}','once'))~=1 || isempty(regexp(presentWeather{count},'(GS){1}','once'))~=1
            if graupchk==0
                graupplace = yplacer+1;
                yplacer = yplacer+1;
                presentLabels{yplacer} = 'Graupel';
                graupchk=1;
            end
            plot(serialTimes(count),graupplace,'Marker','*','MarkerEdgeColor','g','MarkerFaceColor','g','MarkerSize',markerSize-6); %Green
            hold on
        end
        if isempty(regexp(presentWeather{count},'(SN){1}','once'))~=1
            if snowchk==0
                snowplace = yplacer+1;
                yplacer = yplacer+1;
                presentLabels{yplacer} = 'Snow';
                snowchk=1;
            end
            plot(serialTimes(count),snowplace,'Marker','*','MarkerEdgeColor',[51,153,255]./255,'MarkerFaceColor',[51,153,255]./255,'MarkerSize',markerSize-6); %Light blue
            hold on
        end
        if isempty(regexp(presentWeather{count},'(IC){1}','once'))~=1
            if icchk==0
                icplace = yplacer+1;
                yplacer = yplacer+1;
                presentLabels{yplacer} = 'Ice Crystals';
                icchk=1;
            end
            plot(serialTimes(count),icplace,'Marker','-','MarkerEdgeColor',[128 128 128]./255,'MarkerFaceColor',[128 128 128]./255,'MarkerSize',markerSize); %Gray
            hold on
        end
        if isempty(regexp(presentWeather{count},'(GR){1}','once'))~=1
            if hailchk==0
                hailplace = yplacer+1;
                yplacer = yplacer+1;
                presentLabels{yplacer} = 'Hail';
                hailchk=1;
            end
            plot(serialTimes(count),hailplace,'Marker','o','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',markerSize); %Red
            hold on
        end
        if isempty(regexp(presentWeather{count},'(TS){1}','once'))~=1
            if thunderchk==0
                thunderplace = yplacer+1;
                yplacer = yplacer+1;
                presentLabels{yplacer} = 'Thunderstorm';
                thunderchk=1;
            end
            plot(serialTimes(count),thunderplace,'Marker','d','MarkerEdgeColor','y','MarkerFaceColor','y','MarkerSize',markerSize); %Yellow
            hold on
        end
        if isempty(regexp(presentWeather{count},'(UP){1}','once'))~=1
            if upchk==0
                upplace = yplacer+1;
                yplacer = yplacer+1;
                presentLabels{yplacer} = 'Uknwn Precip';
                upchk=1;
            end
            plot(serialTimes(count),upplace,'Marker','p','MarkerEdgeColor','m','MarkerFaceColor','m','MarkerSize',markerSize); %Magenta
            hold on
        end
        if isempty(presentWeather{count})==1 %If there is no weather code for a time
            plot(serialTimes(count),1,'Marker','.','MarkerEdgeColor','w','MarkerFaceColor','w'); %Plot invisible marker, otherwise the apparent end time will be the time of last precipitation code instead of the true last end time
        end
        hold on
    end
    
    %plot([datenum(2015,2,9,12,00,00) datenum(2015,2,9,12,00,00)],[0 20],'Color','r','LineWidth',2) %Annotate a particular time of interest (such as a balloon launch) with a vertical red line on the abacus plot
    ylim([0 yplacer+1]); %For easier comprehension, y limits are set +/- 1 larger than number of wires
    set(presentAxis,'YTick',1:yplacer); %Only make as many wires as there were precipitation types
    try
        set(presentAxis,'YTickLabel',presentLabels); %Label the wires
    catch
        disp('No precipitation weather codes reported!')
        % Non-precip weather codes include SQ (squall)
        close
        return
    end
    set(presentAxis,'FontName','Lato Bold'); set(presentAxis,'FontSize',20) %Lato downloadable from Google Fonts
    xlabel('Time (hour)')
  
    % Make adaptive title including start and end times
    weatherCodeTitleString = ['Precip type data for ' ASOS(1).StationID];
    obsDate1 = datestr(serialTimes(1),'mm/dd/yy HH:MM');
    obsDate2 = datestr(serialTimes(end),'mm/dd/yy HH:MM');
    titleMsg = strcat(weatherCodeTitleString,spaceString,datestr(obsDate1),spaceString,toString,spaceString,datestr(obsDate2)); %Builds title message "Precip type data for mm/dd/yy HH:MM to mm/dd/yy HH:MM"
    precipTitleHand = title(titleMsg);
    set(precipTitleHand,'FontSize',20); set(precipTitleHand,'FontName','Lato Bold') %Lato downloadable from Google Fonts
    tlabel('x','HH:MM','FixLow',10,'FixHigh',12) %Set axis to be the same as surface conditions plot
    xlim([serialTimes(1)-0.02 serialTimes(end)+0.02]); %Set bounds to be the same as surface conditions plot
    xlabelHand = xlabel('Hour');
    set(xlabelHand,'FontName','Lato Bold'); set(xlabelHand,'FontSize',18)
    hold off
    
end

%% Finalizing
disp('Completed!') %Yay!

end