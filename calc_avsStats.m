%calc_avsStats.m

%% get the data for AVS and VSA
dataPaths = get_dataPaths_vsaAdapt2;

%AVS
[~,vsTracks(1).adapt,~] = plot_vsTrack(dataPaths,'adapt');
[~,vsTracks(1).control,~] = plot_vsTrack(dataPaths,'null');
%VSA
[~,vsTracks(2).adapt,~] = plot_vsTrack(dataPaths,'adapt',[],[],[],'VSA');
[~,vsTracks(2).control,~] = plot_vsTrack(dataPaths,'null',[],[],[],'VSA');

%% get non-normalized data
% only need to run these two lines once:
% plot_vsTrack(dataPaths,'adapt',[],[],[],'VSA',0) 
% plot_vsTrack(dataPaths,'null',[],[],[],'VSA',0)
conds = {'adapt','null'};
condNames = {'adapt','control'};
for dP = 1:length(dataPaths)
    for c = 1:length(conds)
        cond = conds{c};
        condName = condNames{c};
        dataPath = fullfile(dataPaths{dP},cond);
        %VSA
        vsTrackFileName = sprintf('vsTrack_%s%d_%s_%s.mat','mid',50,'VSA','hz');
        vsTrackFile = fullfile(dataPath,vsTrackFileName);
        load(vsTrackFile,'vsTrack','binConds');
        vsTracksRaw(1).(condName)(dP,:) = vsTrack;
        %AVS
        vsTrackFileName = sprintf('vsTrack_%s%d_%s_%s.mat','mid',50,'AVS','mels');
        vsTrackFile = fullfile(dataPath,vsTrackFileName);
        load(vsTrackFile,'vsTrack','binConds');
        vsTracksRaw(2).(condName)(dP,:) = vsTrack;
    end
end
%% generate data table
% nSubs = size(vsTracks(1).control,1);
nSubs = size(vsTracksRaw(1).control,1);

conds = {'adapt','control'};

nConds = length(conds);

phases = {'baseline','adapt','washout','retention'};
phaseLocs = [1 10 11 12];
% phases = {'adapt','washout','retention'};
% phaseLocs = [10 11 12];
nPhases = length(phases);

for m = 1:2
    stab = cell(1,nSubs);
    for s = 1:nSubs
        ctab = cell(1,nConds);
        for c = 1:nConds    
            cond = conds{c};

            ptab = cell(1,nPhases);
            for p = 1:nPhases
                phase = phases{p};

                dat.AVS = vsTracks(m).(cond)(s,phaseLocs(p));
                dat.AVSraw = vsTracksRaw(m).(cond)(s,phaseLocs(p));

                fact.cond = cond;
                fact.phase = phase;
                fact.subj = s;

                ptab{p} = get_datatable(dat,fact);
                clear dat;
            end
            ctab{c} = vertcat(ptab{:});
        end
        stab{s} = vertcat(ctab{:});
    end
    datatable{m} = vertcat(stab{:});
end

%% run stats
data2analyze = datatable{1};
terms2include =    [1 0 0;...
                    0 1 0;...
                    0 0 1;...
                    1 1 0];
[~,~,ANOVAstats] = anovan(data2analyze.AVS,{data2analyze.cond data2analyze.phase data2analyze.subj},...
    'model','interaction',...
    'random',3,...
    'varnames',data2analyze.Properties.VariableNames(end-2:end));

%t-tests for difference from 1:
[~,p(1),~,stats(1)] = ttest(data2analyze.AVS(ismember(data2analyze.cond,'adapt')&...
    ismember(data2analyze.phase,'adapt')),1);
[~,p(2),~,stats(2)] = ttest(data2analyze.AVS(ismember(data2analyze.cond,'adapt')&...
    ismember(data2analyze.phase,'washout')),1);
[~,p(3),~,stats(3)] = ttest(data2analyze.AVS(ismember(data2analyze.cond,'adapt')&...
    ismember(data2analyze.phase,'retention')),1);
