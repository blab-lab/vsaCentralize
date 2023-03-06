function [h] = plot_vsaPaperFigs(figs2plot)
%PLOT_VSAPAPERFIGS  Plot figures for the vsaAdapt2 paper.

if nargin < 1 || isempty(figs2plot), figs2plot = 1; end

adaptColor = [237 28 26]./255;
controlColor = [4 75 214]./255;
colors = [adaptColor;controlColor];
fullPageWidth = 17.4+3.0; % 174 mm + margins
%colWidth = 8.5+3.0; % 85 mm + margins

plotParams.Marker = '.';
plotParams.MarkerSize = 8;
plotParams.MarkerAlpha = .25;
plotParams.LineWidth = .6;
plotParams.LineColor = [.7 .7 .7 .5];
plotParams.avgMarker = 'o';
plotParams.avgMarkerSize = 4;
plotParams.avgLineWidth = 1.25;
plotParams.jitterFrac = .25;
plotParams.FontSize = 13;

vowColors.iy = [.4 .7 .06]; %[78 155 11]/255; %[.55 .85 .15];
vowColors.ae = [.8 0 .4];
vowColors.aa = [.1 0 .9];
vowColors.uw = [.1 .6 .9];

dataPaths = get_dataPaths_vsaAdapt2;

%% Fig 1: Experiment design

[bPlot,ifig] = ismember(1,figs2plot);
if bPlot
    
    %% A: pert field
    sid = 'sp185';
    dataPath = get_acoustLoadPath('vsaAdapt2',sid,'adapt');
    fmtMeans = calc_vowelMeans(fullfile(dataPath,'pre'));
    [~,h1(1)] = calc_pertField('in',fmtMeans,1);
    axlim = [300 1100 1000 1900];
    axis(axlim)
    set(gca,'XTick',axlim(1):200:axlim(2))
    set(gca,'YTick',axlim(3)+100:200:axlim(4))
    axis normal;
    makeFig4Printing;
    
    %% B: spectrogram
    trials2plot = [103 101 102 117];
    params.fmtsColor = controlColor;
    params.fmtsLineWidth = 3;
    params.sfmtsColor = adaptColor;
    params.sfmtsLineWidth = 1.5;
    params.ylim = 4000;
    %params.figpos = [35 700 2510 150];
    
    fCen = calc_vowelCentroid(fmtMeans);
    params.fmtCen = fCen;
    params.thresh_gray = .65;
    params.max_gray = .75;
    
    load(fullfile(dataPath,'data.mat'),'data');
    plot_audapterFormants(data(trials2plot),params);
    h1(2) = plot_audapterFormants(data(trials2plot(1)),params);
    cla;
    set(gca,'YTick',[1000 1949 3429]); % 1000, 1500, 2000 in mels
    makeFig4Printing;
    
    %% C: trial timeline
    h1(3) = figure;
    hold on;
    plot([0 1.5 2.5 10.5 10.5 10.5 12],[0 0 50 50 NaN 0 0],'Color',adaptColor,'LineWidth',2);
    controlLine = hline(0,controlColor);
    controlLine.LineWidth = 2;
    uistack(controlLine,'bottom');
    axlim = [0 12 -15 75];
    axis(axlim);
    set(gca,'YTick',[0 50]) %set(gca,'YTick',axlim(3):25:axlim(4))
    set(gca,'YTickLabel',{'0' '50%'}) %set(gca,'YTickLabel',{'' '0' '' '50%' ''})
    hline(0,'k','--');
    vline(1.5,'k',':');
    vline(2.5,'k',':');
    vline(10.5,'k',':');
    vline(11.5,'k',':');
    xlabel('block number (40 trials/block)')
    ylabel('perturbation')
    
    ypos = 60; fontsize = 7; rot = 55;
    text(.75,ypos,'baseline','FontSize',fontsize,'HorizontalAlignment','center','Rotation',rot)
    text(2,ypos,'ramp','FontSize',fontsize,'HorizontalAlignment','center','Rotation',rot)
    text(3,ypos,'hold','FontSize',fontsize,'HorizontalAlignment','center','Rotation',rot)
    text(11,ypos,'washout','FontSize',fontsize,'HorizontalAlignment','center','Rotation',rot)
    text(12,ypos,'retention','FontSize',fontsize,'HorizontalAlignment','center','Rotation',rot)

    fontsize = 11;
    text(8,62,'adapt','Color',adaptColor,'FontSize',fontsize,'FontWeight','bold','HorizontalAlignment','center')
    text(8,12,'control','Color',controlColor,'FontSize',fontsize,'FontWeight','bold','HorizontalAlignment','center')
    
    ax = axis; ylims = ax([3 4]);
    h_fill = fill([9.5 10.5 10.5 9.5],[ylims(1) ylims(1) ylims(2) ylims(2)],[.9 .9 .9],'EdgeColor','none');
    uistack(h_fill,'bottom');

    makeFig4Printing;
    %set(gca,'XColor','none')

    %% ALL
    figpos_cm = [1 29 fullPageWidth fullPageWidth*(325/1244)]; %figpos = [58 970 1244 325];
    h(ifig) = figure('Units','centimeters','Position',figpos_cm);
    copy_fig2subplot(h1,h(ifig),2,3,{[1 4] [2 3] [5 6]},1);%h1,
    
