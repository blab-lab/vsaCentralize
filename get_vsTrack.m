function [vsTrack,binConds] = get_vsTrack(dataPath,avgtype,avgval,binSizePerWord,vsMeas,bMels)
%GET_VSTRACK  Vowel space for a single subject across an experiment.
%   [vsTrack,binConds] = get_vsTrack(dataPath,avgtype,avgval,binSizePerWord,vsMeas,bMels)
%   VSMEAS can be VSA or AVS.

if nargin < 2 || isempty(avgtype), avgtype = 'mid'; end
if nargin < 3 || isempty(avgval), avgval = 50; end
if nargin < 4 || isempty(binSizePerWord), binSizePerWord = 10; end
if nargin < 5 || isempty(vsMeas), vsMeas = 'AVS'; end
if nargin < 6 || isempty(bMels), bMels = 1; end

load(fullfile(dataPath,'expt.mat'),'expt');
load(fullfile(dataPath,'dataVals.mat'),'dataVals');
conds = expt.conds;
vowels = expt.vowels;

fdataByTrial = get_fdataByTrial(dataVals,avgtype,avgval,bMels);

% create bins
% binSize = binSizePerWord*length(expt.words);
binSize = 40;
binSizes = []; binConds = [];
for c = 1:length(conds)
    cond = conds{c};
    nTrialsPerCond.(cond) = length(expt.inds.conds.(cond));
    nBinsPerCond.(cond) = nTrialsPerCond.(cond)/binSize;
    if nBinsPerCond.(cond) ~= round(nBinsPerCond.(cond))
        warning('%s trials not divisible by %d. Creating a single %s bin.',cond,binSize,cond)
        nBinsPerCond.(cond) = 1;
        binSizes = [binSizes nTrialsPerCond.(cond)];
        binConds = [binConds c];
    else
        binSizes = [binSizes repmat(binSize,1,nBinsPerCond.(cond))];
        binConds = [binConds repmat(c,1,nBinsPerCond.(cond))];
    end
end
nbins = length(binSizes);

% get vowel space for each bin
vsTrack = zeros(1,nbins);
for b = 1:nbins
    % get trials in current bin
    currTrials = sum(binSizes(1:b-1))+1:sum(binSizes(1:b));
    
    % separate trials by vowel and average
    for v = 1:length(vowels)
        vow = vowels{v};
        vowTrials = intersect(currTrials,expt.inds.vowels.(vow));
        fdataByVowel.f1.(vow) = nanmean(fdataByTrial.f1(vowTrials));
        fdataByVowel.f2.(vow) = nanmean(fdataByTrial.f2(vowTrials));
    end

    % get vowel space
    switch vsMeas
        case 'VSA'
            vsTrack(b) = calc_VSA(fdataByVowel);
        case 'VSA3'
            [~,vsTrack(b)] = calc_VSA(fdataByVowel);
        case 'VSAnoU'
            fdataByVowel.f1 = rmfield(fdataByVowel.f1,'uw');
            fdataByVowel.f2 = rmfield(fdataByVowel.f2,'uw');
            vsTrack(b) = calc_VSA(fdataByVowel);
        case 'AVS'
            vsTrack(b) = calc_AVS(fdataByVowel);
        case 'AVSnoU'
            fdataByVowel.f1 = rmfield(fdataByVowel.f1,'uw');
            fdataByVowel.f2 = rmfield(fdataByVowel.f2,'uw');
            vsTrack(b) = calc_AVS(fdataByVowel);
    end
    
end

%vsBase = nanmean(vsTrack(1:nBinsPerCond.baseline));
%vsTrackNorm = vsTrack ./ vsBase;
