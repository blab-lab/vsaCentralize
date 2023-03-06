%% vsaAdapt2 stats: per-trial compensation by vowel
%% setup

% set factors
vowels = {'iy' 'ae' 'aa' 'uw'};
phases = {'adaptation' 'washout' 'retention'};
conds = {'adapt' 'null'};

% load data
if ~exist('T_adapt','var')
    dP = get_acoustLocalPath('vsaAdapt2');
    load(fullfile(dP,'table_compByTrial.mat'));
end
T_adapt.cond(:) = {'adapt'};
T_null.cond(:) = {'null'};
Tmean_adapt.cond(:) = {'adapt'};
Tmean_null.cond(:) = {'null'};

% concatenate tables
T = vertcat(Tmean_adapt, Tmean_null);
T = T(~ismember(T.phase,'baseline'),:); % remove baseline phase
T = T(~ismember(T.phase,'ramp'),:);     % remove ramp phase

analysis = 'centdistdiff';  % dependent measure
pmin = 0.0001;              % min p-value for display
%% ANOVA

[~,~,ANOVAstats] = anovan(T.(analysis),{T.subj T.vowel T.phase T.cond},...
    'model','full',...
    'random',1,...
    'varnames',T.Properties.VariableNames(end-3:end));
[~,~,ANOVAstats] = anovan(T.(analysis),{T.subj T.vowel T.phase T.cond},...
    'model','interaction',...
    'random',1,...
    'varnames',T.Properties.VariableNames(end-3:end));
%% Post-hoc t-tests: cross-vowel
% One-sample t-tests for difference from 0:

% t-tests
p = []; stats = struct('tstat',{},'df',{},'sd',{}); testnames = {};
for c = 1:length(conds)
    cnd = conds{c};
    for ph = 1:length(phases)
        phs = phases{ph};
        [~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,cnd) & ismember(T.phase,phs)),0);
        testnames{end+1} = sprintf('%s:%s',cnd,phs);
    end
end

% significance (Holm-Bonferroni correction)
threshold = 0.05 ./ (length(p):-1:1);
[pSort,pInd] = sort(p);
bSig = pSort < threshold;
for i = 1:length(p)
    if bSig(pInd(i))
        fprintf('<strong>%s, %s</strong>\n',testnames{i},sprint_tstat(p(i),stats(i),pmin));
    else
        fprintf('%s, %s\n',testnames{i},sprint_tstat(p(i),stats(i),pmin));
    end
end
% Paired t-tests for difference between sessions:

% t-tests
p = []; stats = struct('tstat',{},'df',{},'sd',{}); testnames = {};
for ph = 1:length(phases)
    phs = phases{ph};
    [~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'adapt') & ismember(T.phase,phs)),T.(analysis)(ismember(T.cond,'null') & ismember(T.phase,phs)));
    testnames{end+1} = sprintf('%s',phs);
end

% significance (Holm-Bonferroni correction)
threshold = 0.05 ./ (length(p):-1:1);
[pSort,pInd] = sort(p);
bSig = pSort < threshold;
for i = 1:length(p)
    if bSig(pInd(i))
        fprintf('<strong>%s, %s</strong>\n',testnames{i},sprint_tstat(p(i),stats(i),pmin));
    else
        fprintf('%s, %s\n',testnames{i},sprint_tstat(p(i),stats(i),pmin));
    end
end
%% Post-hoc t-tests: individual vowels
% One-sample t-tests for difference from 0:

% t-tests
p = []; stats = struct('tstat',{},'df',{},'sd',{}); testnames = {};
for ph = 1:length(phases)
    phs = phases{ph};
    for c = 1:length(conds)
        cnd = conds{c};
        for v = 1:length(vowels)
            vow = vowels{v};
            [~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,cnd) & ismember(T.phase,phs) & ismember(T.vowel,vow)),0);
            testnames{end+1} = sprintf('%s:%s:%s',cnd,phs,vow);
        end
    end
end

% significance (Holm-Bonferroni correction)
threshold = 0.05 ./ (length(p):-1:1);
[pSort,pInd] = sort(p);
bSig = pSort < threshold;
for i = 1:length(p)
    if ismember(i,pInd(bSig))
        fprintf('<strong>%s, %s</strong>\n',testnames{i},sprint_tstat(p(i),stats(i),pmin));
    else
        fprintf('%s, %s\n',testnames{i},sprint_tstat(p(i),stats(i),pmin));
    end
end
% Paired t-tests for difference between sessions:

% t-tests
p = []; stats = struct('tstat',{},'df',{},'sd',{}); testnames = {};
for ph = 1:length(phases)
    phs = phases{ph};
    for v = 1:length(vowels)
        vow = vowels{v};
        [~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'adapt') & ismember(T.phase,phs) & ismember(T.vowel,vow)),...
                                            T.(analysis)(ismember(T.cond,'null') & ismember(T.phase,phs) & ismember(T.vowel,vow)),'Tail','right');
        testnames{end+1} = sprintf('%s:%s',phs,vow);
    end
end

% significance (Holm-Bonferroni correction)
threshold = 0.05 ./ (length(p):-1:1);
[pSort,pInd] = sort(p);
bSig = pSort < threshold;
for i = 1:length(p)
    if ismember(i,pInd(bSig))
        fprintf('<strong>%s, %s</strong>\n',testnames{i},sprint_tstat(p(i),stats(i),pmin));
    else
        fprintf('%s, %s\n',testnames{i},sprint_tstat(p(i),stats(i),pmin));
    end
end