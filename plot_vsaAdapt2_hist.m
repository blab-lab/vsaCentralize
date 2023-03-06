function [hPhase] = plot_vsaAdapt2_hist(rfx,toPlot,vowColors,plotParams)

if nargin < 2 || isempty(toPlot), toPlot = 'proj'; end

%vowels = fieldnames(rfx(1).diff1);
vowels = {'iy' 'ae' 'aa' 'uw'};
phases = fieldnames(rfx(1).diff1.(vowels{1}));

%lineColor = [.8 .8 .8];
hlineColor = [.25 .25 .25];

if nargin < 3 || isempty(vowColors)
    vowColors.iy = [.4 .7 .06];
    vowColors.ae = [.8 0 .4];
    vowColors.aa = [.1 0 .9];
    vowColors.uw = [.1 .6 .9];
end
if nargin < 4, plotParams = []; end

switch toPlot
    case 'proj'
        YLim = [-90 140];
        ylab = '\Delta compensation (mels)';
    case 'percproj'
        YLim = [-100 150];
        ylab = '\Delta compensation (%)';
    case 'effproj'
        YLim = [-100 150];
        ylab = '\Delta efficiency (%)';
    case 'centdistdiff'
        YLim = [-100 150];
        ylab = '\Delta distance to center (mels)';
    otherwise
        YLim = [-100 150];
        ylab = toPlot;
end

for p=1:length(phases)
    phase = phases{p};
    for v=1:length(vowels)
        vow = vowels{v};
        sessionDiff = rfx(1).(toPlot).(vow).(phase) - rfx(2).(toPlot).(vow).(phase);
        h.(phase)(v) = figure;
        histogram(sessionDiff,'BinWidth',10,'FaceColor',vowColors.(vow),'Orientation', 'horizontal');
        %text(1.5,YLim(1)+25,arpabet2ipa(vow,'/'),'HorizontalAlignment','center','FontSize',plotParams.FontSize)
        set(gca,'XLim',[0 7])
        set(gca,'YLim',YLim)
        xlabel('#')
        if v > 1
            set(gca,'YTickLabel','');
        else
            ylabel(ylab)
        end
        hl = hline(0,hlineColor,'--');
        uistack(hl,'bottom');
        box off;
    end
    
    hPhase(p) = figure;

    xpos = 1000;
    ypos = 1000 - 550*(p-1);
    hPhase(p).Position = [xpos ypos 560 420];

    copy_fig2subplot(h.(phase),hPhase(p),1,4,[],1);
    supertitle(phase)
end



