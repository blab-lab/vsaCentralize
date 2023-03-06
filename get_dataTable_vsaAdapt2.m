function [T,Tmean] = get_dataTable_vsaAdapt2(session)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if nargin < 1, session = 'adapt'; end

dataPaths = get_dataPaths_vsaAdapt2(session);
nsubj = length(dataPaths);

stab = cell(1,nsubj);
stab_mean = cell(1,nsubj);
for s = 1:nsubj % get subject data
    dataPath = dataPaths{s};
    load(fullfile(dataPath,'expt.mat'),'expt');
    compByVowel = get_compByVowel(dataPath,'mid',50,1);
    
    analyses = fieldnames(compByVowel);
    nanl = length(analyses);
    
    vowels = fieldnames(compByVowel.(analyses{1}));
    nvowels = length(vowels);
    
    vtab = cell(1,nvowels);
    vtab_mean = cell(1,nvowels);
    for v = 1:nvowels % get vowel data
        vow = vowels{v};
        
        %% trialwise
        % set measures
        for a = 1:nanl
            anl = analyses{a};            
            if isfield(compByVowel.(anl),vow)
                dat.(anl) = compByVowel.(anl).(vow)';
            end
        end
            
        % set factors
        fact.subj = s;
        fact.vowel = vow;
        fact.phase = expt.listConds(expt.inds.vowels.(vow));
        
        vtab{v} = get_datatable(dat,fact);
        clear dat;
        
        %% mean by phase
        [phases,ia] = unique(vtab{v}.phase);
        [~,is] = sort(ia);
        phases = phases(is);
        nphases = length(phases);
        ptab_mean = cell(1,nphases);
        for p = 1:nphases
            phs = phases(p);
            bPhs = ismember(vtab{v}.phase,phs);
            
            if strcmp(phs,'hold')               % hold --> adaptation:
                fPhs = find(bPhs);              % find hold trials
                bAdapt = fPhs(end-9:end);       % use last 10
                phasetab = vtab{v}(bAdapt,:);
                phs = 'adaptation';             % rename phase
            else
                phasetab = vtab{v}(bPhs,:);     % for other phases, use as-is
            end
            
            % set measures
            for a = 1:nanl
                anl = analyses{a};
                dat.(anl) = nanmean(phasetab.(anl));
            end
            
            % set factors
            fact.phase = phs;
            
            ptab_mean{p} = get_datatable(dat,fact);
        end
        
        vtab_mean{v} = vertcat(ptab_mean{:});
        clear dat;
        
    end
    stab{s} = vertcat(vtab{:}); % concatenate all vowels
    stab_mean{s} = vertcat(vtab_mean{:}); % concatenate all vowels
end
T = vertcat(stab{:}); % concatenate all subjects
Tmean = vertcat(stab_mean{:}); % concatenate all subjects

end
