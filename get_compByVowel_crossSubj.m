function [ffx,rfx] = get_compByVowel_crossSubj(dataPaths)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

ffx = []; rfx = [];

%% concatenate matrices
fprintf('Adding data from folder');
for dP=1:length(dataPaths) % for each subject
    % get data
    dataPath = dataPaths{dP};
    load(fullfile(dataPath,'expt.mat'),'expt');
    compByVowel = get_compByVowel(dataPath,'mid',50,1);    
    analyses = fieldnames(compByVowel);
    
    % define trial indices for each phase for averaging
    phaseInds.adaptation = expt.inds.conds.hold(end-39:end); %last 40 hold trials
    phaseInds.washout = expt.inds.conds.washout;
    phaseInds.retention = expt.inds.conds.retention;
    phases = fieldnames(phaseInds);
    
    fprintf(' %d',dP);
    for a=1:length(analyses) % for each type of track (diff1, etc.)
        anl = analyses{a};
        vowels = fieldnames(compByVowel.(anl));
        for v=1:length(vowels) % for each shift condition
            vow = vowels{v};

            % concat all trials (fixed effects)
            if ~isfield(ffx,anl) || ~isfield(ffx.(anl),vow)
                ffx.(anl).(vow) = compByVowel.(anl).(vow);
            else
                track = compByVowel.(anl).(vow);
                ffx.(anl).(vow) = nancat(ffx.(anl).(vow),track);
            end
            
            % concat only means (random effects)
            for p = 1:length(phases)
                phase = phases{p};
                [~,inds2average] = intersect(expt.inds.vowels.(vow),phaseInds.(phase));
                if ~isfield(rfx,anl) || ~isfield(rfx.(anl),vow) || ~isfield(rfx.(anl).(vow),phase)
                    rfx.(anl).(vow).(phase) = nanmean(compByVowel.(anl).(vow)(inds2average));
                else
                    rfx.(anl).(vow).(phase)(end+1) = nanmean(compByVowel.(anl).(vow)(inds2average));
                end
            end
            
        end
    end
end