end

%% Fig 2: vowel space increase

[bPlot,ifig] = ismember(2,figs2plot);
if bPlot
    
    %% A: vowel space, example subjects
    load(fullfile(get_acoustLoadPath('vsaAdapt2'),'fdataByVowel_adapt.mat'),'fdataByVowel');
    fdataAdapt = fdataByVowel;
    load(fullfile(get_acoustLoadPath('vsaAdapt2'),'fdataByVowel_control.mat'),'fdataByVowel');
    fdataControl = fdataByVowel;
    fdataCrossSession = cell2struct([struct2cell(fdataAdapt);struct2cell(fdataControl)],{'baselineAdapt';'adaptationAdapt';'baselineControl';'adaptationControl'});
    %subj2plot = [1 11 12 17]; % 13 14 20]; %% overlay adapt and control
    %subj2plot = [1 11 12 14]; % 3 20]; %% show adapt only
    subj2plot = [1 12 14 11]; %% show adapt and control separately
    plotParams.bLegend = 0;
    plotParams.MarkerSize = 11;
    for sidx = 1:length(subj2plot)
        %h2(sidx) = plot_VSA(fdataByVowel(subj2plot(sidx)),[0 0 0; adaptColor],plotParams);
        %h2(sidx) = plot_VSA(fdataCrossSession(subj2plot(sidx)),[get_desatcolor(get_darkcolor(adaptColor)); adaptColor; get_desatcolor(get_darkcolor(controlColor)); controlColor],plotParams);

        h2(sidx) = plot_VSA(fdataAdapt(subj2plot(sidx)),[0 0 0; adaptColor],plotParams);
        axlim = [350 1008 1000 2000];
        axis(axlim)
        pbaspect([1 1 1]); pbaspect manual;%axis square
        set(gca,'YTick',axlim(3):250:axlim(4))
        set(gca,'XTickLabel','')
        if sidx > 1
            set(gca,'YTickLabel','')
            ylabel('')
        else
            ylabel('F2 (mels)')
        end
        xlabel('')
        %axis normal;
        makeFig4Printing;

        h2(sidx+length(subj2plot)) = plot_VSA(fdataControl(subj2plot(sidx)),[0 0 0; controlColor],plotParams);
        axis(axlim)
        pbaspect([1 1 1]); pbaspect manual;%axis square
        %set(gca,'XTick',axlim(1):200:axlim(2))
        set(gca,'YTick',axlim(3):250:axlim(4))
        if sidx > 1
            set(gca,'YTickLabel','')
            ylabel('')
        else
            ylabel('F2 (mels)')
        end
        xlabel('F1 (mels)')
        %axis normal;
        makeFig4Printing;
    end
    
    %% ALL
    figpos_cm = [15 15 fullPageWidth fullPageWidth*.565];
    h(ifig) = figure('Units','centimeters','Position',figpos_cm);
    copy_fig2subplot(h2,h(ifig),2,length(subj2plot),[],1);

end

%% Fig 3: Increases in vowel space area and vowel contrast

