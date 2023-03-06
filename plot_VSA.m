function [h] = plot_VSA(fdataByVowel,colors,p)
%PLOT_VSA  Plot vowel space area given formant data split by vowel.
%   [h] = plot_VSA(fdataByVowel)

if nargin < 3, p = struct; end

if ~isfield(p,'MarkerSize')
    p.MarkerSize = 10;
end
p.MarkerFaceAlpha = .3;
p.bScatter = 0;
p.bEllipse = 1;
p.ellipseAlpha = .5;
p.linestyles = {'.--' '.-' '.--' '.-'};
if ~isfield(p,'bLegend')
    p.bLegend = 1;
end

conds = fieldnames(fdataByVowel);

if nargin < 2 || isempty(colors), colors = get_colors(length(conds)); end

if isstruct(colors)
    colorStruct = colors;
else
    colorStruct = get_colorStruct(conds,colors);
end

h = figure;
hold on;

leg = zeros(1,length(conds));

for c = 1:length(conds)
    cond = conds{c};
    %        F1 = fdataByVowel.(cond).f1;
    %        F2 = fdataByVowel.(cond).f2;
    for s = 1:length(fdataByVowel)
        vowels = fieldnames(fdataByVowel(s).(cond).f1);
        for v = 1:length(vowels)
            vow = vowels{v};
            F1.(vow)(s) = nanmean(fdataByVowel(s).(cond).f1.(vow));
            F2.(vow)(s) = nanmean(fdataByVowel(s).(cond).f2.(vow));
        end
    end
    
    % plot scatter
    if p.bScatter && length(fdataByVowel) > 1
        for v = 1:length(vowels)
            vow = vowels{v};
            scatter(F1.(vow),F2.(vow),p.MarkerSize,'MarkerFaceColor',colorStruct.(cond),'MarkerFaceAlpha',p.MarkerFaceAlpha,'MarkerEdgeColor','none');
        end
    end
    
    % plot ellipse
    if p.bEllipse && length(fdataByVowel) > 1
        for v = 1:length(vowels)
            vow = vowels{v};
            rectangle('Position',[nanmean(F1.(vow))-nanste(F1.(vow)) nanmean(F2.(vow))-nanste(F2.(vow)) nanste(F1.(vow))*2 nanste(F2.(vow))*2],...
                'Curvature',[1 1],'FaceColor',[get_lightcolor(colorStruct.(cond)) p.ellipseAlpha],'EdgeColor','none');
        end
    end
    
    % plot vowel averages and connecting line
    leg(c) = plot([nanmean(F1.iy) nanmean(F1.ae) nanmean(F1.aa) nanmean(F1.uw) nanmean(F1.iy)], ...
        [nanmean(F2.iy) nanmean(F2.ae) nanmean(F2.aa) nanmean(F2.uw) nanmean(F2.iy)], ...
        p.linestyles{c},'MarkerSize',p.MarkerSize,'Color',colorStruct.(cond));
    hold on;
    
end

if p.bLegend
    legend(leg,conds,'AutoUpdate','off')
end
xlabel('F1')
ylabel('F2')
axis square;
makeFig4Screen;