[~,p(4),~,stats(4)] = ttest(data2analyze.AVS(ismember(data2analyze.cond,'control')&...
    ismember(data2analyze.phase,'adapt')),1);
[~,p(5),~,stats(5)] = ttest(data2analyze.AVS(ismember(data2analyze.cond,'control')&...
    ismember(data2analyze.phase,'washout')),1);
[~,p(6),~,stats(6)] = ttest(data2analyze.AVS(ismember(data2analyze.cond,'control')&...
    ismember(data2analyze.phase,'retention')),1);

threshold = 0.05 ./ [6:-1:1];

[pSort,pInd] = sort(p);

%means and stds
means(1) = nanmean(data2analyze.AVS(ismember(data2analyze.cond,'adapt')&...
    ismember(data2analyze.phase,'adapt')));
stds(1) = nanstd(data2analyze.AVS(ismember(data2analyze.cond,'adapt')&...
    ismember(data2analyze.phase,'adapt')))./sqrt(nSubs);
means(2) = nanmean(data2analyze.AVS(ismember(data2analyze.cond,'adapt')&...
    ismember(data2analyze.phase,'washout')));
stds(2) = nanstd(data2analyze.AVS(ismember(data2analyze.cond,'adapt')&...
    ismember(data2analyze.phase,'washout')))./sqrt(nSubs);
means(3) = nanmean(data2analyze.AVS(ismember(data2analyze.cond,'adapt')&...
    ismember(data2analyze.phase,'retention')));
stds(3) = nanstd(data2analyze.AVS(ismember(data2analyze.cond,'adapt')&...
    ismember(data2analyze.phase,'retention')))./sqrt(nSubs);
means(4) = nanmean(data2analyze.AVS(ismember(data2analyze.cond,'control')&...
    ismember(data2analyze.phase,'adapt')));
stds(4) = nanstd(data2analyze.AVS(ismember(data2analyze.cond,'control')&...
    ismember(data2analyze.phase,'adapt')))./sqrt(nSubs);
means(5) = nanmean(data2analyze.AVS(ismember(data2analyze.cond,'control')&...
    ismember(data2analyze.phase,'washout')));
stds(5) = nanstd(data2analyze.AVS(ismember(data2analyze.cond,'control')&...
    ismember(data2analyze.phase,'washout')))./sqrt(nSubs);
means(6) = nanmean(data2analyze.AVS(ismember(data2analyze.cond,'control')&...
    ismember(data2analyze.phase,'retention')));
stds(6) = nanstd(data2analyze.AVS(ismember(data2analyze.cond,'control')&...
    ismember(data2analyze.phase,'retention')))./sqrt(nSubs);

%means and stds
means(1) = nanmean(data2analyze.AVSraw(ismember(data2analyze.cond,'adapt')&...
    ismember(data2analyze.phase,'adapt')));
stds(1) = nanstd(data2analyze.AVSraw(ismember(data2analyze.cond,'adapt')&...
    ismember(data2analyze.phase,'adapt')))./sqrt(nSubs);

%% correlations between AVS and VSA and between baseline VSA/AVS and increase in adaptation phase
%calculate correlation between AVS and VSA
selector = ismember(datatable{1}.phase,'adapt')&ismember(datatable{1}.cond,'adapt');

[r(1),pCorr(1)] = corr(datatable{2}.AVS(selector),datatable{1}.AVS(selector));
[r(2),pCorr(2)] = corr(vsTracksRaw(1).adapt(:,1),vsTracks(1).adapt(:,10));
[r(3),pCorr(3)] = corr(vsTracksRaw(2).adapt(:,1),vsTracks(2).adapt(:,10));
h_corr = figure('Units','centimeters','Position',[1 1 17.4 7]);
markerColor = 'r';
subplot(1,3,1)
selector = 1:length(datatable{1}.phase);
scatter(datatable{2}.AVS(selector),datatable{1}.AVS(selector),...
    'MarkerFaceColor',markerColor,'MarkerEdgeColor',markerColor)
