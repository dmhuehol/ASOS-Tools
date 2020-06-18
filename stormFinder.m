%%stormFinder
%   Given an structure of ASOS data, return start time, end time, hour of
%   peak intensity, and data for all storms in the season. Individual
%   storms determined by 2-hour gaps.
%
%   ASOS 5-minute data does not record snow liquid water, and snow liquid
%   water is usually unreliable on this timescale anyway. We approximate
%   peak intensity from the weather codes. All weather code entries are
%   assigned a numerical intensity score (iScore): '+' = 3, none = 2, '-' =
%   1. For storms of sufficient length, the event is scored by hour. The
%   hours are then summed individually, and the hour with the highest
%   iScore is considered the hour of peak intensity.
%
%   General form: [storms] = stormFinder(ASOS)
%
%   Input:
%   ASOS: ASOS data structure, see ASOSimportFiveMin or ASOSimportManyFiveMin.
%
%   Output:
%   storms: structure containing the storm information. The 'all'
%   substructure contains every storm with precipitation codes from the
%   input structure. The 'filtered' substructure requires that events have
%   a total iScore above 15. This is an attempt to omit minimal-impact
%   trace events.
%
%   Written by: Daniel Hueholt
%   North Carolina State University
%   Research Assistant at Environment Analytics
%   Version Date: 6/16/2020
%   Last Major Revision: 6/16/2020
%


function [storms] = stormFinder(ASOS)

% Locate data during precipitation
presentWeather = {ASOS.PresentWeather};
precipCode = ["SN","BLSN","PL","DZ","FZDZ","RA","FZRA","SG","GS"]; % all possible weather codes corresponding to precipitation ordered usefully
weather = contains(presentWeather,precipCode);
% Where weather is 1, there is one or more precip code
% Where weather is 0, precip is not occurring
[~,weatherInd,~] = find(weather); %Find indices where precip occurs
weatherInd = weatherInd';

% Find storm gap indices
% 2-hour gap in weather codes denotes 2-hour break in precipitation
findGaps = diff(weatherInd); %Look for gaps in the indices
gapLog = findGaps>24; %24 indices * 5 minutes per index = 120 minutes
[gapInd,~,~] = find(gapLog); %Find indices where gaps occur
if findGaps(end)==1
    fixLastGap = length(weatherInd);
    gapInd = vertcat(gapInd,fixLastGap);
end

% Extract relevant data
weatherData = ASOS(weather); %ASOS data where precip occurred
codesOnly = {weatherData.PresentWeather}; %Weather codes where precip occurred
% These need to be split by the gaps in gapInd

% Set up intensity score
heavy = contains(codesOnly,'+'); %+ => 3
light = contains(codesOnly,'-');%- => 1
[~,heavyInd,~] = find(heavy);
[~,lightInd,~] = find(light);
iScore = ones(length(codesOnly),1)*2; %Regular weather codes => 2
iScore(heavyInd) = 3;
iScore(lightInd) = 1;

fc = 1;
allStorms = struct([]);
filterStorms = struct([]);
for wq = 1:length(gapInd)-1
    allStorms(wq).data = weatherData(gapInd(wq)+1:gapInd(wq+1)-1);
    if ~isempty(allStorms(wq).data)
        allStorms(wq).startTime = allStorms(wq).data(1).Datetime;
        allStorms(wq).endTime = allStorms(wq).data(end).Datetime;
        allStorms(wq).iScoreArr = iScore(gapInd(wq)+1:gapInd(wq+1)-1);
        iScoreScalar = sum(allStorms(wq).iScoreArr);
        allStorms(wq).iScore = iScoreScalar;
    else
        continue
    end
    
    if iScoreScalar > 15
        filterStorms(fc).data = allStorms(wq).data;
        filterStorms(fc).startTime = allStorms(wq).startTime;
        filterStorms(fc).endTime = allStorms(wq).endTime;
        filterStorms(fc).iScoreArr = allStorms(wq).iScoreArr;
        filterStorms(fc).iScore = iScoreScalar;
        
        stormDuration = filterStorms(fc).endTime-filterStorms(fc).startTime;
        if stormDuration>hours(1)
            activeDt = [allStorms(wq).data.Datetime]';
            activeiScore = [allStorms(wq).iScoreArr];
            activeHour = activeDt.Hour;
            allHours = unique(activeHour);
            for hq = 1:length(allHours)
                indHour = activeHour==allHours(hq);
                hour(hq).datetime = activeDt(indHour);
                hour(hq).iScoreArr = activeiScore(indHour);
                hour(hq).iScore = sum(hour(hq).iScoreArr);
            end
            [~,maxInd] = max([hour.iScore]);
            peakIntensity.Hour = hour(maxInd).datetime(1).Hour;
            peakIntensity.datetime = hour(maxInd).datetime;
            peakIntensity.iScoreArr = hour(maxInd).iScoreArr;
            peakIntensity.iScore = sum(peakIntensity.iScoreArr);
            filterStorms(fc).peak = peakIntensity;
            filterStorms(fc).peakHourStart = peakIntensity.datetime(1);
        else
            filterStorms(fc).peak = [];
            filterStorms(fc).peakHourStart = [];
        end
        clear activeDt; clear activeiScore; clear activeHour;
        clear allHours; clear hour; clear indHour; clear peakIntensity;
        fc = fc+1;
        
    end
    
end

% Uncomment for datestrings instead of datetimes
% for qq = 1:fc-1
%     filterStorms(qq).startTime = datestr(filterStorms(qq).startTime);
%     filterStorms(qq).endTime = datestr(filterStorms(qq).endTime);
%     filterStorms(qq).peakHourStart = datestr(filterStorms(qq).peakHourStart);
% end

% Make final output structure
storms.all = allStorms;
storms.filtered = filterStorms;

end