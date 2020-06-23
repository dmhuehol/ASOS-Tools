%%stormFinder
%   Given an structure of ASOS data, return start time, end time, hour of
%   peak intensity, and data for all storms in the season. Individual
%   storms determined by 2-hour gaps.
%
%   ASOS 5-minute data does not record snow liquid water, and snow liquid
%   water is usually unreliable on this timescale anyway. We approximate
%   peak intensity from the weather codes. All weather code entries are
%   assigned a numerical intensity score: '+' = 3, none = 2, '-' = 1
%   For storms of sufficient length, the event is scored by hour. The hours
%   are then summed individually, and the hour with the highest intensity
%   score is considered the hour of peak intensity.
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
%   a total intensity score above 15. This is an attempt to omit trace
%   events.
%
%   Written by: Daniel Hueholt
%   North Carolina State University
%   Research Assistant at Environment Analytics
%   Version date: 6/23/2020
%   Last major revision: 6/23/2020
%


function [storms] = stormFinder(ASOS)

presentWeather = {ASOS.PresentWeather}; %Extract weather codes

% Remove solo BLSN codes, which can throw off storm start/end time
blowSnowCode = "BLSN";
[codeLength] = cellfun('length',presentWeather);
codeLength5 = codeLength == 5; %Length 5=>"BLSN " only
blowSnow = and(contains(presentWeather,blowSnowCode),codeLength5); %Logically index on both conditions being true (hat-tip to Megan Amanatides for this trick)
[~,blowSnowInd,~] = find(blowSnow);
presentWeatherNoBLSN = presentWeather;
presentWeatherNoBLSN(blowSnowInd) = {' '};

% Locate data during precipitation
precipCode = ["SN","BLSN","PL","DZ","FZDZ","RA","FZRA","SG","GS"]; %All weather codes corresponding to precipitation
precip = contains(presentWeatherNoBLSN,precipCode);
[~,precipInd,~] = find(precip); %Where precip is 1, there is one or more precip code
precipInd = precipInd'; %For ease of interpretation

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
% These will need to be split at the indices found in gapInd

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
    
    % Each storm needs its ASOS data, start time, end time, intensity score
    % array, and intensity score scalar.
    allStorms(wq).data = weatherData(gapInd(wq)+1:gapInd(wq+1)-1); %Extract the data for a storm, as identified by the gap indices
    if ~isempty(allStorms(wq).data)
        allStorms(wq).startTime = allStorms(wq).data(1).Datetime;
        allStorms(wq).endTime = allStorms(wq).data(end).Datetime;
        allStorms(wq).iScoreArr = iScore(gapInd(wq)+1:gapInd(wq+1)-1);
        iScoreScalar = sum(allStorms(wq).iScoreArr);
        allStorms(wq).iScore = iScoreScalar;
    else %Skip events with no data
        continue
    end
    
    % Filter the storms based on intensity score
    if iScoreScalar > 15
        filterStorms(fc).data = allStorms(wq).data;
        filterStorms(fc).startTime = allStorms(wq).startTime;
        filterStorms(fc).endTime = allStorms(wq).endTime;
        filterStorms(fc).iScoreArr = allStorms(wq).iScoreArr;
        filterStorms(fc).iScore = iScoreScalar;
        
        % Find hour of peak intensity (if duration greater than 1 hour)
        stormDuration = filterStorms(fc).endTime-filterStorms(fc).startTime; %Easy duration comparison is a big advantage of datetimes rather than storing times numerically
        if stormDuration>hours(1)
            
            activeDt = [allStorms(wq).data.Datetime]';
            activeiScore = [allStorms(wq).iScoreArr];
            activeHour = activeDt.Hour;
            allHours = unique(activeHour); %Identify the hours in the given storm
            
            hour = struct([]);
            for hq = 1:length(allHours)
                indHour = activeHour==allHours(hq); %Logically index on the hour
                hour(hq).datetime = activeDt(indHour);
                hour(hq).iScoreArr = activeiScore(indHour);
                hour(hq).iScore = sum(hour(hq).iScoreArr); %Generate intensity score scalar for each hour
            end     
            
            [~,maxInd] = max([hour.iScore]); %Find hour of peak intensity
            peakIntensity.hour = hour(maxInd).datetime(1).Hour;
            if hour(maxInd).datetime.Minute==0
                peakIntensity.datetime = hour(maxInd).datetime;
            else
                peakIntensity.datetime = hour(maxInd).datetime;
                peakIntensity.datetime.Minute = 0; %Want hour of peak intensity to start at 0
            end
            peakIntensity.iScoreArr = hour(maxInd).iScoreArr;
            peakIntensity.iScore = sum(peakIntensity.iScoreArr); %Calculate intensity score scalar for hour of peak intensity
            filterStorms(fc).peak = peakIntensity;
            filterStorms(fc).peakHourStart = peakIntensity.datetime(1);
            
        else %If duration less than one hour
            filterStorms(fc).peak = [];
            filterStorms(fc).peakHourStart = [];
        end
        fc = fc+1;        
    end
    
end

% Uncomment the next section for datestrings instead of datetimes
% Datetimes are more flexible and powerful, but datestrings are easier to
% assess visually from the workspace.
% for dsc = 1:fc-1
%      filterStorms(dsc).startTime = datestr(filterStorms(dsc).startTime);
%      filterStorms(dsc).endTime = datestr(filterStorms(dsc).endTime);
%      filterStorms(dsc).gpeakHourStart = datestr(filterStorms(dsc).peakHourStart);
% end

% Make final output structure
storms.all = allStorms;
storms.filtered = filterStorms;

end