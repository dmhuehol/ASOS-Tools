%%stormFinder
%   General concept: give an ASOS seasonal structure
%   return start time, end time, peak precipitation intensity for every
%   storm, where 2 hour break defines storm end
%   2 hour break => 24 index gap
%   Written by: Daniel Hueholt
%   North Carolina State University
%   Undergraduate Research Assistant at Environment Analytics
%   Version Date: 6/8/2020
%   Last Major Revision: 6/8/2020
%


function [detectedStorms,detectedSnowstorms] = stormFinder(ASOS)
presentWeather = {ASOS.PresentWeather};

%precipCode = {'RA','FZRA','SN','PL','DZ','FZDZ','SG'}; % all possible weather codes corresponding to precipitation
precipCode = 'SN';
weather = strfind(presentWeather,precipCode);
noWeather = cellfun('isempty',weather); %'isempty' is faster than @isempty
weather(noWeather) = {0}; %Insert 0 into all empty cells, otherwise conversion to double removes blank entries
weather = cell2mat(weather); %Convert to double
logicalWeather = logical(weather); %Logically index on ~0
%All logical 1 elements now correspond to where the weather code is detected
validInd = logicalWeather==1;

indArr = 1:1:length(ASOS);
precipInd = indArr(validInd);


detectedStorms = 'Cats';
detectedSnowstorms = 'Rabbits';

end