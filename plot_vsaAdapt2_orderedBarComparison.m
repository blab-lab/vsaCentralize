function [hPhase] = plot_vsaAdapt2_orderedBarComparison(rfx,arrayToPlot,vowColors,plotParams)

if nargin < 2 || isempty(arrayToPlot), arrayToPlot = {'centdistdiff' 'proj'}; end

%vowels = fieldnames(rfx(1).diff1);
vowels = {'iy' 'ae' 'aa' 'uw'};
%phases = fieldnames(rfx(1).diff1.(vowels{1}));
phases = {'adaptation'};

if nargin < 3 || isempty(vowColors)
    vowColors.iy = [.4 .7 .06];
    vowColors.ae = [.8 0 .4];
    vowColors.aa = [.1 0 .9];
    vowColors.uw = [.1 .6 .9];
end
if nargin < 4, plotParams = []; end

for p=1:length(phases)
    phase = phases{p};
    s_idx = struct;
    for tP = 1:length(arrayToPlot)
        toPlot = arrayToPlot{tP};
        switch toPlot
            case 'proj'
                axLim = [-175 175];
                axlab = '\Delta compensation (mels)';
                units = ' mels';
            case 'percproj'
                axLim = [-125 125];
                axlab = '\Delta compensation (%)';
                units = '%';
            case 'effproj'
                axLim = [-100 150];
                axlab = '\Delta efficiency (%)';
                units = '%';
            case 'centdistdiff'
                axLim = [-150 175];
                axlab = '\Delta norm. distance to center (mels)';
                units = ' mels';
            otherwise
                axLim = [-100 150];
                axlab = toPlot;
                units = '';
        end
        for v=1:length(vowels)
            vow = vowels{v};
            sessionDiff = rfx(1).(toPlot).(vow).(phase) - rfx(2).(toPlot).(vow).(phase);
            h.(phase)(v+length(vowels)*(tP-1)) = figure;
            switch plotParams.barOrientation
                case 'horizontal'
                    if plotParams.bSingleSortOrder
                        if ~isfield(s_idx,vow)
                            [sortedValues, s_idx.(vow)] = sort(sessionDiff);
                        else
                            sortedValues = sessionDiff(s_idx.(vow));
                        end
                    else
                        [sortedValues, s_idx.(vow)] = sort(sessionDiff);
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
                        if ~isfield(s_idx,vow)
                            [sortedValues, s_idx.(vow)] = sort(sessionDiff,'descend');
                        else
                            sortedValues = sessionDiff(s_idx.(vow));
                        end
                    else
                        [sortedValues, s_idx.(vow)] = sort(sessionDiff,'descend');
                    end
                    bar(sortedValues,1,'FaceColor',vowColors.(vow));
                    
                    hold on;
                    hline(nanmean(sortedValues),[0 0 0],'--');
                    txt = sprintf('mean = %0.1f%s',nanmean(sortedValues),units);
                    text(length(sortedValues)/2,nanmean(sortedValues)*1.75,txt,'FontSize',8)

                    set(gca,'XTick',[]);
                    set(gca,'YLim',axLim)
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
        
    end
    hPhase(p) = figure;
    
    xpos = 1000;
    ypos = 1000 - 550*(p-1);
    hPhase(p).Position = [xpos ypos 560 420];
    
    copy_fig2subplot(h.(phase),hPhase(p),2,4,[],1);
    supertitle(phase)
end



