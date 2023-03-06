function [hPhase] = plot_vsaAdapt2_orderedBar(rfx,toPlot,vowColors,plotParams)

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
        axLim = [-100 150];
        axlab = '\Delta compensation (mels)';
    case 'percproj'
        axLim = [-100 150];
        axlab = '\Delta compensation (%)';
    case 'effproj'
        axLim = [-100 150];
        axlab = '\Delta efficiency (%)';
    case 'centdistdiff'
        axLim = [-100 175];
        axlab = '\Delta norm. distance to center (mels)';
    otherwise
        axLim = [-100 150];
        axlab = toPlot;
end

for p=1:length(phases)
    phase = phases{p};
    for v=1:length(vowels)
        vow = vowels{v};
        sessionDiff = rfx(1).(toPlot).(vow).(phase) - rfx(2).(toPlot).(vow).(phase);
        h.(phase)(v) = figure;
        switch plotParams.barOrientation
            case 'horizontal'
                if plotParams.bSingleSortOrder
                    if ~exist('s_idx','var')
                        [sortedValues, s_idx] = sort(sessionDiff);
                    else
                        sortedValues = sessionDiff(s_idx);
                    end
                else
                    [sortedValues, s_idx] = sort(sessionDiff);
                end
                barh(sortedValues,1,'FaceColor',vowColors.(vow));
                set(gca,'XLim',axLim)
                xlabel(axlab)
                if v > 1
                    set(gca,'YTickLabel','');
                else
                    ylabel('participant #')
                end
            case 'vertical'
                if plotParams.bSingleSortOrder
                    if ~exist('s_idx','var')
                        [sortedValues, s_idx] = sort(sessionDiff,'descend');
                    else
                        sortedValues = sessionDiff(s_idx);
                    end
                else
                    [sortedValues, s_idx] = sort(sessionDiff,'descend');
                end
                bar(sortedValues,1,'FaceColor',vowColors.(vow));
                set(gca,'YLim',axLim)
                xlabel('participant #')
                ylabel(axlab)
                if v > 1
                    set(gca,'YTickLabel','');
                else
                    ylabel(axlab)
                end
        end
        %text(1.5,YLim(1)+25,arpabet2ipa(vow,'/'),'HorizontalAlignment','center','FontSize',plotParams.FontSize)
        %set(gca,'YLim',YLim)
        box off;
    end
    
    hPhase(p) = figure;

    xpos = 1000;
    ypos = 1000 - 550*(p-1);
    hPhase(p).Position = [xpos ypos 560 420];

    copy_fig2subplot(h.(phase),hPhase(p),1,4,[],1);
    supertitle(phase)
end



