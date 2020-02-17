%%surfacePlotter
    %Visualizes ASOS 5-minute data on two figures. One is a surface conditions
    %plot which plots temperature, dewpoint, pressure, and relative
    %humidity data on a standard xy plot and shows wind data using wind
    %barbs, and the other is an abacus plot which visualizes
    %precipitation type. Additionally, returns the subset of the input
    %ASOS structure corresponding to the requested times.
    %
    %General form: [surfaceSubset] = surfacePlotter(dStart,hStart,dEnd,hEnd,ASOS)
    %
    %Output:
    %surfaceSubset: a subset of ASOS data corresponding to the input times.
    %
    %Inputs:
    %dStart: 1 or 2 digit starting day
    %hStart: 1 or 2 digit starting hour
    %dEnd: 1 or 2 digit ending day
    %hEnd: 1 or 2 digit ending hour
    %ASOS: structure of ASOS data
    %
    %Figures:
    %surface conditions: three-axis plot against time displaying humidity,
    %surface pressure, and temperature/dewpoint, with wind and wind
    %character velocity displayed as barbs
    %precipitation: abacus plot against time plotting weather codes as
    %wires, with beads representing the current precipitation type(s)
    %
    %Requires external functions tlabel, addaxis, and windbarb
    %   Be sure to add the addaxis6 folder to the path before running
    %   surfacePlotter.
    %
    %Future development: display precipitation intensity on abacus plot,
        %display wind character
    %
    %Written by: Daniel Hueholt
    %North Carolina State University
    %Undergraduate Research Assistant at Environment Analytics
    %Version date: 7/6/2018
    %Last major revision: 11/13/2017
    %
    %tlabel written by Carlos Adrian Vargas Aguilera, last updated 9/2009,
        %found on the MATLAB File Exchange
    %addaxis written by Harry Lee, last updated 7/7/2016, found on the
        %MATLAB File Exchange
    %windbarb written by Laura Tomkins, last updated 5/2017, found on
        %Github at user profile @lauratomkins
    %
    %
    %See also abacusdemo, tlabel, addaxis, addaxislabel, ASOSimportFiveMin,
    %windbarb
    %
    
function [surfaceSubset] = surfacePlotter(dStart,hStart,dEnd,hEnd,ASOS)
%% Locate the requested data
extractDays = [ASOS.Day]; %Array of all days within the given structure, bracket is required to form an array instead of list
logicalDays = logical(extractDays==dStart | extractDays==dEnd); %Logically index the days; 1 represents start/end day entries, 0 represents all others
if dStart==1
    logicalDays(end-120:end) = 0; %Zero out any indices that could possibly be associated with the first day of the next month
end
dayIndices = find(logicalDays~=0); %These are the indices of the input day(s)
if isempty(dayIndices)==1 %If day is not found
    dayMsg = 'No data from input day(s) present in structure!';
    error(dayMsg); %Give a useful error message
end

extractHours = [ASOS(dayIndices).Hour]; %Array of all hours from the given days
logicalHours = logical(extractHours==hStart); %Since it's possible for end to be a number smaller than start and hence deceive the function, start by finding only the start hour
hStartIndices = find(logicalHours~=0); %These are the indices of the input starting hour
if isempty(hStartIndices)==1 %If start hour is not found
    startHourMsg = 'Failed to find start hour in structure!';
    error(startHourMsg); %Give a useful error message
end

hStartFirstInd = hStartIndices(1); %This is the first index
logicalHours = logical(extractHours==hEnd); %Remake the logical matrix, this time logically indexing on the input ending hour (INCLUDES data from the hEnd hour)
if hStart==hEnd %For cases where the end hour and start hour are the same number
    indStartAndEnd = find(diff(logicalHours)~=0); %Locate the bounds of indices corresponding to starting and ending hours
    logicalHours(indStartAndEnd(1):indStartAndEnd(2)) = 0; %Zero all the indices that corresponded to the start hour
end
hEndIndices = find(logicalHours~=0); %These are the indices of the ending hour
if isempty(hEndIndices)==1 %Check to see whether the ending indices were found
    msg = 'Could not find end hour in structure!'; %If not
    error(msg); %give a useful error message
end
hEndFinalInd = hEndIndices(end); %This is the last data index

dataHourSpan = [hStartFirstInd hEndFinalInd]; %This is the span of indices corresponding to hour locations within the found days
dataSpan = [dayIndices(dataHourSpan(1)) dayIndices(dataHourSpan(2))]; %This is the span of indices corresponding to data positions in the actual structure

