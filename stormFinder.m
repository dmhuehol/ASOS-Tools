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
[~,weatherInd,~] = find(weather); % Find indices where precip occurs
weatherInd = weatherInd';

findGaps = diff(weatherInd); %Look for gaps in the indices where precip occurs
gapLog = findGaps>24; %If the gap is larger than 24 indices, then it's longer than 2 hours
[gapInd,~,~] = find(gapLog);
weatherData = ASOS(weather);

for wq = 1:length(gapInd)-1
    storms(wq).data = weatherData(gapInd(wq)+1:gapInd(wq+1)-1); %#ok
    storms(wq).startTime = storms(wq).data(1).Datetime; %#ok
    storms(wq).endTime = storms(wq).data(end).Datetime; %#ok
end


end