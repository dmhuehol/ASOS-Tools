%%weatherCodeSearch
    %Function to find all dates and times when a given weather code
    %occurred in a given ASOS data structure.
    %
    %General form: [dates,exactTimes] = weatherCodeSearch(weatherCode,ASOS)
    %
    %Outputs:
    %dates: all dates where the input code was observed.
    %exactTimes: the exact dates and times where the input code was observed
    %   in DMY HMS format (all second entries are fake zeros).
    %
    %Inputs:
    %weatherCode: an ASOS weather code, which must be input as a string.
    %   Common codes: 'RA' = rain, 'SN' = snow, 'PL' = sleet, 'FZRA' =
    %   freezing rain, 'FZDZ' = freezing drizzle, 'DZ' = drizzle
    %ASOS: an ASOS 5-minute data structure.
    %
    %Written by: Daniel Hueholt
    %North Carolina State University
    %Undergraduate Research Assistant at Environment Analytics
    %Version Date: 6/05/2018
    %Last Major Revision: 6/05/2018
    %
    %See also ASOSimportFiveMin
    %

function [dates,exactTimes] = weatherCodeSearch(weatherCode,ASOS)
presentWeather = {ASOS.PresentWeather};

weather = strfind(presentWeather,weatherCode);
noWeather = cellfun('isempty',weather); %'isempty' is faster than @isempty
weather(noWeather) = {0}; %Insert 0 into all empty cells, otherwise conversion to double will remove all blank entries
weather = cell2mat(weather); %Make double
logicalWeather = logical(weather); %Logically index on ~0
%All logical 1 elements now correspond to where the weather code is detected
validInd = logicalWeather==1;

%Useful command window message if no weather codes were found
if isempty(nonzeros(validInd))==1
    dates = []; exactTimes = []; %Set outputs
    msg = 'No instances of this weather code could be located.';
    disp(msg)
    return %End the function
end

%Extract times
validYear = [ASOS(validInd).Year]';
validMonth = [ASOS(validInd).Month]';
validDay = [ASOS(validInd).Day]';
validHour = [ASOS(validInd).Hour]';
validMinute = [ASOS(validInd).Minute]';
fakeSecond = zeros(length(validMinute),1); %Assume all seconds are zero entries

validDates = datenum(validYear,validMonth,validDay);
validDates = unique(validDates);
dates = datestr(validDates); %Output unique days where code occurred
validExactTimes = datenum(validYear,validMonth,validDay,validHour,validMinute,fakeSecond);
exactTimes = datestr(validExactTimes); %Output every time where the code occurred
end