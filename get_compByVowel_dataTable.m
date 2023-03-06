function [T] = get_compByVowel_dataTable(dataPaths)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

nSubs = length(dataPaths);
conds = {'adapt','null'};
nConds = length(conds);

%% concatenate matrices
fprintf('Adding data from folder');
stab = cell(1,nSubs);
for s=1:nSubs % for each subject
    fprintf(' %d',s);
    ctab = cell(1,nConds);
    for c = 1:nConds % for each session
        cond = conds{c};
        
        % get data
        dataPath = fullfile(dataPaths{s},cond);
        load(fullfile(dataPath,'expt.mat'),'expt');
        compByVowel = get_compByVowel(dataPath,'mid',50,1);
        analyses = fieldnames(compByVowel);
        
        % define trial indices for each phase for averaging
        phaseInds.adaptation = expt.inds.conds.hold(end-39:end); %last 40 hold trials
        phaseInds.washout = expt.inds.conds.washout;
        phaseInds.retention = expt.inds.conds.retention;
        phases = fieldnames(phaseInds);
        nPhases = length(phases);
        
        ptab = cell(1,nPhases);
        for p = 1:nPhases
            phase = phases{p};
            
            vowels = fieldnames(compByVowel.(analyses{1}));
            vtab = cell(1,length(vowels)); % for each shift condition
            for v=1:length(vowels)
                vow = vowels{v};
                [~,inds2add] = intersect(expt.inds.vowels.(vow),phaseInds.(phase));
                
                for a = 1:length(analyses)
                    anl = analyses{a};
                    dat.(anl) = compByVowel.(anl).(vow)(inds2add)';
                end
                
                fact.vow = vow;
                fact.cond = cond;
                fact.phase = phase;
                fact.subj = s;
                
                vtab{v} = get_datatable(dat,fact);
                clear dat;
            end
            
            ptab{p} = vertcat(vtab{:});
        end
        ctab{c} = vertcat(ptab{:});
    end
    stab{s} = vertcat(ctab{:});
end
T = vertcat(stab{:});

%% stats
[~,~,ANOVAstatsProj] = anovan(T.proj,{T.vow T.cond T.phase T.subj},'model','full','random',4,'varnames',T.Properties.VariableNames(end-3:end));
[~,~,ANOVAstatsEff] = anovan(T.effproj,{T.vow T.cond T.phase T.subj},'model','full','random',4,'varnames',T.Properties.VariableNames(end-3:end));

analysis = 'proj';
%analysis = 'effproj';

%t-tests for difference from 0:
[~,p(1),~,stats(1)] = ttest(T.(analysis)(ismember(T.cond,'adapt') & ismember(T.phase,'adaptation')),0);
[~,p(2),~,stats(2)] = ttest(T.(analysis)(ismember(T.cond,'adapt') & ismember(T.phase,'washout')),0);
[~,p(3),~,stats(3)] = ttest(T.(analysis)(ismember(T.cond,'adapt') & ismember(T.phase,'retention')),0); %
[~,p(4),~,stats(4)] = ttest(T.(analysis)(ismember(T.cond,'null') & ismember(T.phase,'adaptation')),0);
[~,p(5),~,stats(5)] = ttest(T.(analysis)(ismember(T.cond,'null') & ismember(T.phase,'washout')),0);
[~,p(6),~,stats(6)] = ttest(T.(analysis)(ismember(T.cond,'null') & ismember(T.phase,'retention')),0);
threshold = 0.05 ./ [6:-1:1];
[pSort,pInd] = sort(p);
% all significant except adapt-retention

%% unpaired t
%t-tests for difference from 0:

analysis = 'proj';
%analysis = 'effproj';

p = []; stats = struct('tstat',{},'df',{},'sd',{});
%1-4
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'adapt') & ismember(T.phase,'adaptation') & ismember(T.vow,'iy')),0);
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'adapt') & ismember(T.phase,'adaptation') & ismember(T.vow,'ae')),0);
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'adapt') & ismember(T.phase,'adaptation') & ismember(T.vow,'uw')),0);
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'adapt') & ismember(T.phase,'adaptation') & ismember(T.vow,'aa')),0);

%5-8
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'null') & ismember(T.phase,'adaptation') & ismember(T.vow,'iy')),0);
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'null') & ismember(T.phase,'adaptation') & ismember(T.vow,'ae')),0);
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'null') & ismember(T.phase,'adaptation') & ismember(T.vow,'uw')),0);
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'null') & ismember(T.phase,'adaptation') & ismember(T.vow,'aa')),0);