lsline
xlabel('VSA');
ylabel('AVS');
title(sprintf('VSA vs. AVS'))
set(gca,'FontSize',16)
makeFig4Printing

subplot(1,3,2)
scatter(vsTracksRaw(1).adapt(:,1),(vsTracks(1).adapt(:,10)-1)*100,...
    'MarkerFaceColor',markerColor,'MarkerEdgeColor',markerColor)
lsline
xlabel('Baseline VSA (mels^2)');
ylabel('Adaptation (% change)');
title(sprintf('Baseline VSA vs. adaptation'))
set(gca,'FontSize',16,'XTickLabels',{'2e5', '3e5', '4e5','5e5','6e5'})
makeFig4Printing

subplot(1,3,3)
scatter(vsTracksRaw(2).adapt(:,1),(vsTracks(2).adapt(:,10)-1)*100,...
    'MarkerFaceColor',markerColor,'MarkerEdgeColor',markerColor)
lsline
xlabel('Baseline AVS (mels)');
ylabel('Adaptation (% change)');
title(sprintf('Baseline AVS vs. adaptation'))
set(gca,'FontSize',16)
makeFig4Printing

%% calculate vowel duration
nSubs = length(dataPaths);
durations.adapt = nan(nSubs,500);
durations.control = nan(nSubs,500);
intensityMax.adapt = nan(nSubs,500);
intensityMax.control = nan(nSubs,500);
intensityMean.adapt = nan(nSubs,500);
intensityMean.control = nan(nSubs,500);
f0Max.adapt = nan(nSubs,500);
f0Max.control = nan(nSubs,500);
f0Mean.adapt = nan(nSubs,500);
f0Mean.control = nan(nSubs,500);
f0Range.adapt= nan(nSubs,500);
f0Range.control = nan(nSubs,500);

condFileNames = {'adapt','null'};
condNames = {'adapt','control'};
nConds = length(condNames);
for dP = 1:length(dataPaths)
    fprintf('processing participant %d\n',dP)
    for c = 1:nConds
        condName = condNames{c};
        fprintf('\tprocessing condition %s\n',condName)
        condFileName = condFileNames{c};
        dataPath = fullfile(dataPaths{dP},condFileName);
        load(fullfile(dataPath,'dataVals.mat'))
        iTri = [dataVals(:).token];
        %add Nans for excluded trials
        bExcl = find([dataVals(:).bExcl]);
        for t = bExcl
            dataVals(t).dur = NaN;
            dataVals(t).int = NaN;
            dataVals(t).f0 = NaN;
        end
        %get durations
        durations.(condName)(dP,iTri) = [dataVals(:).dur];
        %calculate max intensity for each trial
        tempIntMax = [];
        tempIntMean = [];
        for t = 1:length(dataVals)
            tempIntMax(t) = max(dataVals(t).int);
            tempIntMean(t) = nanmean(dataVals(t).int);
            tempf0Max(t)    = max(dataVals(t).f0);
            tempf0Mean(t) = mean(dataVals(t).f0);
            tempf0Range(t) = range(dataVals(t).f0);
        end
        intensityMax.(condName)(dP,iTri) = tempIntMax;
        intensityMean.(condName)(dP,iTri) = tempIntMean;
        f0Max.(condName)(dP,iTri) = tempf0Max;
        f0Mean.(condName)(dP,iTri) = tempf0Mean;
        f0Range.(condName)(dP,iTri) = tempf0Range;
    end
end
fileName = 'supplementaryData.mat';
save(fullfile(get_acoustLoadPath('vsaAdapt2'),fileName),...
    'durations','intensityMax','intensityMean','f0Max','f0Mean','f0Range')

