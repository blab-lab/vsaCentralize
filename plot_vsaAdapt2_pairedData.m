function [hPhase] = plot_vsaAdapt2_pairedData(rfx,toPlot,vowColors,plotParams)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

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
        YLim = [-150 175];
        ylab = 'compensation (mels)';
    case 'percproj'
        YLim = [-150 125];
        ylab = 'compensation (%)';
    case 'effproj'
        YLim = [-125 125];
        ylab = 'efficiency (%)';
    case 'centdistdiff'
        YLim = [-150 150];
        ylab = 'norm. distance to center (mels)';
    otherwise
        YLim = [-125 125];
        ylab = toPlot;
end

for p=1:length(phases)
    phase = phases{p};
    for v=1:length(vowels)
        vow = vowels{v};
        dataMeansByCond.adapt = rfx(1).(toPlot).(vow).(phase);
        dataMeansByCond.control = rfx(2).(toPlot).(vow).(phase);
        colorSpec(1,:) = vowColors.(vow);
        colorSpec(2,:) = get_desatcolor(get_darkcolor(vowColors.(vow)));
        h.(phase)(v) = plot_pairedData(dataMeansByCond,colorSpec,plotParams);
        text(1.5,YLim(1)+25,arpabet2ipa(vow,'/'),'HorizontalAlignment','center','FontSize',plotParams.FontSize)
        set(gca,'YLim',YLim)
        set(gca,'XTickLabelRotation',30)
        if v > 1
            set(gca,'YTickLabel','');
        else
            ylabel(ylab)
        end
        hl = hline(0,hlineColor,'--');
        uistack(hl,'bottom');
    end
    
    hPhase(p) = figure;

    xpos = 1000;
    ypos = 1000 - 550*(p-1);
    hPhase(p).Position = [xpos ypos 560 420];

    copy_fig2subplot(h.(phase),hPhase(p),1,4,[],1);
    supertitle(phase)
end



