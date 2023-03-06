function [varByVowel, vCen] = get_variabilityByVowel(dataPath,avgtype,avgval,bMels)
%GET_VARIABILITYBYVOWEL  Get per-vowel variability and vowel centers for a single subject.

if nargin < 2 || isempty(avgtype), avgtype = 'mid'; end
if nargin < 3 || isempty(avgval), avgval = 50; end
if nargin < 4 || isempty(bMels), bMels = 1; end

load(fullfile(dataPath,'expt.mat'),'expt');
load(fullfile(dataPath,'dataVals.mat'),'dataVals');

vowels = expt.vowels;

% define trial indices for each phase for averaging
phaseInds.baseline = expt.inds.conds.baseline;    
phaseInds.adaptation = expt.inds.conds.hold(end-39:end); %last 40 hold trials
phaseInds.washout = expt.inds.conds.washout;
phaseInds.retention = expt.inds.conds.retention;
phases = fieldnames(phaseInds);

% for each trial, get single value for F1,F2
fdataByTrial = get_fdataByTrial(dataVals,avgtype,avgval,bMels);

for v = 1:length(vowels)
    %% get difference vectors
    vow = vowels{v};
    vowInds = expt.inds.vowels.(vow);
    for p = 1:length(phases)
        phase = phases{p};
        inds2average = intersect(vowInds,phaseInds.(phase));
        % subtract baseline average per vowel
        meanBaseF1.(vow).(phase) = nanmean(fdataByTrial.f1(inds2average));
        meanBaseF2.(vow).(phase) = nanmean(fdataByTrial.f2(inds2average));   
        vCen.(vow).(phase).f1 = meanBaseF1.(vow).(phase);
        vCen.(vow).(phase).f2 = meanBaseF2.(vow).(phase);
        diff1.(vow).(phase) = fdataByTrial.f1(inds2average) - meanBaseF1.(vow).(phase);
        diff2.(vow).(phase) = fdataByTrial.f2(inds2average) - meanBaseF2.(vow).(phase);

        % calculate 2D formant difference
        diff2d.(vow).(phase) = sqrt(diff1.(vow).(phase).^2 + diff2.(vow).(phase).^2);

        % calculate diff as a fraction of raw formant values
        fracdiff1.(vow).(phase) = diff1.(vow).(phase)./meanBaseF1.(vow).(phase);
        fracdiff2.(vow).(phase) = diff2.(vow).(phase)./meanBaseF2.(vow).(phase);

        % calculate 2D formant fraactional difference 
        fracdiff2d.(vow).(phase) = sqrt(fracdiff1.(vow).(phase).^2 + fracdiff2.(vow).(phase).^2);
    end
        
end

% construct struct
varByVowel.diff1 = diff1; %meanvarByVowel.diff1 = diff1_mean;
varByVowel.diff2 = diff2; %meanvarByVowel.diff2 = diff2_mean;
varByVowel.diff2d = diff2d; %meanvarByVowel.diff2d = diff2d_mean;
varByVowel.fracdiff1 = fracdiff1; %meanvarByVowel.fracdiff1 = fracdiff1_mean;
varByVowel.fracdiff2 = fracdiff2; %meanvarByVowel.fracdiff2 = fracdiff2_mean;
varByVowel.fracdiff2d = fracdiff2d; 


