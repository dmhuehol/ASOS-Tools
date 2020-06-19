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
%   Version date: 6/19/2020
%   Last major revision: 6/19/2020
%


function [storms] = stormFinder(ASOS)

presentWeather = {ASOS.PresentWeather};

% Remove solo BLSN codes, which can throw off storm start/end time
blowSnowCode = "BLSN";
[codeLength] = cellfun('length',presentWeather);
codeLength5 = codeLength == 5; %Length 5=>"BLSN " only
blowSnow = and(contains(presentWeather,blowSnowCode),codeLength5); % Learned this trick from Megan Amanatides's original balloon import code
[~,blowSnowInd,~] = find(blowSnow);
presentWeatherNoBLSN = presentWeather;
presentWeatherNoBLSN(blowSnowInd) = {' '};

% Locate data during precipitation
precipCode = ["SN","BLSN","PL","DZ","FZDZ","RA","FZRA","SG","GS"]; % all possible weather codes corresponding to precipitation ordered usefully
precip = contains(presentWeatherNoBLSN,precipCode);
% Where weather is 1, there is one or more precip code
% Where weather is 0, precip is not occurring
[~,precipInd,~] = find(precip); %Find indices where precip occurs
precipInd = precipInd';

% Find storm gap indices
% 2-hour gap in weather codes denotes 2-hour break in precipitation
findGaps = diff(precipInd); %Look for gaps in the indices
gapLog = findGaps>24; %24 indices * 5 minutes per index = 120 minutes
[gapInd,~,~] = find(gapLog); %Find indices where gaps occur
if findGaps(end)==1
    fixLastGap = length(precipInd);
    gapInd = vertcat(gapInd,fixLastGap);
end

% Extract relevant data
weatherData = ASOS(precip); %ASOS data where precip occurred
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
% (Datetimes are more flexible for coding but datestrings are easier to
% assess visually from the workspace.)
for qq = 1:fc-1
     filterStorms(qq).startTime = datestr(filterStorms(qq).startTime);
     filterStorms(qq).endTime = datestr(filterStorms(qq).endTime);
     filterStorms(qq).peakHourStart = datestr(filterStorms(qq).peakHourStart);
end

% Make final output structure
storms.all = allStorms;
storms.filtered = filterStorms;

end