[bPlot,ifig] = ismember(3,figs2plot);
if bPlot
    
    nSubs = length(dataPaths);
    analyses = {'VSA', 'AVS'};
    clear ylims;
    ylims{1} = [0.9 1.2];
    ylims{2} = [0.95 1.1];
    ylimSpacing{1} = 0.1;
    ylimSpacing{2} = 0.05;
    ylimsPaired{1} = [0.55 1.7];
    ylimsPaired{2} = [0.75 1.3];
    h3 = [];
    
    for vs = 1:length(analyses)
        toPlot = analyses{vs};
        
        % get data
        [~,vsTracks.adapt,vsPairedData.adapt] = plot_vsTrack(dataPaths,'adapt',[],[],[],toPlot);
        [~,vsTracks.control,vsPairedData.control] = plot_vsTrack(dataPaths,'null',[],[],[],toPlot);
        avgTrack.adapt = mean(vsTracks.adapt);
        stdTrack.adapt = std(vsTracks.adapt)./sqrt(nSubs);
        avgTrack.control = mean(vsTracks.control);
        stdTrack.control = std(vsTracks.control)./sqrt(nSubs);
        
        %% A,B: vs tracks, all subjects
        h3(end+1) = figure;
        lineWidth = 2;
        errorbar(avgTrack.adapt,stdTrack.adapt,'o-','Color',adaptColor,'MarkerFaceColor',[1 1 1],'MarkerSize',2,'LineWidth',lineWidth);
        hold on
        errorbar(avgTrack.control,stdTrack.control,'o-','Color',controlColor,'MarkerFaceColor',controlColor,'MarkerSize',2,'LineWidth',lineWidth);
        
        
        axlim = [0.5 12.5 ylims{vs}(1) ylims{vs}(2)];
        axis(axlim);
        set(gca,'YTick',axlim(3):ylimSpacing{vs}:axlim(4),'XTick',[1 2 6 10 11 12])
        set(gca,'XTickLabel',{'baseline', 'ramp', 'hold', 'adaptation', 'washout', 'retention'})
        xtickangle(30)
        h_lines = hline(1,'k','--');
        h_lines(end+1) = vline(1.5,'k',':');
        h_lines(end+1) = vline(2.5,'k',':');
        h_lines(end+1) = vline(10.5,'k',':');
        h_lines(end+1) = vline(11.5,'k',':');
        for hl = 1:length(h_lines)
            h_lines(hl).HandleVisibility = 'off';
        end
        h_fill = fill([9.5 10.5 10.5 9.5],[ylims{vs}(1) ylims{vs}(1) ylims{vs}(2) ylims{vs}(2)],[.9 .9 .9],'EdgeColor','none');
        uistack(h_fill,'bottom');
        ylab = sprintf('Normalized %s',toPlot);
        ylabel(ylab)
        makeFig4Printing;
        
        %% C,D (E,F,G,H): paired data, adaptation/washout/retention phases
        phases = {'adaptation','washout','retention'};
        for p = 1:length(phases)
            blockInd = p+9;
            pairedData.adapt = vsTracks.adapt(:,blockInd)';
            pairedData.control = vsTracks.control(:,blockInd)';
            h3(end+1) = plot_pairedData(pairedData,colors,plotParams);
            title(phases{p})
            set(gca,'YLim',ylimsPaired{vs})
            if p==1
                ylabel(ylab)
            else
                set(gca,'YTickLabel',[])
            end
            h_line = hline(1,'k','--');
            h_line.HandleVisibility = 'off';
            makeFig4Printing;
        end
    end
    
    %% ALL
    figpos_cm = [1 15 fullPageWidth fullPageWidth*.565];
    h(ifig) = figure('Units','centimeters','Position',figpos_cm);
    copy_fig2subplot(h3,h(ifig),2,6,{[1 2 3] 7 8 9 [4 5 6] 10 11 12},1);

end

%% Fig 4: Vowel-specific distance from center

[bPlot,~] = ismember(4,figs2plot);
if bPlot
    
    %load(fullfile(get_acoustLoadPath('vsaAdapt2'),'fx.mat'),'rfx_adapt','rfx_control');
    load(fullfile(get_acoustLoadPath('vsaAdapt2'),'fx.mat'),'rfx');
    rfx_adapt = rfx.adapt;
    rfx_control = rfx.control;
    clear rfx;
    
    %% A,B,C: 2D formant diffs
    plotParams.bPlotMeans = 1;
    h4abc = plot_compByVowel([rfx_adapt rfx_control],vowColors,plotParams);
    
    %% D,E,F: paired data
    rfx(1) = rfx_adapt; rfx(2) = rfx_control;
    h4def = plot_vsaAdapt2_pairedData(rfx,'centdistdiff',vowColors,plotParams);
    
    %% ALL
    figWidth = (fullPageWidth/3) * .9; % for next time: .8;
    for ih = 1:length(h4abc)
        figpos_cm = [15 10*(length(h4abc)-ih) figWidth figWidth];
        set(h4abc(ih),'Units','centimeters','Position',figpos_cm);
        makeOpaque(h4abc(ih));
        makeFig4Printing(h4abc(ih));
    end
    for ih = 1:length(h4def)
        figpos_cm = [25 10*(length(h4def)-ih) figWidth figWidth];
        set(h4def(ih),'Units','centimeters','Position',figpos_cm);
        makeOpaque(h4def(ih));
        makeFig4Printing(h4def(ih));
    end
    
end

%% Fig 6: Individual
% Correlation plots stacked

