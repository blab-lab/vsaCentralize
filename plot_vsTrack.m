function [h,vsTracksNorm,pairedData] = plot_vsTrack(dataPaths,session,avgtype,avgval,binSizePerWord,vsMeas,bMels)
%PLOT_VSTRACK  Plot timecourse of vowel space across an experiment.

if ischar(dataPaths), dataPaths = {dataPaths}; end
if nargin < 2 || isempty(session), session = 'adapt'; end
if nargin < 3 || isempty(avgtype), avgtype = 'mid'; end
if nargin < 4 || isempty(avgval), avgval = 50; end
if nargin < 5 || isempty(binSizePerWord), binSizePerWord = 10; end
if nargin < 6 || isempty(vsMeas), vsMeas = 'AVS'; end
if nargin < 7 || isempty(bMels), bMels = 1; end

% get filename
if bMels
    units = 'mels';
else
    units = 'hz';
end
vsTrackFileName = sprintf('vsTrack_%s%d_%s_%s.mat',avgtype,avgval,vsMeas,units);

% get tracks for each subject
for dP = 1:length(dataPaths)
    if strcmp(session,'diff')
        % adapt
        dataPath = fullfile(dataPaths{dP},'adapt');        
        vsTrackFile = fullfile(dataPath,vsTrackFileName);
        if ~exist(vsTrackFile,'file')
            gen_vsTrack(dataPath,avgtype,avgval,binSizePerWord,vsMeas,bMels);
        end
        load(vsTrackFile,'vsTrack','binConds');
        vsTracks(dP,:) = vsTrack;
        
        % null
        dataPath = fullfile(dataPaths{dP},'null');
        vsTrackFile = fullfile(dataPath,vsTrackFileName);
        if ~exist(vsTrackFile,'file')
            gen_vsTrack(dataPath,avgtype,avgval,binSizePerWord,vsMeas,bMels);
        end
        load(vsTrackFile,'vsTrack');
        vsTracksNull(dP,:) = vsTrack;
        
        % difference
        vsTracksNorm(dP,:) = vsTracks(dP,:)-vsTracksNull(dP,:);
        noChangeVal = 0;
    else
        if strcmp(session,'single')
            dataPath = fullfile(dataPaths{dP});
        else
            dataPath = fullfile(dataPaths{dP},session);
        end
        vsTrackFile = fullfile(dataPath,vsTrackFileName);
        if ~exist(vsTrackFile,'file')
            gen_vsTrack(dataPath,avgtype,avgval,binSizePerWord,vsMeas,bMels);
        end
        load(vsTrackFile,'vsTrack','binConds');
        vsTracks(dP,:) = vsTrack;
        
        vsBase = nanmean(vsTrack(binConds==1));
        vsTracksNorm(dP,:) = vsTrack ./ vsBase;
        noChangeVal = 1;
    end
    
    % compare data across bins
    if strcmp(session,'single')
        conds2plot = {'baseline' 'hold'};
    else
        conds2plot = {'baseline' 'adaptation'};
    end
    bins2plot = {1 10};
    load(fullfile(dataPath,'expt'),'expt')
    for c = 1:length(conds2plot)
        cond = conds2plot{c};
        if isempty(bins2plot)
            condInd = find(strcmp(expt.conds,cond));
            binInds = find(binConds == condInd);
        else
            binInds = bins2plot{c};
        end
        pairedData.(cond)(dP) = vsTrack(:,binInds(end));
    end
end

%% plot by trial
h = figure('Position',[100,75,1500,800]);
sig = mean(vsTracksNorm);
err = std(vsTracksNorm);

hold on
for i =1:size(vsTracksNorm,1)
    plot(vsTracksNorm(i,:),'LineWidth',2)
end
% plot_filled_err([],sig,err)
plot(sig,'k','LineWidth',5)

% get phase lines
for i = 1:max(binConds)-1
    vl = 0.5 + find(binConds==i, 1, 'last');
    vline(vl,'k',':');
end
hline(noChangeVal,'k');
