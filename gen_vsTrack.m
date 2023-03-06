function [ ] = gen_vsTrack(dataPath,avgtype,avgval,binSizePerWord,vsMeas,bMels,bSaveCheck)
%GEN_VSTRACK  Generates experiment vowel space file for a subject.
%   [vsTrack,binConds] = gen_vsTrack(dataPath,avgtype,avgval,binSizePerWord,vsMeas,bMels)
%   VSMEAS can be VSA or AVS.

if nargin < 1 || isempty(dataPath), dataPath = cd; end
if nargin < 2 || isempty(avgtype), avgtype = 'mid'; end
if nargin < 3 || isempty(avgval), avgval = 50; end
if nargin < 4 || isempty(binSizePerWord), binSizePerWord = 10; end
if nargin < 5 || isempty(vsMeas), vsMeas = 'AVS'; end
if nargin < 6 || isempty(bMels), bMels = 1; end
if nargin < 7 || isempty(bSaveCheck), bSaveCheck = 1; end

% get filename
if bMels
    units = 'mels';
else
    units = 'hz';
end
savefile = fullfile(dataPath,sprintf('vsTrack_%s%d_%s_%s.mat',avgtype,avgval,vsMeas,units));

% check for existence of file
if bSaveCheck
    bSave = savecheck(savefile);
else
    bSave = 1;
end

% generate file
if bSave
    [vsTrack,binConds] = get_vsTrack(dataPath,avgtype,avgval,binSizePerWord,vsMeas,bMels);
    save(savefile,'vsTrack','binConds');
    fprintf('%s created.\n',savefile);
else
    fprintf('Save canceled.');
end