% h6 = figure('Units','centimeters','Position',[4.8331    5.5033    4.4450    6.6851]);
% subplot(2,1,1)
% scatter(vsTracksRaw(1).adapt(:,1),(vsTracks(1).adapt(:,10)-1)*100,10,...
%     'MarkerFaceColor',adaptColor,'MarkerEdgeColor',adaptColor)
% xlabel('Baseline VSA (mels^2)');
% ylabel('Adaptation');
% %title(sprintf('Baseline VSA vs. adaptation'))
% makeFig4Printing
% lsline
% 
% subplot(2,1,2)
% scatter(vsTracksRaw(2).adapt(:,1),(vsTracks(2).adapt(:,10)-1)*100,10,...
%     'MarkerFaceColor',adaptColor,'MarkerEdgeColor',adaptColor)
% xlabel('Baseline AVS (mels)');
% ylabel('Adaptation');
% %title(sprintf('Baseline AVS vs. adaptation'))
% makeFig4Printing
% lsline
% 
% %% Fig S1: VSA vs. AVS
% hs1corr = figure('Units','centimeters','Position',[4 5 6.5 5.6]);
% selector = ~strcmp(datatable{1}.phase,'baseline');
% markerSize = 10;
% scatter(datatable{2}.AVS(selector),datatable{1}.AVS(selector),markerSize,'MarkerFaceColor',adaptColor,'MarkerEdgeColor',adaptColor);
% set(gca,'XTick',.5:.25:1.75)
% set(gca,'YTick',.8:.1:1.3)
% xlabel('normalized VSA');
% ylabel('normalized AVS');
% title(sprintf('VSA vs. AVS'))
% makeFig4Printing
% axis square
% axis([.5 1.75 .8 1.3])
% lsline
% axis([.5 1.75 .8 1.3])


%%


[bPlot,ifig] = ismember(6,figs2plot);
if bPlot
    
    %% A,B: VSA/AVS ordered bars, all subjects
    analyses = {'VSA', 'AVS'};
    axLim{1} = [-0.4 0.8];
    axLim{2} = [-0.2 0.4];
    h6ab = gobjects(1,length(analyses));
    
    for vs = 1:length(analyses)
        toPlot = analyses{vs};
        axlab = sprintf('%s Normalized %s','\Delta',toPlot);
        
        % get data
        [~,vsTracks.adapt,vsPairedData.adapt] = plot_vsTrack(dataPaths,'adapt',[],[],[],toPlot);
        [~,vsTracks.control,vsPairedData.control] = plot_vsTrack(dataPaths,'null',[],[],[],toPlot);
        
        % plot A,B
        h6ab(vs) = figure;
        
        sessionDiff = vsTracks.adapt(:,10)-vsTracks.control(:,10);
        
        plotParams.bSingleSortOrder = 1;
        if plotParams.bSingleSortOrder
            if ~exist('s_idx','var')
                [sortedValues, s_idx] = sort(sessionDiff,'descend');
            else
                sortedValues = sessionDiff(s_idx);
            end
        else
            sortedValues = sort(sessionDiff,'descend');
        end
        bar(sortedValues,1,'FaceColor',[.2 .2 .2]);
        hold on;
        hline(nanmean(sortedValues),[0 0 0],'--');
        txt = sprintf('mean %s increase = %0.2f%%',toPlot,nanmean(sortedValues)*100);
        text(length(sortedValues)/2,axLim{vs}(2)/4,txt)
        set(gca,'XTick',[]);
        set(gca,'YLim',axLim{vs})
        ylabel(axlab)
        makeFig4Printing;
    end

    %% C: 2D formant diffs, all subjects
    
    %load(fullfile(get_acoustLoadPath('vsaAdapt2'),'fx.mat'),'rfx_adapt','rfx_control');
    load(fullfile(get_acoustLoadPath('vsaAdapt2'),'fx.mat'),'rfx');
    rfx_adapt = rfx.adapt;
    rfx_control = rfx.control;
    clear rfx;
    
    plotParams.bPlotMeans = 0;
    h6c = plot_compByVowel([rfx_adapt rfx_control],vowColors,plotParams);
    
    %% ALL
    figWidth = (fullPageWidth/3) * .9; % for next time: .8;
    for ih = 1:length(h6c)
        figpos_cm = [15 10*(length(h6c)-ih) figWidth figWidth];
        set(h6c(ih),'Units','centimeters','Position',figpos_cm);
        makeOpaque(h6c(ih));
        makeFig4Printing(h6c(ih));
    end
    
end

