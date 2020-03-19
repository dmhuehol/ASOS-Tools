%%ASOSgrabber
    %Function to retrieve a section of data from an ASOS data structure at
    %and around a given input time. Returns the index within the ASOS structure 
    %corresponding to the input time, and a structure containing the data
    %+/- grab number of entries from this index.
    %
    %General form:
    % [data,foundIt] = ASOSgrabber(year,month,day,hour,minute,inputStructure,grab)
    %
    %Outputs:
    %data: structure containing the subset of the original structure
    %   containing the data and the entries +/- grab distance from the
    %   index.
    %foundIt: index in input structure corresponding to given time
    %
    %Inputs:
    %year: 4 digit year
    %month: 1 or 2 digit month
    %day: 1 or 2 digit day
    %hour: 1 or 2 digit UTC
    %minute: 1 or 2 digit minute
    %inputStructure: an ASOS data structure
    %grab: number of entries to be retrieved (total number of entries
    %   output will be twice this number, from foundIt-grab to
    %   foundIt+grab)
    %
    %Written by: Daniel Hueholt
    %Undergraduate Research Assistant at Environment Analytics
    %North Carolina State University
    %Version Date: 4/6/2018
    %Last major revision: 10/10/2017
    %
    %See also: ASOSdownloadFiveMin, ASOSimportFiveMin
    %
    
function [data,foundIt] = ASOSgrabber(year,month,day,hour,minute,inputStructure,grab)
if exist('grab','var')==0 %If no grab number is specified
    grab = 12; %retrieve ~2 hours of 5 minute observations
    noGrabMsg = 'No grab number specified! Retrieved +/- 12 entries.';
    disp(noGrabMsg)
end

if nargin<6 %Any possible run of ASOSgrabber will have at least 6 variables
    msg = 'Missing input variable(s)! Check input and try again.';
    error(msg);
end

for count = 1:length(inputStructure) %Loop through input structure
    if inputStructure(count).Year==year && inputStructure(count).Month==month && inputStructure(count).Day==day && inputStructure(count).Hour==hour && inputStructure(count).Minute==minute %If all time entries match the input time
        foundIt = count; %then this entry is the desired entry
        break %Stop looping as soon as desired entry is found (saves time)
    else
        %do nothing
    end
end

if exist('foundIt','var')==1 %If the input time was in the structure
    data = inputStructure(foundIt-grab:foundIt+grab); %the output data is all entries +/- grab from the desired entry
else %Otherwise the input time was not in the structure
    msg = 'No data found for input time!';
    error(msg); %Send an error to the user
end

end