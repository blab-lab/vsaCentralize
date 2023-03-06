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
for dP = 1:length(dataPaths)
    dataPath = fullfile(dataPaths{dP},'adapt');
    %VSA
    vsTrackFileName = sprintf('vsTrack_%s%d_%s_%s.mat','mid',50,'VSA','hz');
    vsTrackFile = fullfile(dataPath,vsTrackFileName);
    load(vsTrackFile,'vsTrack','binConds');
    vsTracksRaw(1).adapt(dP,:) = vsTrack;
    %AVS
    vsTrackFileName = sprintf('vsTrack_%s%d_%s_%s.mat','mid',50,'AVS','mels');
    vsTrackFile = fullfile(dataPath,vsTrackFileName);
    load(vsTrackFile,'vsTrack','binConds');
    vsTracksRaw(2).adapt(dP,:) = vsTrack;
end
%% generate data table
nSubs = size(vsTracks(1).control,1);

conds = {'adapt','control'};
nConds = length(conds);

phases = {'adapt','washout','retention'};
phaseLocs = [10 11 12];
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
[~,~,ANOVAstats] = anovan(data2analyze{1}.AVS,{data2analyze.cond data2analyze.phase data2analyze.subj},...
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
%% correlations between AVS and VSA and between baseline VSA/AVS and increase in adaptation phase
%calculate correlation between AVS and VSA
% selector = ismember(datatable{1}.phase,'adapt')&ismember(datatable{1}.cond,'adapt');

[r(1),pCorr(1)] = corr(datatable{2}.AVS(selector),datatable{1}.AVS(selector));
[r(2),pCorr(2)] = corr(vsTracksRaw(1).adapt(:,1),vsTracks(1).adapt(:,10));
[r(3),pCorr(3)] = corr(vsTracksRaw(2).adapt(:,1),vsTracks(2).adapt(:,10));
h_corr = figure('Position',[100 100 1200 400]);

subplot(1,3,1)
selector = 1:length(datatable{1}.phase);
scatter(datatable{2}.AVS(selector),datatable{1}.AVS(selector))
lsline
xlabel('VSA');
ylabel('AVS');
title(sprintf('VSA vs. AVS'))
makeFig4Printing

subplot(1,3,2)
scatter(vsTracksRaw(1).adapt(:,1),(vsTracks(1).adapt(:,10)-1)*100)
lsline
xlabel('Baseline VSA (mels^2)');
ylabel('Adaptation (% change)');
title(sprintf('Baseline VSA vs. adaptation'))
makeFig4Printing

subplot(1,3,3)
scatter(vsTracksRaw(2).adapt(:,1),(vsTracks(2).adapt(:,10)-1)*100)
lsline
xlabel('Baseline AVS (mels)');
ylabel('Adaptation (% change)');
title(sprintf('Baseline AVS vs. adaptation'))
makeFig4Printing
