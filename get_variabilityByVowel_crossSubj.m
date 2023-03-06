function [ffx,rfx] = get_variabilityByVowel_crossSubj(dataPaths)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

ffx = []; rfx = [];

sessions = {'adapt','null'};

%% concatenate matrices
fprintf('Adding data from folder');
for dP=1:length(dataPaths) % for each subject
    % get data
    for s = 1:length(sessions)
        session = sessions{s};
        dataPath = fullfile(dataPaths{dP},session);
        load(fullfile(dataPath,'expt.mat'),'expt');
        [varByVowel,vCen] = get_variabilityByVowel(dataPath,'mid',50,1);    
        analyses = fieldnames(varByVowel);

        % define trial indices for each phase for averaging
        phaseInds.baseline = expt.inds.conds.baseline;
        phaseInds.adaptation = expt.inds.conds.hold(end-39:end); %last 40 hold trials
        phaseInds.washout = expt.inds.conds.washout;
        phaseInds.retention = expt.inds.conds.retention;
        phases = fieldnames(phaseInds);

        fprintf(' %d',dP);
        % concat vowel center locations
        anl = fieldnames(varByVowel);
        vowels = fieldnames(varByVowel.(anl{1}));
        for v=1:length(vowels) % for each shift condition
            vow = vowels{v};
            for p = 1:length(phases)
                phase = phases{p};
                if ~isfield(ffx,vow)
                    ffx.(session).(vow).(phase).f1 = vCen.(vow).(phase).f1;
                    ffx.(session).(vow).(phase).f2 = vCen.(vow).(phase).f2;
                else
                    track = vCen.(vow).f1;
                    ffx.(session).(vow).(phase).f1 = nancat(ffx.(vow).(phase).f1,track);
                    track = vCen.(vow).f2;
                    ffx.(session).(vow).(phase).f2 = nancat(ffx.(vow).(phase).f2,track);
                end
            end
        end

        %concat variability measurements
        for a=1:length(analyses) % for each type of track (diff1, etc.)
            anl = analyses{a};
            vowels = fieldnames(varByVowel.(anl));
            for v=1:length(vowels) % for each shift condition
                vow = vowels{v};

                for p = 1:length(phases)
                    phase = phases{p};
                    if strcmp(anl,'diff2d') || strcmp(anl,'fracdiff2d')
                        track = nanmean(varByVowel.(anl).(vow).(phase));
                    else
                        track = nanstd(varByVowel.(anl).(vow).(phase));
                    end
                    if ~isfield(rfx,session) || ~isfield(rfx.(session),anl) || ~isfield(rfx.(session).(anl),vow) || ~isfield(rfx.(session).(anl).(vow),phase)
                        rfx.(session).(anl).(vow).(phase) = track;
                    else
                        rfx.(session).(anl).(vow).(phase)(end+1) = track;
                    end
                end

            end
        end
    end
end

baseDir = fileparts(dataPaths{1});
save(fullfile(baseDir,'variabilityByVowel.mat'),'ffx','rfx')