surfaceSubset = ASOS(dataSpan(1):dataSpan(2)); %Extract the requested data from the structure

%% Plot Td, T, RH, P, wind data
dewpoint = [surfaceSubset.Dewpoint]; %Dewpoint data
temperature = [surfaceSubset.Temperature]; %Temperature data
humidity = [surfaceSubset.RelativeHumidity]; %Humidity
pressureInHg = [surfaceSubset.Altimeter]; %Pressure
pressure = pressureInHg.*33.8639; %Convert pressure from the default inches of mercury to the more useful hPa

TdT = [dewpoint;temperature]; %Concatenate dewpoint and temperature for plotting on same axis
times = [surfaceSubset.Year; surfaceSubset.Month; surfaceSubset.Day; surfaceSubset.Hour; surfaceSubset.Minute; zeros(1,length(surfaceSubset))]; %YMDHM are real from data, S are generated at 0
serialTimes = datenum(times(1,:),times(2,:),times(3,:),times(4,:),times(5,:),times(6,:)); %Make times into datenumbers
%Note: use actual datetimes once we update to 2016+

minDegC = nanmin(dewpoint); %Minimum Td will be min for both T and Td, since Td is always less than T
maxDegC = nanmax(temperature); %Maximum T will be max for both T and Td, since T is always greater than Td
minHum = nanmin(humidity);
maxHum = 100.02; %Maximum humidity will always be at least close to 100, so set to just above 100 to make figures consistent while not cutting off 100 values when saving
minPre = nanmin(pressure);
maxPre = nanmax(pressure);
font = 'Lato Bold';
labelTxt = 16;
axTxt = 16;

figure; %Make new figure
tempAndDew = plot(serialTimes,TdT); %Plot temperature and dewpoint in deg C
set(tempAndDew,'LineWidth',2.3)
ylim([minDegC-4 maxDegC+1]) %Set ylim according to max/min degree; the min limit is offset by -3 instead of -1 in order to make room for the wind barbs
celsiusLabelHand = ylabel([char(176) 'C']);
set(celsiusLabelHand,'FontName',font); set(celsiusLabelHand,'FontSize',labelTxt);
degCaxis = gca; %Grab axis in order to change color
set(degCaxis,'YColor',[0 112 115]./255); %Teal - note that this is the same axis for temperature (blue) and dewpoint (green)
set(degCaxis,'FontName',font); set(degCaxis,'FontSize',axTxt);
addaxis(serialTimes,pressure,[minPre-0.2 maxPre+0.2],'Color',[255 170 0]./255,'LineWidth',2.3); %Plot pressure in hPa
pressureLabelHand = addaxislabel(2,'hPa');
set(pressureLabelHand,'FontName',font); set(pressureLabelHand,'FontSize',labelTxt);
addaxis(serialTimes,humidity,[minHum-10 maxHum],'m','LineWidth',2.3); %Plot humidity in %, leaving max at maxHum because it's 100
humidityLabelHand = addaxislabel(3,'%');
set(humidityLabelHand,'FontName',font); set(humidityLabelHand,'FontSize',labelTxt);
legendHand = legend('Dewpoint','Temperature','Pressure','Humidity','AutoUpdate','off');
set(legendHand,'FontName',font); set(legendHand,'FontSize',14);
allAxes = findall(0,'type','axes'); %Find all axes
set(allAxes(2),'FontName',font); set(allAxes(2),'FontSize',axTxt);
set(allAxes(3),'FontName',font); set(allAxes(3),'FontSize',axTxt);

%%Plot wind data
%Note this is on the same plot as above data
windSpd = [surfaceSubset.WindSpeed]; %Wind speed data
windDir = [surfaceSubset.WindDirection]; %Wind direction data
windCharSpd = [surfaceSubset.WindCharacterSpeed]; %Wind character speed data - currently wind character is not displayed,
    %which is sort of acceptable in the short term because essentially all wind characters at Upton are gusts
barbScale = 0.028; %Modifies the size of the wind barbs for both wind character and regular wind barbs

if length(serialTimes)>100 %When plotting over a long period of time, displaying all wind barbs takes very long and makes the figure confusing
    spacer = -5; %This sets the skip interval for the following loop when there are many entries
else
    spacer = -1; %When plotting over an interval of a few hours, display all winds
