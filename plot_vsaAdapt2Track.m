function [] = plot_vsaAdapt2Track(dataPaths,phase2plot,avgtype,avgval,binSize,vsMeas,toPlot,plotcolor)
%PLOT_VSAADAPTATIONTRACK  Plot timecourse of acoustic adaptation.

if ischar(dataPaths), dataPaths = {dataPaths}; end
if nargin < 2 || isempty(phase2plot), phase2plot = 'adapt'; end
if nargin < 3 || isempty(avgtype), avgtype = 'mid'; end
if nargin < 4 || isempty(avgval), avgval = 50; end
if nargin < 5 || isempty(binSize), binSize = 10; end
if nargin < 6 || isempty(vsMeas), vsMeas = 'VSAnoU'; end
if nargin < 7 || isempty(toPlot), toPlot = {'f1' 'f2'}; end
if nargin < 8 || isempty(plotcolor)
    switch avgtype
    case 'mid'
        plotcolor = 'k';
    case 'first'
        plotcolor = 'r';
    case 'next'
        plotcolor = 'g';
    case 'then'
        plotcolor = 'b';
    end
end

    
% get subject data
for dP=1:length(dataPaths)
    if strcmp(phase2plot,'diff')
        dataPath = fullfile(dataPaths{dP},'adapt');
        load(fullfile(dataPath,'expt.mat'),'expt');
        nTrials = expt.ntrials;
        nWords = length(expt.words);
        nBins = ceil(nTrials/(binSize*nWords));
        [dPAvgAdapt,~,~] = get_vsaAdaptTrack(dataPath,avgtype,avgval,binSize,vsMeas,toPlot);
        
        dataPath = fullfile(dataPaths{dP},'null');
        [dPAvgNull,~,~] = get_vsaAdaptTrack(dataPath,avgtype,avgval,binSize,vsMeas,toPlot);
        normavg(dP,1:nBins) = dPAvgAdapt-dPAvgNull;
        
        noChangeVal = 0;
    else
        dataPath = fullfile(dataPaths{dP},phase2plot);
        load(fullfile(dataPath,'expt.mat'),'expt'); 
        nTrials = expt.ntrials;
        nWords = length(expt.words);
        nBins = ceil(nTrials/(binSize*nWords));

        [~,~,dPAvg] = get_vsaAdaptTrack(dataPath,avgtype,avgval,binSize,vsMeas,toPlot);
        normavg(dP,1:nBins) = dPAvg;
        
        noChangeVal = 1;
    end
    nBaseline = length(expt.inds.conds.baseline);
    nRamp = length(expt.inds.conds.ramp);
    nHold = length(expt.inds.conds.hold);
    nWashout = length(expt.inds.conds.washout);
    vlines(1) = 0.5+floor(nBaseline/(binSize*nWords));
    vlines(2) = vlines(1) + nRamp/(binSize*nWords);
    vlines(3) = vlines(2) + nHold/(binSize*nWords);
    vlines(4) = vlines(3) + nWashout/(binSize*nWords);
    
%     plot(dPAvg)
%     for v=1:length(vlines)
%         vline(vlines(v),'k',':');
%     end
%     hline(1,'k');
    
%     nwords = length(expt.words);
%     for w = 1:nwords
%         subword = expt.words{w};
%         [~,~,normavg(dP)] = get_vsaAdaptationTrack(dataPath,avgtype,avgval,binSize,toPlot,subword); %#ok<AGROW>
%         
%         % get expt phase info
%         vlines(1) = expt.nBaseline;
%         vlines(2) = vlines(1) + expt.nRamp;
%         vlines(3) = vlines(2) + expt.nHold;
%         vlines(4) = vlines(3) + expt.nWashout;
%         
%         toBin = fieldnames(normavg); % different bin sizes
%         for b = 1:length(toBin)
%             catOverBins = cat(1,normavg.(toBin{b}));
%             for i = 1:length(toPlot)
%                 allSubj.(toBin{b}).(toPlot{i}) = cat(1,catOverBins.(toPlot{i}));
%                 allSubjNorm.(toBin{b}).(toPlot{i}) = nanmean(allSubj.(toBin{b}).(toPlot{i}),1);
%             end
%         end
%         
%         %% plot
%         for i=1:length(toPlot)
%             % all trials
%             figname = toPlot{i}; %naming figure
%             %figure('Name',sprintf('%s %s all',subword,figname)) %naming figure
%             subplot(length(toPlot), nwords, w+(nwords*(i-1)))
%             plot(allSubjNorm.allTrials.(figname),'.','Color',plotcolor)
%             title(sprintf('%s %s all',subword,figname))
%             % draw lines to separate experiment phases
%             for v=1:length(vlines)
%                 vline(vlines(v)/nwords); % divide by number of words when plotting by words
%             end
%             hline(0);
%             axis tight
%             
%             %     % bins
%             %     if binSize ~= 1
%             %         binfigname = (sprintf('%s binned',figname));
%             %         figure('Name',binfigname)
%             %         plot(allSubjNorm.bins.(figname),'o','Color',plotcolor)
%             %         % draw lines to separate experiment phases
%             %         for v=1:length(vlines)
%             %             vline(vlines(v)/binSize);
%             %         end
%             %         hline(0);
%             %         axis tight
%             %         title(binfigname)
%             %     end
%         end
%     end
end
figure('Name','All participants', 'Position',[200,100,1500,800]);
sig = mean(normavg);
err = std(normavg);

% plot_filled_err([],sig,err)
hold on
% plot(sig,'r')
plot(sig,'k','LineWidth',4)
for i =1:size(normavg,1)
    plot(normavg(i,:),'LineWidth',2)
end
for v=1:length(vlines)
    vline(vlines(v),'k',':');
end
hline(noChangeVal,'k');