%9-12
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'adapt') & ismember(T.phase,'washout') & ismember(T.vow,'iy')),0);
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'adapt') & ismember(T.phase,'washout') & ismember(T.vow,'ae')),0);
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'adapt') & ismember(T.phase,'washout') & ismember(T.vow,'uw')),0);
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'adapt') & ismember(T.phase,'washout') & ismember(T.vow,'aa')),0);

%13-16
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'null') & ismember(T.phase,'washout') & ismember(T.vow,'iy')),0);
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'null') & ismember(T.phase,'washout') & ismember(T.vow,'ae')),0);
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'null') & ismember(T.phase,'washout') & ismember(T.vow,'uw')),0);
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'null') & ismember(T.phase,'washout') & ismember(T.vow,'aa')),0);

%17-20
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'adapt') & ismember(T.phase,'retention') & ismember(T.vow,'iy')),0);
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'adapt') & ismember(T.phase,'retention') & ismember(T.vow,'ae')),0);
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'adapt') & ismember(T.phase,'retention') & ismember(T.vow,'uw')),0);
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'adapt') & ismember(T.phase,'retention') & ismember(T.vow,'aa')),0);

%21-24
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'null') & ismember(T.phase,'retention') & ismember(T.vow,'iy')),0);
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'null') & ismember(T.phase,'retention') & ismember(T.vow,'ae')),0);
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'null') & ismember(T.phase,'retention') & ismember(T.vow,'uw')),0);
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'null') & ismember(T.phase,'retention') & ismember(T.vow,'aa')),0);

threshold = 0.05 ./ [length(p):-1:1];
[pSort,pInd] = sort(p);
bSig = pSort < threshold;
sigInds = sort(pInd(bSig));

%% paired t

analysis = 'proj';
%analysis = 'effproj';

p = []; stats = struct('tstat',{},'df',{},'sd',{});
%1-4
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'adapt') & ismember(T.phase,'adaptation') & ismember(T.vow,'iy')),T.(analysis)(ismember(T.cond,'null') & ismember(T.phase,'adaptation') & ismember(T.vow,'iy')));
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'adapt') & ismember(T.phase,'adaptation') & ismember(T.vow,'ae')),T.(analysis)(ismember(T.cond,'null') & ismember(T.phase,'adaptation') & ismember(T.vow,'ae')));
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'adapt') & ismember(T.phase,'adaptation') & ismember(T.vow,'uw')),T.(analysis)(ismember(T.cond,'null') & ismember(T.phase,'adaptation') & ismember(T.vow,'uw')));
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'adapt') & ismember(T.phase,'adaptation') & ismember(T.vow,'aa')),T.(analysis)(ismember(T.cond,'null') & ismember(T.phase,'adaptation') & ismember(T.vow,'aa')));

%5-8
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'adapt') & ismember(T.phase,'washout') & ismember(T.vow,'iy')),T.(analysis)(ismember(T.cond,'null') & ismember(T.phase,'washout') & ismember(T.vow,'iy')));
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'adapt') & ismember(T.phase,'washout') & ismember(T.vow,'ae')),T.(analysis)(ismember(T.cond,'null') & ismember(T.phase,'washout') & ismember(T.vow,'ae')));
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'adapt') & ismember(T.phase,'washout') & ismember(T.vow,'uw')),T.(analysis)(ismember(T.cond,'null') & ismember(T.phase,'washout') & ismember(T.vow,'uw')));
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'adapt') & ismember(T.phase,'washout') & ismember(T.vow,'aa')),T.(analysis)(ismember(T.cond,'null') & ismember(T.phase,'washout') & ismember(T.vow,'aa')));

%9-12
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'adapt') & ismember(T.phase,'retention') & ismember(T.vow,'iy')),T.(analysis)(ismember(T.cond,'null') & ismember(T.phase,'retention') & ismember(T.vow,'iy')));
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'adapt') & ismember(T.phase,'retention') & ismember(T.vow,'ae')),T.(analysis)(ismember(T.cond,'null') & ismember(T.phase,'retention') & ismember(T.vow,'ae')));
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'adapt') & ismember(T.phase,'retention') & ismember(T.vow,'uw')),T.(analysis)(ismember(T.cond,'null') & ismember(T.phase,'retention') & ismember(T.vow,'uw')));
[~,p(end+1),~,stats(end+1)] = ttest(T.(analysis)(ismember(T.cond,'adapt') & ismember(T.phase,'retention') & ismember(T.vow,'aa')),T.(analysis)(ismember(T.cond,'null') & ismember(T.phase,'retention') & ismember(T.vow,'aa')));

threshold = 0.05 ./ [length(p):-1:1];
[pSort,pInd] = sort(p);
bSig = pSort < threshold;
sigInds = sort(pInd(bSig));

%%
% all significant except adapt-retention



