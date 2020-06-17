%%stormFinder
%   Given an structure of ASOS data, return start time, end time, and data
%   for all storms in the season. Individual storms determined by 2-hour
%   gaps.
%
%   General form: [storms] = stormFinder(ASOS)
%
%   Under development: Also return peak precipitation intensity for every
%   storm
%   2 hour break => 24 index gap
%   Written by: Daniel Hueholt
%   North Carolina State University
%   Research Assistant at Environment Analytics
%   Version Date: 6/16/2020
%   Last Major Revision: 6/16/2020
%


function [storms] = stormFinder(ASOS)
presentWeather = {ASOS.PresentWeather};

precipCode = ["SN","BLSN","PL","DZ","FZDZ","RA","FZRA","SG","GS"]; % all possible weather codes corresponding to precipitation ordered usefully
weather = contains(presentWeather,precipCode);
% Where weather is 1, there is at least one precip code hit
% where weather is 0, precip is not occurring
% Instead of looping and removing codes, check for e.g. BLSN yes and SN no?
[~,weatherInd,~] = find(weather); % Find indices where precip occurs
weatherInd = weatherInd';

findGaps = diff(weatherInd); %Look for gaps in the indices where precip occurs
gapLog = findGaps>24; %If the gap is larger than 24 indices, then it's longer than 2 hours
[gapInd,~,~] = find(gapLog);
weatherData = ASOS(weather);

codesOnly = {weatherData.PresentWeather};
heavy = contains(codesOnly,'+');
light = contains(codesOnly,'-');
[~,heavyInd,~] = find(heavy);
[~,lightInd,~] = find(light);
iScore = ones(length(codesOnly),1)*2;
iScore(heavyInd) = 3;
iScore(lightInd) = 1;

fc = 1;
for wq = 1:length(gapInd)-1
    allStorms(wq).data = weatherData(gapInd(wq)+1:gapInd(wq+1)-1); %#ok
    allStorms(wq).startTime = allStorms(wq).data(1).Datetime; %#ok
    allStorms(wq).endTime = allStorms(wq).data(end).Datetime; %#ok
    allStorms(wq).iScoreArr = iScore(gapInd(wq)+1:gapInd(wq+1)-1); %#ok
    iScoreScalar = sum(allStorms(wq).iScoreArr);
    allStorms(wq).iScore = iScoreScalar; %#ok
    
    if iScoreScalar > 15
        filterStorms(fc).data = allStorms(wq).data; %#ok
        filterStorms(fc).startTime = allStorms(wq).startTime; %#ok
        filterStorms(fc).endTime = allStorms(wq).endTime; %#ok
        filterStorms(fc).iScoreArr = allStorms(wq).iScoreArr; %#ok
        filterStorms(fc).iScore = iScoreScalar; %#ok
        fc = fc+1;
    end
        
end

% Make final output structure
storms.all = allStorms;
storms.filtered = filterStorms;

end