%plot_vsaPaperFigAVS
%% get the data for AVS and VSA
calc_avsStats

%% plot data
controlColor = [4 75 214]./255;
adaptColor = [237 28 26]./255;

colors = [adaptColor;controlColor];
 
ylims(1).main = [0.95 1.1];
ylims(2).main = [0.9 1.2];
ylims(1).sub = [0.75 1.3];
ylims(2).sub = [0.55 1.7];
ylimSpacing = [0.05 0.1];
ylabels = {'Normalized AVS','Normalized VSA'};
nSubs = length(dataPaths);
clear h
for p = 1:2
    %plot group average data
    avgTrack{1} = mean(vsTracks(p).adapt);
    stdTrack{1} = std(vsTracks(p).adapt)./sqrt(nSubs);
    avgTrack{2} = mean(vsTracks(p).control);
    stdTrack{2} = std(vsTracks(p).control)./sqrt(nSubs);

    
    lineWidth = 3;
    if p == 1
        h(1) = figure;
    else
        h(end+1) = figure;
    end
    for i = 1:2
        errorbar(avgTrack{i},stdTrack{i},'Color',colors(i,:),'LineWidth',lineWidth);
        hold on
    end
    axlim = [0.5 12.5 ylims(p).main(1) ylims(p).main(2)];
    axis(axlim);
    set(gca,'YTick',axlim(3):ylimSpacing(p):axlim(4),'XTick',[1 2 6 10 11 12])
    
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
    h_fill = fill([9.5 10.5 10.5 9.5],[ylims(p).main(1)+0.001 ylims(p).main(1)+0.001 1.3 1.3],[.9 .9 .9],'EdgeAlpha',0);
    uistack(h_fill,'bottom');
%     xlabel('Phase')
    ylabel(ylabels{p})
%     legend({'perturbation','control'},'Location','northeast')
    makeFig4Screen;


%     %plot paired data for adaptation
%     if exist('pairedData','var');clear pairedData;end
%     pairedData.baseline = vsTracks(p).adapt(:,1)';
%     pairedData.hold = vsTracks(p).adapt(:,10)';
%     pairedData.washout = vsTracks(p).adapt(:,11)';
%     pairedData.retention = vsTracks(p).adapt(:,12)';
%     h(2) = plot_pairedData(pairedData,colors(1,:));
%     title('adapt')
%     set(gca,'YLim',ylims)
%     makeFig4Screen;
% 
%     %plot paired data for null
%     clear pairedData
%     pairedData.baseline = vsTracks(p).control(:,1)';
%     pairedData.hold = vsTracks(p).control(:,10)';
%     pairedData.washout = vsTracks(p).control(:,11)';
%     pairedData.retention = vsTracks(p).control(:,12)';
%     h(3) = plot_pairedData(pairedData,colors(2,:));
%     title('null')
%     set(gca,'YLim',ylims)
%     makeFig4Screen;

    %plot paired data for adaptation
    clear pairedData
    pairedData.adapt = vsTracks(p).adapt(:,10)';
    pairedData.control = vsTracks(p).control(:,10)';
    h(end+1) = plot_pairedData(pairedData,colors);
    title('adaptation')
    ylabel(ylabels{p})
    set(gca,'YLim',ylims(p).sub)
    h_line = hline(1,'k','--');
    h_line.HandleVisibility = 'off';
    makeFig4Screen;

    %plot paired data for washout
    clear pairedData
    pairedData.adapt = vsTracks(p).adapt(:,11)';
    pairedData.control = vsTracks(p).control(:,11)';
    h(end+1) = plot_pairedData(pairedData,colors);
    title('washout')
    set(gca,'YLim',ylims(p).sub)
    h_line = hline(1,'k','--');
    h_line.HandleVisibility = 'off';
    makeFig4Screen;

    %plot paired data for retention
    clear pairedData
    pairedData.adapt = vsTracks(p).adapt(:,12)';
    pairedData.control = vsTracks(p).control(:,12)';
    h(end+1) = plot_pairedData(pairedData,colors);
    title('retention')
    set(gca,'YLim',ylims(p).sub)
    h_line = hline(1,'k','--');
    h_line.HandleVisibility = 'off';
    makeFig4Screen;

    hAll(p) = figure('Position',[100 100 800 600]);
    copy_fig2subplot(h(end-3),hAll(p),2,3,{1:3});
    copy_fig2subplot(h(end-2),hAll(p),2,3,{4});
    copy_fig2subplot(h(end-1),hAll(p),2,3,{5});
    copy_fig2subplot(h(end),hAll(p),2,3,{6});
end
close(h)

%% Correlation plots
h_corr = figure('Position',[100 100 1000 300]);

subplot(1,3,1)
selector = 1:length(datatable{1}.phase);
scatter(datatable{2}.AVS(selector),datatable{1}.AVS(selector),...
    'MarkerFaceColor',adaptColor,'MarkerEdgeColor',adaptColor)
xlabel('VSA');
ylabel('AVS');
title(sprintf('VSA vs. AVS'))
makeFig4Printing
lsline

subplot(1,3,2)
scatter(vsTracksRaw(1).adapt(:,1),(vsTracks(1).adapt(:,10)-1)*100,...
    'MarkerFaceColor',adaptColor,'MarkerEdgeColor',adaptColor)

xlabel('Baseline VSA (mels^2)');
ylabel('Adaptation (% change)');
title(sprintf('Baseline VSA vs. adaptation'))
makeFig4Printing
lsline

subplot(1,3,3)
scatter(vsTracksRaw(2).adapt(:,1),(vsTracks(2).adapt(:,10)-1)*100,...
    'MarkerFaceColor',adaptColor,'MarkerEdgeColor',adaptColor)
xlabel('Baseline AVS (mels)');
ylabel('Adaptation (% change)');
title(sprintf('Baseline AVS vs. adaptation'))
makeFig4Printing
lsline