%% stats for supplemenatary analyses
% sData = load(fullfile(get_acoustLoadPath('vsaAdapt2'),fileName));
sTable = [];
sStats = [];
meanDiff = [];
analyses = fieldnames(sData);
baseline = 1:60;
adapt = 381:420;
washout = 421:460;
retention = 461:500;
for i = 1:length(analyses)
    a = analyses{i};
    conds = fieldnames(sData.(a));
    nConds = length(conds);
    for c = 1:nConds
        cond = conds{c};
        baselineMean = nanmean(sData.(a).(cond)(:,baseline),2);
        allData = sData.(a).(cond)-baselineMean;
        adaptMean = nanmean(allData(:,adapt),2);
        washoutMean = nanmean(allData(:,washout),2);
        retentionMean = nanmean(allData(:,retention),2);
        meanDiff.(a).(cond).mean(1) = mean(adaptMean);
        meanDiff.(a).(cond).mean(2) = mean(washoutMean);
        meanDiff.(a).(cond).mean(3) = mean(retentionMean);
        meanDiff.(a).(cond).std(1) = std(adaptMean);
        meanDiff.(a).(cond).std(2) = std(washoutMean);
        meanDiff.(a).(cond).std(3) = std(retentionMean);
        [~,meanDiff.(a).(cond).p(1),~,meanDiff.(a).(cond).stats.adapt] = ttest(adaptMean);
        [~,meanDiff.(a).(cond).p(2),~,meanDiff.(a).(cond).stats.washout] = ttest(washoutMean);
        [~,meanDiff.(a).(cond).p(3),~,meanDiff.(a).(cond).stats.retention] = ttest(retentionMean);
        
        nSubs = size(adaptMean,1);
        subs = 1:nSubs;
        subs = subs';
        
        nPhases = 3;
        t{c} = table(repmat({cond},nPhases*nSubs,1), ...
            [repmat({'adapt'},nSubs,1); repmat({'washout'},nSubs,1); repmat({'retention'},nSubs,1)],...
            repmat(subs,nPhases,1), [adaptMean; washoutMean; retentionMean],...
            'VariableNames',{'cond','phase','subj','value'});
    end
    data2analyze = [t{1};t{2}];
    [~,temp1,temp2] = anovan(data2analyze.value,{data2analyze.cond data2analyze.phase data2analyze.subj},...
        'model','interaction',...
        'random',3,...
        'varnames',data2analyze.Properties.VariableNames(end-3:end-1));
    sTable.(a) = temp1;
    sStats.(a) = temp2;
end
% sTable.f0Max(:,[1 3 6 7]) %look at data this way


%% check for differences in baseline values
%make sure you have baseline raw VSA and AVS values in datatable!!
h = [];
p = [];
stats = [];
means.adapt = [];
stds.adapt = [];
means.control = [];
stds.control = [];
%test all participants
for data2analyze = 1:2
    sel1 = ismember(datatable{data2analyze}.cond,'adapt')&ismember(datatable{data2analyze}.phase,'baseline');
    sel2 = ismember(datatable{data2analyze}.cond,'control')&ismember(datatable{data2analyze}.phase,'baseline');
    [h{data2analyze},p{data2analyze},~,stats{data2analyze}] = ttest(datatable{data2analyze}.AVSraw(sel1),datatable{data2analyze}.AVSraw(sel2));
    means.adapt{data2analyze} = nanmean(datatable{data2analyze}.AVSraw(sel1));
    stds.adapt{data2analyze} = nanstd(datatable{data2analyze}.AVSraw(sel1));
    means.control{data2analyze} = nanmean(datatable{data2analyze}.AVSraw(sel2));
    stds.control{data2analyze} = nanstd(datatable{data2analyze}.AVSraw(sel2));
end

%test people who had adapt session first
sorder = [47 79 81 87 97 ...
121 176 183 184 185 ...
186 188 191 194 195 ...
196 197 201 202 204 ...
208 209 210 211 216];

adaptFirst = [47, 176, 183, 184, 185, 186, 188, 191, 194, 195, 196, 197];

