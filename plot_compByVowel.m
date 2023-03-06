function [h] = plot_compByVowel(rfx,colors,plotParams)
%PLOT_COMPBYVOWEL  Plot compensation in 2D formant space.
%   --> PLOT_F1F2DIFF

if nargin < 2 || isempty(colors)
    colors.iy = [.4 .7 .06];
    colors.ae = [.8 0 .4];
    colors.aa = [.1 0 .9];
    colors.uw = [.1 .6 .9];
end

plotParams.lineColor = [.8 .8 .8]; % for individual subj plots
plotParams.hlineColor = [.7 .7 .7];
plotParams.bErrorBars = 1;
plotParams.bEllipse = 1;
plotParams.ellipseAlpha = .25;
plotParams.bArrow = 1;
plotParams.bMeanPoints = 1;
plotParams.scaleFact = 1; % 0.7 for vsaAdapt2

%% boxplot
% if nargin < 2, toPlot = 'proj'; end
% if ischar(toPlot), toPlot = {toPlot}; end
% for r = 1:length(rfx)
%     for tP = 1:length(toPlot)
%         plotType = toPlot{tP};
%         vowels = fieldnames(rfx(r).(plotType));
%         nvowels = length(vowels);
%         
%         phaseData = [];
%         phaseData0 = [];
%         lab = {};
%         col = [];
%         
%         for v=1:nvowels
%             vow=vowels{v};
%             phases = fieldnames(rfx(r).(plotType).(vow));
%             nphases = length(phases);
%             for p=1:nphases
%                 phase=phases{p};
%                 phaseData(:,end+1) = rfx(r).(plotType).(vow).(phase);
%                 phaseData0(:,end+1) = rfx(r).(plotType).(vow).(phase);
%                 lab{end+1} = sprintf('%s%d',vow,p);
%                 col(end+1,:) = colors.(vow);
%             end
%             phaseData(:,end+1) = NaN(size(phaseData(:,1)));
%             phaseData0(:,end+1) = zeros(size(phaseData(:,1)));
%             lab{end+1} = '';
%             col(end+1,:) = [1 1 1];
%         end
%         
%         h = figure;
%         hax = axes;
%         boxplot(hax,phaseData,'labels',lab,'colors',col);
%         xlim = nvowels*(nphases+1);
%         hax.XLim = [0 xlim];
%         
%         hold on;
%         hl = hline(0,plotParams.hlineColor);
%         uistack(hl,'bottom');
%         switch plotType
%             case 'diff2d'
%                 ylab = 'formant movement (mels)';
%             case 'proj'
%                 ylab = 'compensation (mels)';
%             case 'percproj'
%                 ylab = 'compensation (%)';
%             case 'effproj'
%                 ylab = 'efficiency (%)';
%             otherwise
%                 ylab = plotType;
%         end
%         ylabel(ylab)
%         makeFig4Screen;
%         set(h,'Position',[710 400 750 420]);
%         
%         % remove extraneous ticks and fix labels
%         hax.XTick = setdiff(0:xlim,0:nphases+1:xlim);
%         XTickLab = get(gca,'XTickLabel');
%         XTickLab(nphases+1:nphases+1:xlim) = [];
%         hax.XTickLabel = XTickLab;
%         
%         % figure;
%         % CategoricalScatterplot(phaseData0,'labels',lab)
%         % hold on;
%         % hline(0);
%         
%     end
% end

%% vowel space plots
vowels = fieldnames(rfx(1).diff1);
nvowels = length(vowels);
phases = fieldnames(rfx(1).diff1.(vowels{1}));

%% vowel norm diff: subject mean

if plotParams.bPlotMeans
    axmax = 50;
else
    axmax = 200;
end

