%%extract500Ind
%   Extract 500 indices after a desired datetime. Useful when checking
%   specific cases within very large structures of ASOS data.
%
%   General form: [subset] = extract500Ind(dtOfInterest,ASOS)
%
%   Inputs:
%   dtOfInterest: the datetime of interest. Create with
%      datetime(yyyy,mm,dd,00,00,00)
%   ASOS: structure of ASOS data
%
%   Output:
%   subset: subset of ASOS data containing the 500 indices after the
%   requested time
%
%   Written by: Daniel Hueholt
%   North Carolina State University
%   Research Assistant at Environment Analytics
%   Version date: 6/19/2020
%   Last major revision: 6/19/2020
%

function [subset] = extract500Ind(dtOfInterest,ASOS)

allDates = [ASOS.Datetime];
allDatesLog = allDates == dtOfInterest; % Logically index on the datetime of interest
[~,foundIt,~] = find(allDatesLog);
subset = ASOS(foundIt:foundIt+500); % Grab 500 indices after the datetime, usually

end