[~,iAF] = intersect(sorder,adaptFirst);
for data2analyze = 1:2
    sel1 = ismember(datatable{data2analyze}.cond,'adapt')&ismember(datatable{data2analyze}.phase,'baseline')&ismember(datatable{data2analyze}.subj,iAF);
    sel2 = ismember(datatable{data2analyze}.cond,'control')&ismember(datatable{data2analyze}.phase,'baseline')&ismember(datatable{data2analyze}.subj,iAF);
    [h{data2analyze+2},p{data2analyze+2},~,stats{data2analyze+2}] = ttest(datatable{data2analyze}.AVSraw(sel1),datatable{data2analyze}.AVSraw(sel2));
    means.adapt{data2analyze+2} = nanmean(datatable{data2analyze}.AVSraw(sel1));
    stds.adapt{data2analyze+2} = nanstd(datatable{data2analyze}.AVSraw(sel1));
    means.control{data2analyze+2} = nanmean(datatable{data2analyze}.AVSraw(sel2));
    stds.control{data2analyze+2} = nanstd(datatable{data2analyze}.AVSraw(sel2));
end

%test people who had control session first
[~,iCF] = setxor(sorder,adaptFirst);
for data2analyze = 1:2
    sel1 = ismember(datatable{data2analyze}.cond,'adapt')&ismember(datatable{data2analyze}.phase,'baseline')&ismember(datatable{data2analyze}.subj,iCF);
    sel2 = ismember(datatable{data2analyze}.cond,'control')&ismember(datatable{data2analyze}.phase,'baseline')&ismember(datatable{data2analyze}.subj,iCF);
    [h{data2analyze+4},p{data2analyze+4},~,stats{data2analyze+4}] = ttest(datatable{data2analyze}.AVSraw(sel1),datatable{data2analyze}.AVSraw(sel2));
    means.adapt{data2analyze+4} = nanmean(datatable{data2analyze}.AVSraw(sel1));
    stds.adapt{data2analyze+4} = nanstd(datatable{data2analyze}.AVSraw(sel1));
    means.control{data2analyze+4} = nanmean(datatable{data2analyze}.AVSraw(sel2));
    stds.control{data2analyze+4} = nanstd(datatable{data2analyze}.AVSraw(sel2));
end

%compare groups
firstSession = repmat({'AF'},length(datatable{1}.cond),1);
firstSession(ismember(datatable{data2analyze}.subj,iCF),1) = repmat({'CF'},length(find(ismember(datatable{data2analyze}.subj,iCF))),1);
if ~any(ismember(datatable{2}.Properties.VariableNames,'firstSession'))
    for i = 1:2
        datatable{i} = [datatable{i} firstSession];
        datatable{i}.Properties.VariableNames{5} = 'firstSession';
    end
end

%t-test comparison
hAF0 = [];
hCF0 = [];
hAFCF = [];
pAF0 = [];
pCF0 = [];
pAFCF = [];
statsAF0 = [];
statsCF0 = [];
statsAFCF = [];

deltaAVS = [];
for i = 1:2
    baselineOnly{i} = datatable{i}(ismember(datatable{1}.phase,'baseline'),:);
    data2analyze = baselineOnly{i};
    sel1AF = ismember(data2analyze.cond,'adapt')&ismember(data2analyze.firstSession,'AF');
    sel2AF= ismember(data2analyze.cond,'control')&ismember(data2analyze.firstSession,'AF');
    sel1CF = ismember(data2analyze.cond,'control')&ismember(data2analyze.firstSession,'CF');
    sel2CF= ismember(data2analyze.cond,'adapt')&ismember(data2analyze.firstSession,'CF');
    
    deltaAVS{i}.AF = data2analyze.AVSraw(sel1AF) - data2analyze.AVSraw(sel2AF);
    deltaAVS{i}.CF = data2analyze.AVSraw(sel1CF) - data2analyze.AVSraw(sel2CF);
    [hAF0{i},pAF0{i},~,statsAF0{i}] = ttest(deltaAVS{i}.AF);
    [hCF0{i},pCF0{i},~,statsCF0{i}] = ttest(deltaAVS{i}.CF);
    [hAFCF{i},pAFCF{i},~,statsAFCF{i}] = ttest2(deltaAVS{i}.AF,deltaAVS{i}.CF);
