function [ax] = plot_pertField(ax,pertFieldFile)
%PLOT_PERTFIELD  Plot perturbation field created by calc_pertField.

if isempty(ax)
    figure;
    ax = gca;
else
    axes(ax);
end
load(pertFieldFile,'pertf1','pertf2','xVS','yVS','pertAmp','pertPhi','xPertField','yPertField','vowels','fmtMeans','fCen');
[~,iFCen(1)] = min(abs(pertf1 - fCen(1)));
[~,iFCen(2)] = min(abs(pertf2 - fCen(2)));

fillcolor = [.945 .945 .945];
fill(pertf1(xVS), pertf2(yVS),fillcolor)
arrowcolor = 'r';

hold on
plotInd = 1:10:257;
pertAmp2Plot = pertAmp;
pertAmp2Plot(pertAmp>400) = 0; %for display only
[u,v] = pol2cart(pertPhi,pertAmp2Plot);
quiver(xPertField(plotInd,plotInd),yPertField(plotInd,plotInd),u(plotInd,plotInd),v(plotInd,plotInd),'Color',arrowcolor)
plot(pertf1(iFCen(1)),pertf2(iFCen(2)),'+k')
for v = 1 :length(vowels)
    vow = vowels{v};
    textLoc = fmtMeans.(vow);
    text(textLoc(1),textLoc(2),arpabet2ipa(vow),'FontSize',15)
end

if ~exist('bMel','var')
    bMel = 1;
    warning('Frequency scale not saved in pert field file. Setting axes to mels.')
end
if bMel
    for v = 1:length(vowels)
        vow = vowels{v};
        fmtMeans.(vow) = hz2mels(fmtMeans.(vow));
    end
    
    xlab = 'F1 (mels)';
    ylab = 'F2 (mels)';
else
    xlab = 'F1 (Hz)';
    ylab = 'F2 (Hz)';
end

xlabel(xlab);
ylabel(ylab);
