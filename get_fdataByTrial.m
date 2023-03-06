function [fdataByTrial] = get_fdataByTrial(dataVals,avgtype,avgval,bMels,toTrack)
%GET_FDATABYTRIAL  Average each trial's data within specified window.
%   [fdataByTrial] = get_fdataByTrial(dataVals,avgtype,avgval,toTrack)
%
% Updated 2021-07 by CWN to accommodate dataVals structures with cell
% arrays, where each cell represents one word/vowel within a trial

if nargin < 2 || isempty(avgtype), avgtype = 'mid'; end
if nargin < 3 || isempty(avgval), avgval = 50; end
if nargin < 4 || isempty(bMels), bMels = 1; end
if nargin < 5 || isempty(toTrack), toTrack = {'f1' 'f2'}; end

i = 1;
while ~exist('fs','var')
    try
        fs = get_fs_from_taxis(dataVals(i).ftrack_taxis);
    catch
        i = i+1;
    end     
end

% define averaging function (which timepoints/percent, etc.)
switch avgtype
    case 'mid'
        avgfn = @(ftrack) midnperc(ftrack,avgval);
    case 'first'
        avgfn = @(ftrack) ftrack(1:min(ceil(avgval/fs),length(ftrack)));
    case 'next'
        avgfn = @(ftrack) ftrack(min(ceil(avgval/fs)+1,length(ftrack)):min(2*ceil(avgval/fs),length(ftrack)));
    case 'then'
        avgfn = @(ftrack) ftrack(min(2*ceil(avgval/fs)+1,length(ftrack)):min(3*ceil(avgval/fs),length(ftrack)));
end

bDataValsIsCell = iscell(dataVals(1).f1);

% get data by trial
for f=1:length(toTrack)
    fmt = toTrack{f};
    
    % calculate the average over each of the trials
    for itrial = 1:length(dataVals)
        if bDataValsIsCell
            for c = 1:length(dataVals(1).f1) %max(c) ==  the number of cells in the cell array
                fdataByTrial.(fmt){c}(itrial) = mean(avgfn(dataVals(itrial).(fmt){c}), 'omitnan');
            end
        else
            fdataByTrial.(fmt)(itrial) = mean(avgfn(dataVals(itrial).(fmt)), 'omitnan');
        end
    end
    % convert to mels
    if bMels
        if bDataValsIsCell
            for c = 1:length(dataVals(1).f1)
                fdataByTrial.(fmt){c} = hz2mels(fdataByTrial.(fmt){c});
            end
        else
            fdataByTrial.(fmt) = hz2mels(fdataByTrial.(fmt));
        end
    end
end


end %EOF