%% Fig S1:
[bPlot,ifig] = ismember(101,figs2plot);
if bPlot
    
    analyses = {'VSA', 'AVS'};
    axLim{1} = [-0.4 0.8];
    axLim{2} = [-0.2 0.4];
    hS1 = gobjects(1,length(analyses));
    
    for vs = 1:length(analyses)
        toPlot = analyses{vs};
        axlab = sprintf('%s Normalized %s','\Delta',toPlot);
        
        % get data
        [~,vsTracks.adapt,vsPairedData.adapt] = plot_vsTrack(dataPaths,'adapt',[],[],[],toPlot);
        [~,vsTracks.control,vsPairedData.control] = plot_vsTrack(dataPaths,'null',[],[],[],toPlot);
        
        %% A,B: ordered bars, all subjects
        hS1(vs) = figure;
        
        sessionDiff = vsTracks.adapt(:,10)-vsTracks.control(:,10);
        
        plotParams.bSingleSortOrder = 1;
        if plotParams.bSingleSortOrder
            if ~exist('s_idx','var')
                [sortedValues, s_idx] = sort(sessionDiff,'descend');
            else
                sortedValues = sessionDiff(s_idx);
            end
        else
            sortedValues = sort(sessionDiff,'descend');
        end
        bar(sortedValues,1,'FaceColor',[.2 .2 .2]);
        hold on;
        hline(nanmean(sortedValues),[0 0 0],'--');
        txt = sprintf('mean %s increase = %0.2f%%',toPlot,nanmean(sortedValues)*100);
        text(length(sortedValues)/2,axLim{vs}(2)/4,txt)
        set(gca,'XTick',[]);
        set(gca,'YLim',axLim{vs})
        ylabel(axlab)
        makeFig4Printing;
    end
    
    %% C,D,E
    
    %% ALL
    figpos_cm = [1 15 fullPageWidth fullPageWidth/3];
    h(ifig) = figure('Units','centimeters','Position',figpos_cm);
    copy_fig2subplot(hS1,h(ifig),1,2,[],1);
    
end

%% Fig S2: checking for clear speech
[bPlot,ifig] = ismember(102,figs2plot);
if bPlot
    
    analyses = {'durations', 'intensityMax', 'f0Max', 'f0Range'};
%     toPlot = {'duration (%)','intensity (a.u.)','f0 (Hz)', 'f0 range (Hz)'};
    toPlot = {'duration (ms)','intensity (a.u.)','max. pitch (Hz)', 'pitch range (Hz)'};
    clear ylims;
%     ylims{1} = [0.9 1.1];
    ylims{1} = [-50 25];
    ylims{2} = [-5 15]; %[-2 10];
    ylims{3} = [-10 10]; %[-3 12];
    ylims{4} = [-10 10];
    ylimsPaired = ylims;
%    ylimsPaired{1} = [0.6 1.4];
    ylimsPaired{1} = [-150 150]; %[-75 75];
    ylimsPaired{2} = [-25 25]; %[-10 20];
    ylimsPaired{3} = [-30 30]; %[-15 25];
    ylimsPaired{4} = [-60 60]; %[-35 35];
%     ylimSpacing{1} = 0.05;
    ylimSpacing{1} = 25;
    ylimSpacing{2} = 5;
    ylimSpacing{3} = 5;
    ylimSpacing{4} = 5; %10;
