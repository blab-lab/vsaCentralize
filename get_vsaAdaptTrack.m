function [binAvg,baseavg,normavg] = get_vsaAdaptTrack(dataPath,avgtype,avgval,binSize,vsMeas,toTrack,subword)
%GET_VSAADAPTATIONTRACK  Adaptation for a single subject across an experiment.
%   Detailed explanation goes here

if nargin < 2 || isempty(avgtype), avgtype = 'mid'; end
if nargin < 3 || isempty(avgval), avgval = 50; end
if nargin < 4 || isempty(binSize), binSize = 10; end
if nargin < 5 || isempty(vsMeas), vsMeas = 'VSA'; end
if nargin < 6 || isempty(toTrack), toTrack = {'f1' 'f2'}; end
if nargin < 7 || isempty(subword), bVSACalc = 1;else; bVSACalc = 0; end
% get experiment info
load(fullfile(dataPath,'expt.mat'),'expt');

% get data
load(fullfile(dataPath,'dataVals.mat'));
fs = get_fs_from_taxis(dataVals(1).ftrack_taxis);
% define averaging function (which timepoints/percent, etc.)
switch avgtype
    case 'mid'
        avgfn = @(fmttrack) midnperc(fmttrack,avgval);
    case 'first'
        avgfn = @(fmttrack) fmttrack(1:min(ceil(avgval/fs),length(fmttrack)));
    case 'next'
        avgfn = @(fmttrack) fmttrack(min(ceil(avgval/fs)+1,length(fmttrack)):min(2*ceil(avgval/fs),length(fmttrack)));
    case 'then'
        avgfn = @(fmttrack) fmttrack(min(2*ceil(avgval/fs)+1,length(fmttrack)):min(3*ceil(avgval/fs),length(fmttrack)));
end

if bVSACalc
    nTrials = length(dataVals);
    nBaseline = length(expt.inds.conds.baseline);
    nWords = length(expt.words);
    binSize = binSize*nWords;
    nBins = ceil(nTrials/binSize);
    nBaselineBins = nBaseline / binSize;
    if mod(nBaselineBins,1) ~= 0
        warning('Bin size does not align with number of baseline trials! Omiting start of baseline')
        extraTrials = nBaseline - binSize*floor(nBaselineBins);
        nBaselineBins = floor(nBaselineBins);
    else
        extraTrials = 0;
    end
    
    for i=1:length(toTrack)
        for itrial = extraTrials+1:nTrials
            avg.allTrials.(toTrack{i})(itrial) = hz2mel(nanmean(avgfn(dataVals(itrial).(toTrack{i}))));
        end
    end
    
    for i = 1:nBins
        if i*(binSize-1)+binSize > nTrials
            currTrials = i*(binSize-1)+1+extraTrials:nTrials;
        else
            currTrials = i*(binSize-1)+1+extraTrials:i*(binSize-1)+binSize+extraTrials;
        end
        vowelList = expt.allVowels(currTrials);
        uLoc = currTrials(vowelList==3);
        iLoc = currTrials(vowelList==1);
        aLoc = currTrials(vowelList==4);
        aeLoc = currTrials(vowelList==2);

        switch vsMeas
            case 'VSA'
                binAvg(i) = polyarea([nanmean(avg.allTrials.f1(iLoc)) nanmean(avg.allTrials.f1(aLoc)) nanmean(avg.allTrials.f1(aeLoc)) nanmean(avg.allTrials.f1(uLoc))],[nanmean(avg.allTrials.f2(iLoc)) nanmean(avg.allTrials.f2(aLoc)) nanmean(avg.allTrials.f2(aeLoc)) nanmean(avg.allTrials.f2(uLoc))]);
            case 'VSAnoU'
                binAvg(i) = polyarea([nanmean(avg.allTrials.f1(iLoc)) nanmean(avg.allTrials.f1(aLoc)) nanmean(avg.allTrials.f1(aeLoc))],[nanmean(avg.allTrials.f2(iLoc)) nanmean(avg.allTrials.f2(aLoc)) nanmean(avg.allTrials.f2(aeLoc))]);
            case 'AVS'
                vowDists = [];
                %/i/-/ae/
                vowDists(1) = sqrt(...
                    (nanmean(avg.allTrials.f1(iLoc))-nanmean(avg.allTrials.f1(aeLoc)))^2+...
                    (nanmean(avg.allTrials.f2(iLoc))-nanmean(avg.allTrials.f2(aeLoc)))^2);
                %/i/-/a/
                vowDists(2) = sqrt(...
                    (nanmean(avg.allTrials.f1(iLoc))-nanmean(avg.allTrials.f1(aLoc)))^2+...
                    (nanmean(avg.allTrials.f2(iLoc))-nanmean(avg.allTrials.f2(aLoc)))^2);
                %/ae/-/a/
                vowDists(3) = sqrt(...
                    (nanmean(avg.allTrials.f1(aeLoc))-nanmean(avg.allTrials.f1(aLoc)))^2+...
                    (nanmean(avg.allTrials.f2(aeLoc))-nanmean(avg.allTrials.f2(aLoc)))^2);
                %/u/-/a/
                vowDists(4) = sqrt(...
                    (nanmean(avg.allTrials.f1(uLoc))-nanmean(avg.allTrials.f1(aLoc)))^2+...
                    (nanmean(avg.allTrials.f2(uLoc))-nanmean(avg.allTrials.f2(aLoc)))^2);
                %/u/-/ae/
                vowDists(5) = sqrt(...
                    (nanmean(avg.allTrials.f1(uLoc))-nanmean(avg.allTrials.f1(aeLoc)))^2+...
                    (nanmean(avg.allTrials.f2(uLoc))-nanmean(avg.allTrials.f2(aeLoc)))^2);
                %/u/-/i/
                vowDists(6) = sqrt(...
                    (nanmean(avg.allTrials.f1(uLoc))-nanmean(avg.allTrials.f1(iLoc)))^2+...
                    (nanmean(avg.allTrials.f2(uLoc))-nanmean(avg.allTrials.f2(iLoc)))^2);
                binAvg(i) = mean(vowDists);    
            case 'AVSnoU'
                vowDists = [];
                %/i/-/ae/
                vowDists(1) = sqrt(...
                    (nanmean(avg.allTrials.f1(iLoc))-nanmean(avg.allTrials.f1(aeLoc)))^2+...
                    (nanmean(avg.allTrials.f2(iLoc))-nanmean(avg.allTrials.f2(aeLoc)))^2);
                %/i/-/a/
                vowDists(2) = sqrt(...
                    (nanmean(avg.allTrials.f1(iLoc))-nanmean(avg.allTrials.f1(aLoc)))^2+...
                    (nanmean(avg.allTrials.f2(iLoc))-nanmean(avg.allTrials.f2(aLoc)))^2);
                %/ae/-/a/
                vowDists(3) = sqrt(...
                    (nanmean(avg.allTrials.f1(aeLoc))-nanmean(avg.allTrials.f1(aLoc)))^2+...
                    (nanmean(avg.allTrials.f2(aeLoc))-nanmean(avg.allTrials.f2(aLoc)))^2);
                binAvg(i) = mean(vowDists);
        end
    end
    
    baseavg = nanmean(binAvg(1:nBaselineBins));
    normavg = binAvg ./ baseavg;
    