h = gobjects(1,length(phases));
for p = 1:length(phases)
    phase = phases{p};
    h(p) = figure('Position',[100 100 560 560]);
    %hax = tight_subplot(2,2,.02,.14,.11);
    hax = tight_subplot(2,nvowels/2,.02,.11,.11);
    for nax = 1:length(hax), axis(hax(nax),'square'); end
    % for each vowel
    for v = 1:nvowels
        vow = vowels{v};
        color{1} = colors.(vow);
        color{2} = get_desatcolor(get_darkcolor(colors.(vow),2));
        axes(hax(v)); % get axes
        hold on;
        
        if plotParams.bPlotMeans
            %% plot means
            for c = 1:length(rfx) % for each plot (condition)
                % get means
                meandiff1(c) = nanmean(rfx(c).diff1.(vow).(phase));
                meandiff2(c) = nanmean(rfx(c).diff2.(vow).(phase));
                stediff1(c) = nanste(rfx(c).diff1.(vow).(phase));
                stediff2(c) = nanste(rfx(c).diff2.(vow).(phase));
                
                % plot means
                if plotParams.bMeanPoints
                    plot(meandiff1(c),meandiff2(c),'.','Color',color{c},'MarkerSize',plotParams.MarkerSize);
                end
                
                % plot error bars
                if plotParams.bErrorBars
                    plot([meandiff1(c)-stediff1(c) meandiff1(c)+stediff1(c)],[meandiff2(c) meandiff2(c)],'Color',color{c});
                    plot([meandiff1(c) meandiff1(c)],[meandiff2(c)-stediff2(c) meandiff2(c)+stediff2(c)],'Color',color{c});
                end
                
                % plot ellipses
                if plotParams.bEllipse
                    he = rectangle('Position',[meandiff1(c)-stediff1(c) meandiff2(c)-stediff2(c) stediff1(c)*2 stediff2(c)*2],...
                        'Curvature',[1 1],'FaceColor',[get_lightcolor(color{c}) plotParams.ellipseAlpha],'EdgeColor','none');
                    uistack(he,'bottom');
                end
                
                % plot arrows
                if plotParams.bArrow
                    plot([0 meandiff1(c)],[0 meandiff2(c)],'-','Color',color{c},'LineWidth',plotParams.LineWidth);
                end
            end
        else
            %% plot individual subjects paired points
            for s = 1:length(rfx(1).diff1.(vow).(phase))
                plot([rfx(1).diff1.(vow).(phase)(s) rfx(2).diff1.(vow).(phase)(s)],[rfx(1).diff2.(vow).(phase)(s) rfx(2).diff2.(vow).(phase)(s)],'Color',plotParams.lineColor)
                hold on;
            end
            %plot(rfx(1).diff1.(vow).(phase),rfx(1).diff2.(vow).(phase),'+','Color',adaptColor,'MarkerSize',10);
            plot(rfx(1).diff1.(vow).(phase),rfx(1).diff2.(vow).(phase),'o','Color',color{1},'MarkerSize',5);
            plot(rfx(2).diff1.(vow).(phase),rfx(2).diff2.(vow).(phase),'.','Color',get_desatcolor(get_darkcolor(color{1},2)),'MarkerSize',12);
        end
        
        % plot 0 lines to cover axes
        %axis([-axmax-5 axmax+5 -axmax-5 axmax+5])
        scaleFact = plotParams.scaleFact;
        if v==1
            axis([-axmax-5 axmax*scaleFact -axmax*scaleFact axmax+5])
        elseif v==2
            axis([-axmax*scaleFact axmax+5 -axmax*scaleFact axmax+5])
        elseif v==3
            axis([-axmax-5 axmax*scaleFact -axmax-5 axmax*scaleFact])
        elseif v==4
            axis([-axmax*scaleFact axmax+5 -axmax-5 axmax*scaleFact])
        else
            axis([-axmax axmax -axmax axmax])
        end
        %axis square
        hl = hline(0,plotParams.hlineColor);
        uistack(hl,'bottom');
        vl = vline(0,plotParams.hlineColor);
        uistack(vl,'bottom');
        
        % format axes
%         hax(v).XTick = -axmax:axmax/2:axmax;
%         hax(v).YTick = -axmax:axmax/2:axmax;
%         xticklabels('auto');
%         yticklabels('auto');
%         if v < 3                             % re
%             set(hax(v),'XTickLabel','');
%             ysign = 1;
%         else
%             xlabel('F1 (mels)');
%             ysign = -1;
%         end
%         if iseven(v)
%             set(hax(v),'YTickLabel','');
%             xsign = 1;
%         else
%             ylabel('F2 (mels)');
%             xsign = -1;
%         end
        
        if v==1
            hax(v).XTick = -axmax:(axmax/2):(axmax/2);
            hax(v).YTick = -(axmax/2):(axmax/2):axmax;
            hax(v).XTickLabel = '';
            hax(v).YTickLabel = {'' num2str(0) '' num2str(axmax)};
            ylabel('F2 (mels)');
            xsign = -1;
            ysign = 1;
        elseif v==2
            hax(v).XTick = -(axmax/2):(axmax/2):axmax;
            hax(v).YTick = -(axmax/2):(axmax/2):axmax;
            hax(v).XTickLabel = '';
            hax(v).YTickLabel = '';
            xsign = 1;ysign = 1;
        elseif v==3
            hax(v).XTick = -axmax:(axmax/2):(axmax/2);
            hax(v).YTick = -axmax:(axmax/2):(axmax/2);
            hax(v).XTickLabel = {num2str(-axmax) '' num2str(0) ''};
            hax(v).YTickLabel = {num2str(-axmax) '' num2str(0) ''};
            ylabel('F2 (mels)');
            xlabel('F1 (mels)');
            xsign = -1;
            ysign = -1;
        elseif v==4
            hax(v).XTick = -(axmax/2):(axmax/2):axmax;
            hax(v).YTick = -axmax:(axmax/2):(axmax/2);
            hax(v).XTickLabel = {'' num2str(0) '' num2str(axmax)};
            hax(v).YTickLabel = '';
            xlabel('F1 (mels)');
            xsign = 1; ysign = -1;
        end
        
        text(.75*axmax*xsign,.75*axmax*ysign,arpabet2ipa(vow,'/'),'HorizontalAlignment','center','FontSize',plotParams.FontSize);
    end
    xpos = 400;
    ypos = 400 - 550*(p-1);
    set(h(p),'Position',[xpos ypos 569.0000  471.3333]);
    supertitle(phase)
end