end


%global analysis
ANOVAstats= [];
ANOVAtable= [];
for i = 1:2
    baselineOnly{i} = datatable{i}(ismember(datatable{1}.phase,'baseline'),:);
    data2analyze = baselineOnly{i};
    data2analyze.subj = categorical(data2analyze.subj);
    [~,ANOVAtable{i},ANOVAstats{i}] = anovan(data2analyze.AVSraw,{data2analyze.cond data2analyze.firstSession},... %need to sort out why including subj as a random factor yields all NaNs. potentially not enough replications per subject.
        'model','interaction',...
        'varnames',{'condition','firstSession'});
end

%% check for differences in variability between vowels
%create table
load(fullfile(get_acoustLoadPath('vsaAdapt2'),'variabilityByVowel.mat'),'rfx','ffx')
sessions = fieldnames(rfx);
sjtab= [];
ptab= [];
vtab= [];
atab= [];
stab= [];
for s = 1:length(sessions)
    session = sessions{s};
    analyses = fieldnames(rfx.(session));
    for a = 1:length(analyses)
        analysis = analyses{a};
        vowels = fieldnames(rfx.(session).(analysis));
        for v = 1:length(vowels)
            vow = vowels{v};
            phases = fieldnames(rfx.(session).(analysis).(vow));
            for p = 1:length(phases)
                phase = phases{p};
                for sj = 1:length(rfx.(session).(analysis).(vow).(phase))
                    phase = phases{p};
                    dat.var = rfx.(session).(analysis).(vow).(phase)(sj);

                    fact.cond = session;
                    fact.analysis = analysis;
                    fact.vowel = vow;
                    fact.phase = phase;
                    fact.subj = sj;

                    sjtab{sj} = get_datatable(dat,fact);
                    clear dat;
                end
                ptab{p} = vertcat(sjtab{:});    
            end
            vtab{v} = vertcat(ptab{:});    
        end 
        atab{a} = vertcat(vtab{:});
    end
    stab{s} = vertcat(atab{:});
end

%add in how much each participant adapted by vowel

datatable = vertcat(stab{:});



datatable.subj = categorical(datatable.subj);
%stats analysis
analysis = 'diff1';
session = 'adapt';
data2analyze = datatable(ismember(datatable.analysis,analysis)&ismember(datatable.cond,session),:);
% [~,sTable,sStats] = anovan(data2analyze.var,{data2analyze.phase data2analyze.vowel data2analyze.subj},...
%         'model','interaction',...
%         'random',3,...
%         'varnames',data2analyze.Properties.VariableNames([3 6 4]));
data2analyze = datatable(ismember(datatable.analysis,analysis),:);

[~,sTable,sStats] = anovan(data2analyze.var,{data2analyze.cond data2analyze.phase data2analyze.vowel data2analyze.subj},...
        'model','interaction',...
        'random',4);
        
%% correlate variability and learning for each vowel
load(fullfile(get_acoustLoadPath('vsaAdapt2'),'variabilityByVowel.mat'),'rfx')
rfx_var = rfx;
load(fullfile(get_acoustLoadPath('vsaAdapt2'),'fx.mat'),'rfx');
rfx_adapt = rfx;
clear rfx;

vowels = fieldnames(rfx_var.adapt.diff2d);
nVowels = length(vowels);
figure
for i = 1:nVowels
    subplot(2,2,i)
    vow = vowels{i};
    plotcorr(rfx_var.adapt.diff2d.(vow).baseline,rfx_adapt.adapt.centdistdiff.(vow).adaptation)
    title(vow)
end
figure
for i = 1:nVowels
    subplot(2,2,i)
    vow = vowels{i};
    baseDist = rfx_adapt.adapt.centdist.(vow).adaptation-rfx_adapt.adapt.centdistdiff.(vow).adaptation;
    plotcorr(baseDist,rfx_adapt.adapt.centdistdiff.(vow).adaptation)
    title(vow)
end