end
for windCount = length(serialTimes):spacer:1 %Loop backwards through winds
    windbarb(serialTimes(windCount),minDegC-2.5,windSpd(windCount),windDir(windCount),barbScale,0.09,'r',1); %#justiceforbarb
    if isnan(windCharSpd(windCount))~=1 %If there is a wind character entry
        windbarb(serialTimes(windCount),minDegC-3.5,windCharSpd(windCount),windDir(windCount),barbScale,0.09,[179 77 77]./255,1); %Make wind barb for the character as well
    end
    hold on %Otherwise only one barb will be plotted
end

tlabel('x','HH:MM','FixLow',10,'FixHigh',12) %x-axis is date axis; FixLow and FixHigh arguments control the number of ticks that are displayed
xlim([serialTimes(1)-0.02 serialTimes(end)+0.02]); %For the #aesthetic

titleString = 'Surface observations data for ';
toString = 'to';
spaceString = {' '}; %Yes those curly brackets are needed
windString = 'Upper barbs denote winds; lower barbs denote wind character';
if dStart==dEnd
    obsDate = datestr(serialTimes(1),'mm/dd/yy');
    titleMsg = [titleString datestr(obsDate)]; %Builds title message "Surface observations data for mm/dd/yy"
    titleAndSubtitle = {titleMsg,windString};
else
    obsDate1 = datestr(serialTimes(1),'mm/dd/yy HH:MM');
    obsDate2 = datestr(serialTimes(end),'mm/dd/yy HH:MM');
    titleMsg = strcat(titleString,spaceString,datestr(obsDate1),spaceString,toString,spaceString,datestr(obsDate2)); %Builds title message "Surface observations data for mm/dd/yy"
    titleAndSubtitle = {cell2mat(titleMsg),windString}; %Adds the above subtitle
    %I agree that the above syntax is unwieldy but oh well
end
surfaceTitleHand = title(titleAndSubtitle);
set(surfaceTitleHand,'FontName','Lato Bold'); set(surfaceTitleHand,'FontSize',16)
xlabelHand = xlabel('Hour');
set(xlabelHand,'FontName','Lato Bold'); set(surfaceTitleHand,'FontSize',16)
hold off

%% Plot weather codes
presentWeather = {surfaceSubset.PresentWeather}; %Weather codes
if isempty(nonzeros(~cellfun('isempty',presentWeather)))==1 %If no precipitation occurs
    emptyMsg = 'No precipitation during requested period! Skipped precipitation type plot.';
    disp(emptyMsg); %Display message at command window and continue function without making a precipitation plot