%     yTickLocs{1} = 0.9:ylimSpacing{1}:1.1;
%     yTickLocs{1} = -50:ylimSpacing{1}:50;
%     yTickLocs{2} = 0:ylimSpacing{2}:10;
%     yTickLocs{3} = 0:ylimSpacing{3}:10;
%     yTickLocs{4} = -10:ylimSpacing{4}:10;
    for yt = 1:length(ylims)
        yTickLocs{yt} = ylims{yt}(1):ylimSpacing{yt}:ylims{yt}(2);
    end

    hS2 = [];
    load(fullfile(get_acoustLoadPath('vsaAdapt2'),'supplementaryData.mat'))
    for vs = 1:length(analyses)
        data2plot = eval(analyses{vs});
        conds = fieldnames(data2plot);
        % get data
        for c = 1:length(conds)
            cnd = conds{c};

            blockData = [];
            blockFirstT = [1 61:40:501];
            for b = 1:length(blockFirstT)-1
                blockData(:,b) = nanmean(data2plot.(cnd)(:,blockFirstT(b):blockFirstT(b+1)-1),2);
            end
            
            
            baselineVal = blockData(:,1);
            if strcmp(analyses{vs}, 'durations')
                normData.(analyses{vs}).(cnd) = 1000*(blockData - baselineVal);
                normVal.(analyses{vs}).(cnd) = 0;
            else
                normData.(analyses{vs}).(cnd) = blockData - baselineVal;
                normVal.(analyses{vs}).(cnd) = 0;
            end
            avgTrack.(cnd) = nanmean(normData.(analyses{vs}).(cnd));
            err = get_errorbars(normData.(analyses{vs}).(cnd)','se');
            stdTrack.(cnd) = err';
        end
        
        %% A,B,I: vs tracks, all subjects
        hS2(end+1) = figure;
        lineWidth = 2;
        errorbar(avgTrack.adapt,stdTrack.adapt,'o-','Color',adaptColor,'MarkerFaceColor',[1 1 1],'MarkerSize',2,'LineWidth',lineWidth);
        hold on
        errorbar(avgTrack.control,stdTrack.control,'o-','Color',controlColor,'MarkerFaceColor',controlColor,'MarkerSize',2,'LineWidth',lineWidth);
        
        
        axlim = [0.5 12.5 ylims{vs}(1) ylims{vs}(2)];
        axis(axlim);
        set(gca,'YTick',yTickLocs{vs},'XTick',[1 2 6 10 11 12])
        set(gca,'XTickLabel',{'baseline', 'ramp', 'hold', 'adaptation', 'washout', 'retention'})
        xtickangle(30)
        h_lines = hline(normVal.(analyses{vs}).(cnd),'k','--');
        h_lines(end+1) = vline(1.5,'k',':');
        h_lines(end+1) = vline(2.5,'k',':');
        h_lines(end+1) = vline(10.5,'k',':');
        h_lines(end+1) = vline(11.5,'k',':');
        for hl = 1:length(h_lines)
            h_lines(hl).HandleVisibility = 'off';
        end
        h_fill = fill([9.5 10.5 10.5 9.5],[ylims{vs}(1) ylims{vs}(1) ylims{vs}(2) ylims{vs}(2)],[.9 .9 .9],'EdgeColor','none');
        uistack(h_fill,'bottom');
        ylab = sprintf('Normalized %s',toPlot{vs});
        ylabel(ylab)
        makeFig4Printing;
       
        %% C,D,E,F,G,H,J,K,L: paired data, adaptation/washout/retention phases
        phases = {'adaptation','washout','retention'};
        for p = 1:length(phases)
            blockInd = p+9;
            pairedData.adapt = normData.(analyses{vs}).adapt(:,blockInd)';
            pairedData.control = normData.(analyses{vs}).control(:,blockInd)';
            hS2(end+1) = plot_pairedData(pairedData,colors,plotParams);
            title(phases{p})
            set(gca,'YLim',ylimsPaired{vs})
            if p==1
                ylabel(ylab)
            else
                set(gca,'YTickLabel',[])
            end
            h_line = hline(normVal.(analyses{vs}).(cnd),'k','--');
            h_line.HandleVisibility = 'off';
            makeFig4Printing;
        end
    end
    
    %% ALL
    figpos_cm = [1 15 fullPageWidth fullPageWidth];
    h(ifig) = figure('Units','centimeters','Position',figpos_cm);
    copy_fig2subplot(hS2,h(ifig),4,6,{1:3,7,8,9,4:6,10,11,12,13:15,19,20,21,16:18,22,23,24},1);

end

%% Fig S3: Individual data, vowel-specific distance from center 

[bPlot,~] = ismember(103,figs2plot);
if bPlot
    
    %% Supplemental: 2D formant diffs, individual data
    
    load(fullfile(get_acoustLoadPath('vsaAdapt2'),'fx.mat'),'rfx_adapt','rfx_control');
    
    plotParams.bPlotMeans = 0;
    hS3 = plot_compByVowel([rfx_adapt rfx_control],vowColors,plotParams);
    
    %% ALL
    figWidth = (fullPageWidth/3) * .9; % for next time: .8;
    for ih = 1:length(hS3)
        figpos_cm = [15 10*(length(hS3)-ih) figWidth figWidth];
        set(hS3(ih),'Units','centimeters','Position',figpos_cm);
        makeOpaque(hS3(ih));
        makeFig4Printing(hS3(ih));
    end
    
end

%% Fig S4: Individual data, vowel-specific compensation (projection)

[bPlot,~] = ismember(104,figs2plot);
if bPlot
    
    load(fullfile(get_acoustLoadPath('vsaAdapt2'),'fx.mat'),'rfx_adapt','rfx_control');
    
    %% A,B,C: paired data
    rfx(1) = rfx_adapt; rfx(2) = rfx_control;
    %hS4 = plot_vsaAdapt2_pairedData(rfx,'proj',vowColors,plotParams);
    
    %% D,E,F: histograms
    %hS4def = plot_vsaAdapt2_hist(rfx,'proj',vowColors,plotParams);    

    %hS4ghi = plot_vsaAdapt2_hist(rfx,'centdistdiff',vowColors,plotParams);    
    
    plotParams.bSingleSortOrder = 0;
%    plotParams.barOrientation = 'horizontal';
%    hS4jkl = plot_vsaAdapt2_orderedBar(rfx,'centdistdiff',vowColors,plotParams);

    plotParams.barOrientation = 'vertical';
%    hS4mno = plot_vsaAdapt2_orderedBar(rfx,'centdistdiff',vowColors,plotParams);

    plotParams.bSingleSortOrder = 1;
    hS4pqr = plot_vsaAdapt2_orderedBarComparison(rfx,{'centdistdiff' 'proj'},vowColors,plotParams);
    hS4stu = plot_vsaAdapt2_orderedBarComparison(rfx,{'centdistdiff' 'percproj'},vowColors,plotParams);

    %% ALL
    figWidth = (fullPageWidth/3) * .9; % for next time: .8;
%     for ih = 1:length(hS4)
%         figpos_cm = [10 8+8*(length(hS4)-ih) figWidth figWidth];
%         set(hS4(ih),'Units','centimeters','Position',figpos_cm);
%         makeOpaque(hS4(ih));
%         makeFig4Printing(hS4(ih));
%     end
%     for ih = 1:length(hS4def)
%         figpos_cm = [15 8+8*(length(hS4def)-ih) figWidth figWidth];
%         set(hS4def(ih),'Units','centimeters','Position',figpos_cm);
%         makeOpaque(hS4def(ih));
%         makeFig4Printing(hS4def(ih));
%     end
%     for ih = 1:length(hS4ghi)
%         figpos_cm = [20 8+8*(length(hS4ghi)-ih) figWidth figWidth];
%         set(hS4ghi(ih),'Units','centimeters','Position',figpos_cm);
%         makeOpaque(hS4ghi(ih));
%         makeFig4Printing(hS4ghi(ih));
%     end
%     for ih = 1:length(hS4jkl)
%         figpos_cm = [25 8+8*(length(hS4jkl)-ih) fullPageWidth figWidth];
%         set(hS4jkl(ih),'Units','centimeters','Position',figpos_cm);
%         makeOpaque(hS4jkl(ih));
%         makeFig4Printing(hS4jkl(ih));
%     end
%     for ih = 1:length(hS4mno)
%         figpos_cm = [25 8+8*(length(hS4mno)-ih) fullPageWidth figWidth];
%         set(hS4mno(ih),'Units','centimeters','Position',figpos_cm);
%         makeOpaque(hS4mno(ih));
%         makeFig4Printing(hS4mno(ih));
%     end
    for ih = 1:length(hS4pqr)
        figpos_cm = [25 8+8*(length(hS4pqr)-ih) fullPageWidth*1.3 figWidth*2];
        set(hS4pqr(ih),'Units','centimeters','Position',figpos_cm);
        makeOpaque(hS4pqr(ih));
        makeFig4Printing(hS4pqr(ih));
    end
    for ih = 1:length(hS4stu)
        figpos_cm = [25 8+8*(length(hS4stu)-ih) fullPageWidth*1.3 figWidth*2];
        set(hS4stu(ih),'Units','centimeters','Position',figpos_cm);
        makeOpaque(hS4stu(ih));
        makeFig4Printing(hS4stu(ih));
    end
    
    
end

%% Fig X:

[bPlot,~] = ismember(222,figs2plot);
if bPlot
    
    %% B: vowel space, all subjects
    adaptPaths = get_dataPaths_vsaAdapt2('adapt');
    controlPaths = get_dataPaths_vsaAdapt2('null');
    allPaths = {adaptPaths controlPaths};
    %allPaths = {adaptPaths(1:3) controlPaths(1:3)};
    trialindsAdaptation = 401:440;

    for a = 1:length(allPaths)
        
        % temp local load
        if a == 1
            %filename = 'fdataByVowel_adapt.mat';
            filename = 'fdataByVowel_normByCentroid_adapt.mat';
        elseif a == 2
            %filename = 'fdataByVowel_control.mat';
            filename = 'fdataByVowel_normByCentroid_control.mat';
        end
        
        if exist(fullfile(get_acoustLocalPath('vsaAdapt2'),filename),'file')
            fprintf('Loading from local path...');
            load(fullfile(get_acoustLocalPath('vsaAdapt2'),filename),'fdataByVowel');
            fprintf(' done\n');
        else
            % load norm data from server
            sessPaths = allPaths{a};
            fprintf('Loading ');
            for dP = 1:length(sessPaths)
                sessPath = sessPaths{dP};
                fprintf('s%d ',dP)
                fdataByVowel(dP).baseline = get_fdataByVowel_normByCentroid(sessPath,'baseline');
                fdataByVowel(dP).adaptation = get_fdataByVowel_normByCentroid(sessPath,trialindsAdaptation);
            end
            fprintf('...done\n');
        end
        
        hS22(a) = plot_VSA(fdataByVowel,[0 0 0; colors(a,:)]);
        
        axlim = [-250 250 -350 350];
        axis(axlim)
        set(gca,'XTick',axlim(1):100:axlim(2))
        set(gca,'YTick',axlim(3):100:axlim(4))
        xlabel('F1 (mels)')
        ylabel('F2 (mels)')
        hlineColor = [.75 .75 .75];
        hl = hline(0,hlineColor); uistack(hl,'bottom');
        vl = vline(0,hlineColor); uistack(vl,'bottom');
        axis normal;
        axis square
        makeFig4Printing;
    end
    
end

%% Graphical abstract

[bPlot,~] = ismember(999,figs2plot);
if bPlot
    %% A: pert field
    sid = 'sp185';
    dataPath = get_acoustLocalPath('vsaAdapt2',sid,'adapt');
    fmtMeans = calc_vowelMeans(fullfile(dataPath,'pre'));
    
    vowels = fieldnames(fmtMeans);
    for v = 1:length(vowels)
        vow = vowels{v};
        fmtMeans.(vow) = hz2mels(fmtMeans.(vow));
    end
    
    fieldDim = 25;
    pertAmp = zeros(fieldDim,fieldDim);
    pertPhi = zeros(fieldDim,fieldDim);
    
    F1Min = 200;
    F1Max = 1500;
    F2Min = 500;
    F2Max = 3500;
    F1Min = hz2mels(F1Min);
    F1Max = hz2mels(F1Max);
    F2Min = hz2mels(F2Min);
    F2Max = hz2mels(F2Max);
    
    %F1 and F2 values of perturbation field
    pertf1 = floor(F1Min:(F1Max-F1Min)/(fieldDim-1):F1Max);
    pertf2 = floor(F2Min:(F2Max-F2Min)/(fieldDim-1):F2Max);
    [xPertField,yPertField] = meshgrid(pertf1,pertf2);
    
    for v = 1:length(vowels)
        vow = vowels{v};
        [~,inds.(vow)(1)] = min(abs(pertf1 - fmtMeans.(vow)(1)));
        [~,inds.(vow)(2)] = min(abs(pertf2 - fmtMeans.(vow)(2)));
    end
    xVS = [inds.iy(1) inds.ae(1) inds.aa(1) inds.uw(1)];
    yVS = [inds.iy(2) inds.ae(2) inds.aa(2) inds.uw(2)];

    %find center of vowel area
    [fCen(1),fCen(2)] = centroid(polyshape({pertf1(xVS)}, {pertf2(yVS)}));
    [~,iFCen(1)] = min(abs(pertf1 - fCen(1)));
    [~,iFCen(2)] = min(abs(pertf2 - fCen(2)));
    
    figure('Units','centimeters','Position',[5 5 7 6])
    fillcolor = [.945 .945 .945];
    fill(pertf1(xVS), pertf2(yVS),fillcolor)
    hold on;
    for iF1 = 1:fieldDim
        for iF2 = 1:fieldDim
            F1 = pertf1(iF1);
            F2 = pertf2(iF2);
            F1half = mean([F1 fCen(1)]);
            F2half = mean([F2 fCen(2)]);
            plot([F1 F1half],[F2 F2half],'Color',adaptColor);
        end
    end
    plot(fCen(1),fCen(2),'+k')
    for v = 1 :length(vowels)
        vow = vowels{v};
        textLoc = fmtMeans.(vow);
        text(textLoc(1),textLoc(2),vow)
    end

    axlim = [300 1100 1000 1900];
    axis(axlim)
    set(gca,'XTick',axlim(1):200:axlim(2))
    set(gca,'YTick',axlim(3)+100:200:axlim(4))
    xlabel('F1 (mels)');
    ylabel('F2 (mels)');
    axis normal;
    makeFig4Printing;
    
    %% B: vowel space, all subjects
    adaptPaths = get_dataPaths_vsaAdapt2('adapt');
    controlPaths = get_dataPaths_vsaAdapt2('null');
    allPaths = {adaptPaths controlPaths};
    %allPaths = {adaptPaths(1:3) controlPaths(1:3)};
    trialindsAdaptation = 401:440;
    
    for a = 1:length(allPaths)
        
        % temp local load
        if a == 1
            %filename = 'fdataByVowel_adapt.mat';
            filename = 'fdataByVowel_normByCentroid_adapt.mat';
        elseif a == 2
            %filename = 'fdataByVowel_control.mat';
            filename = 'fdataByVowel_normByCentroid_control.mat';
        end
        
        if exist(fullfile(get_acoustLocalPath('vsaAdapt2'),filename),'file')
            fprintf('Loading from local path...');
            load(fullfile(get_acoustLocalPath('vsaAdapt2'),filename),'fdataByVowel');
            fprintf(' done\n');
        else
            % load norm data from server
            sessPaths = allPaths{a};
            fprintf('Loading ');
            for dP = 1:length(sessPaths)
                sessPath = sessPaths{dP};
                fprintf('s%d ',dP)
                fdataByVowel(dP).baseline = get_fdataByVowel_normByCentroid(sessPath,'baseline');
                fdataByVowel(dP).adaptation = get_fdataByVowel_normByCentroid(sessPath,trialindsAdaptation);
            end
            fprintf('...done\n');
        end
        
        hS22(a) = plot_VSA(fdataByVowel,[0 0 0; colors(a,:)]);
        
        axlim = [-250 250 -350 350];
        axis(axlim)
        set(gca,'XTick',axlim(1):100:axlim(2))
        set(gca,'YTick',axlim(3):100:axlim(4))
        xlabel('F1 (mels)')
        ylabel('F2 (mels)')
        hlineColor = [.75 .75 .75];
        hl = hline(0,hlineColor); uistack(hl,'bottom');
        vl = vline(0,hlineColor); uistack(vl,'bottom');
        axis normal;
        axis square
        makeFig4Printing;
    end
    
end

