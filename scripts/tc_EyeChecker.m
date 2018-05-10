function [TargetTriggerOccurance,fullData] = tc_EyeChecker(varargin)
%% [TargetTriggerOccurance,fullData] = tc_EyeChecker(varargin)
%
% Spawns file selection dialog, to select .asc file obtained after wrapping
% the EyeTracker's .edf file or uses pre-defined path. Within the selected file it will be checked
% (line by line) whether a certain trigger value occured and how often
%
% example: tc_EyeChecker
% output: command line output of size 2 x 10 - The first row displays the
% trigger value and the second row, how often it coccured
%
% example: TargetTriggerOccurance = tc_EyeChecker([],[1,2,3,4])
% output: command line output of size 2 x 4 - The first row displays the
% trigger value [1,2,3,4] and the second row, how often it coccured. The
% same data is assigned to TargetTriggerOccurance
%
% example output:
%   1     2    11    12    13    14    21    22    23    24
% 116   116     7     7     7     7     7     7     7     7
%
% example: [~,fullData] = tc_EyeChecker('/users/user/myFile.asc',[1,2,3,4])
% output: structure containing two fields: BlinkTrialsTable & BlinkRegTable
%
% BlinkTrialsTable contains a N x 5 matrix where N is the number of trials.
% The respective column headers are:
% Trial number | start Sample | end Sample | blink index (0/1)
%
% BlinkRegTable contains a N x 3 matrix where N is the number of trials.
% The respective column headers are:
% Trial number | start relative to trial | end relative to trial
%
% Note: that a blink will be recorded if it occurs within a trial. Which
% means that either the OFFset of the blink is after the stimulus ONset or
% the ONset of a blink if before the stimulus OFFset
% All values are given in ms relative to the stimulus onset.
TargetTriggerOccurance=0; % default state of output
fullData=struct('BlinkTrialsTable',[],'BlinkRegTable',[],'TargetTriggerOccurance',[]);

TriggerValues=[1,2,11:14,21:24]; % define default target trigger values to look for

if numel(varargin)>0 % check of input
    if numel(varargin)>1
        TriggerValues=varargin{2}; % accept input target trigger values
    end
    file_=varargin{1};
    if isempty(file_)
        [FileName, PathName]=uigetfile('*.asc','select ASC file'); % open file selection dialogs
        file_=[PathName,FileName];
    end
else
    [FileName, PathName]=uigetfile('*.asc','select ASC file'); % open file selection dialogs
    file_=[PathName,FileName];
end

if ischar(file_) % check valid file input
    TargetTriggerOccurance=[TriggerValues;zeros(size(TriggerValues))]; % add counter
    fid = fopen(file_); % open file
    tline = fgetl(fid); % read first line
    BlinkTrialsTable=[];
    BlinkRegTable=[];
    trialCounter=0;
    trialLength=2100;
    disp('scanning file...')
    while ischar(tline) % if still valid (String)
        str_=regexp(tline,'INPUT.*\f*.\f*','match'); % find matching pattern for trial onset
        if ~isempty(str_) % check if pattern was found
            tmp=strsplit(str_{1}); % split pattern
            trigVal=str2double(tmp{3});
            trigSample=str2double(tmp{2});
            if ismember(trigVal,TargetTriggerOccurance(1,:)) % check if value is one of the targets
                trialCounter=trialCounter+1;
                ind=trigVal==TargetTriggerOccurance(1,:); % find index of target in counter
                TargetTriggerOccurance(2,ind)=TargetTriggerOccurance(2,ind)+1; % raise specific counter by 1
                BlinkTrialsTable=cat(1,BlinkTrialsTable,[trialCounter,trigSample,trigSample+trialLength-1,trigVal,0]);
            end
        end
        str_=regexp(tline,'EBLINK.*','match'); % find matching pattern for blink onset and offset
        if ~isempty(str_)
            tmp=strsplit(str_{1});
            blinkSamples=[str2double(tmp{3}),str2double(tmp{4})];
            if blinkSamples(2)>=trigSample && blinkSamples(1)<=(trigSample+trialLength-1)
                if size(BlinkTrialsTable,1)>0
                    BlinkTrialsTable(end,5)=1; % set blink occurance to true
                    BlinkRegTable=cat(1,BlinkRegTable,[trialCounter,blinkSamples-trigSample]);
                end
            end
        end
        tline = fgetl(fid); % get next line
    end
    disp('done.')
    fullData.BlinkTrialsTable=BlinkTrialsTable;
    fullData.BlinkRegTable=BlinkRegTable;
    fullData.TargetTriggerOccurance=TargetTriggerOccurance;
    fclose(fid); % close file
end