else
    %Weather codes covered in the abacus plot: fog, freezing fog,
    %mist, rain, freezing drizzle, drizzle, freezing rain, sleet, graupel,
    %snow, unknown precipitation, hail, ice crystals, thunder
    %
    %KNOWN PROBLEM: ASOS sometimes misrepresents precipitation type.
    %Especially troublesome types are graupel (which is usually displayed
    %as snow), partially melted particles (which displays as rain), and
    %slush (which displays as rain). Someday the codes might be able to be 
    %cross-checked against other environmental variables or a database of 
    %flake pictures but currently the user must simply remain aware of this
    %issue.
    %NOTE: it may seem that partially melted particles and slush are
    %misidentified as freezing rain, but ASOS is likely more or less correct here, as
    %these particles behave as freezing rain (freezing on contact with the
    %surface). Technically, they aren't rain per se (rather freezing slush
    %or freezing partially melted particles) but these precipitation
    %categories do not exist.
    
    %Initialize variables to check for precipitation type presence
    fogchk = 0; frzfogchk = 0; mistchk = 0; rainchk = 0; frzdrizchk = 0; drizchk = 0; frzrainchk = 0;
    sleetchk = 0; graupchk = 0; snowchk = 0; upchk = 0; hailchk = 0; icchk = 0; thunderchk = 0;
    yplacer = 0;
    figure;
    presentAxis = gca;
    markerSize = 20; %This needs to be changed based on how long of a time period is requested
    for count = length(presentWeather):-1:1 %Sometimes you just have to get loopy
        %Note that the backwards loop is very slightly slower than a forward
        %loop would be, but is used to make MATLAB less worried about how
        %the adaptive labels are created.
        if isempty(regexp(presentWeather{count},'(FG){1}','once'))~=1
            if fogchk==0
                fogplace = yplacer+1; %Sets the wire where fog beads will be placed
                yplacer = yplacer+1; %Increments the label placer so each code gets its own wire
                presentLabels{yplacer} = 'Fog';
                fogchk=1; %Make sure that the above only happens once, otherwise each new fog entry will receive its own label and wire
            end
            plot(serialTimes(count),fogplace,'b','Marker','.','MarkerEdgeColor',[128 128 128]./255,'MarkerSize',markerSize); %Gray
            hold on
        end
        if isempty(regexp(presentWeather{count},'(FZFG){1}','once'))~=1
            if frzfogchk==0
                frzfogplace = yplacer+1;
                yplacer = yplacer+1;
                presentLabels{yplacer} = 'Frz Fog';
                frzfogchk=1;
            end
            plot(serialTimes(count),frzfogplace,'b','Marker','.','MarkerEdgeColor',[128 128 128]./255,'MarkerSize',markerSize);
            hold on
        end
        if isempty(regexp(presentWeather{count},'(BR){1}','once'))~=1
            if mistchk==0
                mistplace = yplacer+1;
                yplacer = yplacer+1;
                presentLabels{yplacer} = 'Mist';
                mistchk=1;
            end
            plot(serialTimes(count),mistplace,'b','Marker','.','MarkerEdgeColor',[128 128 128]./255,'MarkerSize',markerSize);
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
            plot(serialTimes(count),rainplace,'Marker','.','MarkerFaceColor','b','MarkerSize',markerSize); %Blue
            hold on
        end
        if isempty(regexp(presentWeather{count},'(FZRA){1}','once'))~=1
            if frzrainchk==0
                fzraplace = yplacer+1;
                yplacer = yplacer+1;
                presentLabels{yplacer} = 'Frz Rain';
                frzrainchk=1;
            end
            plot(serialTimes(count),fzraplace,'Marker','.','MarkerFaceColor','b','MarkerSize',markerSize+5);
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
            plot(serialTimes(count),graupplace,'Marker','*','MarkerEdgeColor','g','MarkerSize',markerSize-6); %Green
            hold on
        end
        if isempty(regexp(presentWeather{count},'(SN){1}','once'))~=1
            if snowchk==0
                snowplace = yplacer+1;
                yplacer = yplacer+1;
                presentLabels{yplacer} = 'Snow';
                snowchk=1;
            end
            plot(serialTimes(count),snowplace,'Marker','*','MarkerEdgeColor',[51,153,255]./255,'MarkerSize',markerSize-6); %Light deep blue
            hold on
        end
        if isempty(regexp(presentWeather{count},'(IC){1}','once'))~=1
            if icchk==0
                icplace = yplacer+1;
                yplacer = yplacer+1;
                presentLabels{yplacer} = 'Ice Crystals';
                icchk=1;
            end
            plot(serialTimes(count),icplace,'Marker','-','MarkerEdgeColor',[128 128 128]./255,'MarkerSize',markerSize); %Gray
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
 %   plot([datenum(2015,2,9,12,00,00) datenum(2015,2,9,12,00,00)],[0 4],'Color','r','LineWidth',2) %Use this line to annotate a particular time with a vertical red line (such as a sounding time)
    ylim([0 yplacer+1]); %For easier comprehension, y limits are set +/- 1 larger than number of wires
    set(presentAxis,'YTick',1:yplacer); %Only make as many wires as there were precipitation types
    set(presentAxis,'YTickLabel',presentLabels); %Label the wires
    set(presentAxis,'FontName','Lato Bold'); set(presentAxis,'FontSize',20)
    xlabel('Time (hour)')
  
    %Make adaptive title including start and end times
    weatherCodeTitleString = 'Precip type data for ';
    if dStart==dEnd
        obsDate = datestr(serialTimes(1),'mm/dd/yy');
        titleMsg = [weatherCodeTitleString datestr(obsDate)]; %Builds title message "Precip type data for mm/dd/yy"
    else
        obsDate1 = datestr(serialTimes(1),'mm/dd/yy HH:MM');
        obsDate2 = datestr(serialTimes(end),'mm/dd/yy HH:MM');
        titleMsg = strcat(weatherCodeTitleString,spaceString,datestr(obsDate1),spaceString,toString,spaceString,datestr(obsDate2)); %Builds title message "Precip type data for mm/dd/yy HH:MM to mm/dd/yy HH:MM"
    end
    precipTitleHand = title(titleMsg);
    set(precipTitleHand,'FontSize',20); set(precipTitleHand,'FontName','Lato Bold')
    tlabel('x','HH:MM','FixLow',10,'FixHigh',12) %Set axis to be the same as surface conditions plot
    xlim([serialTimes(1)-0.02 serialTimes(end)+0.02]); %Set bounds to be the same as surface conditions plot
    xlabelHand = xlabel('Hour');
    set(xlabelHand,'FontName','Lato Bold'); set(xlabelHand,'FontSize',18)
    hold off
end

%% Finalizing
disp('Completed!') %Yay!

end