else
    if isfield(expt,'nBaseline')
        baselineTrials = expt.inds.conds.baseline;
        subwordTrials = expt.inds.words.(subword);
        nBaseline = length(intersect(baselineTrials,subwordTrials));
    else
        baselineTrials = expt.inds.conds.baseline;
        subwordTrials = expt.inds.words.(subword);
        nBaseline = length(intersect(baselineTrials,subwordTrials));
    end
    word_dataVals = dataVals(expt.inds.words.(subword));
    nTrials = length(word_dataVals);
    for i=1:length(toTrack)
        % calculate the average over each of the trials
        avg.allTrials.(toTrack{i}) = zeros(1,nTrials);
        for itrial = 1:nTrials
            avg.allTrials.(toTrack{i})(itrial) = nanmean(avgfn(word_dataVals(itrial).(toTrack{i})));
        end
        % calculate baseline & normalized average
        baseavg.allTrials.(toTrack{i}) = nanmean(avg.allTrials.(toTrack{i})(1:nBaseline));
        normavg.allTrials.(toTrack{i}) = avg.allTrials.(toTrack{i}) - baseavg.allTrials.(toTrack{i});

        %     % calculate bins
        %     if binSize ~= 1
        %         nBins = floor(nTrials/binSize);
        %         avg.bins.(toTrack{i}) = zeros(1,nBins);
        %         for ibin=1:nBins
        %             avg.bins.(toTrack{i})(ibin) = nanmean(avg.allTrials.(toTrack{i})(binSize*(ibin-1)+1:binSize*ibin));
        %         end
        %         % calculate baseline % normalized average
        %         baseavg.bins.(toTrack{i}) = nanmean(avg.bins.(toTrack{i})(1:floor(nBaseline/binSize)));
        %         normavg.bins.(toTrack{i}) = avg.bins.(toTrack{i}) - baseavg.bins.(toTrack{i});
        %     end
    end
end