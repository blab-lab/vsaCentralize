function [compByVowel] = get_compByVowel(dataPath,avgtype,avgval,bMels)
%GET_COMPBYVOWEL  Get per-vowel compensation for a single subject.
%   [compByVowel] = get_compByVowel(dataPath,avgtype,avgval,bMels)

if nargin < 2 || isempty(avgtype), avgtype = 'mid'; end
if nargin < 3 || isempty(avgval), avgval = 50; end
if nargin < 4 || isempty(bMels), bMels = 1; end

load(fullfile(dataPath,'expt.mat'),'expt');
load(fullfile(dataPath,'dataVals.mat'),'dataVals');

vowels = expt.vowels;
baseInds = expt.inds.conds.baseline;

subjFolder = fileparts(dataPath);
[expt.shifts,fCen] = calc_centroidShiftsByVowel(fullfile(subjFolder,'adapt'),bMels);

% for each trial, get single value for F1,F2
fdataByTrial = get_fdataByTrial(dataVals,avgtype,avgval,bMels);

for v = 1:length(vowels)
    %% get difference vectors
    vow = vowels{v};
    vowInds = expt.inds.vowels.(vow);
    baseVowInds = intersect(baseInds,vowInds);

    % subtract baseline average per vowel
    meanBaseF1.(vow) = nanmean(fdataByTrial.f1(baseVowInds));
    meanBaseF2.(vow) = nanmean(fdataByTrial.f2(baseVowInds));    
    diff1.(vow) = fdataByTrial.f1(vowInds) - meanBaseF1.(vow);
    diff2.(vow) = fdataByTrial.f2(vowInds) - meanBaseF2.(vow);
    diff1_mean.(vow) = nanmean(diff1.(vow));
    diff2_mean.(vow) = nanmean(diff2.(vow));

    % calculate 2D formant difference
    diff2d.(vow) = sqrt(diff1.(vow).^2 + diff2.(vow).^2);
    diff2d_mean.(vow) = sqrt(diff1_mean.(vow).^2 + diff2_mean.(vow).^2);
    
    % calculate diff as a fraction of raw formant values
    fracdiff1.(vow) = diff1.(vow)./meanBaseF1.(vow);
    fracdiff2.(vow) = diff2.(vow)./meanBaseF2.(vow);
    fracdiff1_mean.(vow) = nanmean(fracdiff1.(vow));
    fracdiff2_mean.(vow) = nanmean(fracdiff2.(vow));
    
    %% get distance to centroid
    meanBaseCentDist.(vow) = nanmean(sqrt((fdataByTrial.f1(baseVowInds)-fCen(1)).^2 + (fdataByTrial.f2(baseVowInds)-fCen(2)).^2));
    centdist.(vow) = sqrt((fdataByTrial.f1(vowInds)-fCen(1)).^2 + (fdataByTrial.f2(vowInds)-fCen(2)).^2);
    centdistdiff.(vow) = centdist.(vow) - meanBaseCentDist.(vow);
    normcentdist.(vow) = centdist.(vow)/meanBaseCentDist.(vow);
    
    %% if a perturbation study: calculate shift percentages and projections
    if isfield(expt,'shifts')
        % get vowel-specific shift vector
        if bMels
            if isfield(expt.shifts,'mels')
                shiftvec = expt.shifts.mels{v};
            else
                shiftvec_hz = expt.shifts.mels{v};
                meanprod_mels = [meanBaseF1.(vow) meanBaseF2.(vow)];
                meanprod_hz = mels2hz(meanprod_mels);
                shiftedprod_hz = meanprod_hz + shiftvec_hz;
                shiftedprod_mels = hz2mels(shiftedprod_hz);
                shiftvec = shiftedprod_mels - meanprod_mels;
            end
        else
            shiftvec = expt.shifts.hz{v};
        end
        magShift = sqrt(shiftvec(1)^2 + shiftvec(2)^2);
        
        % calculate diff as a percentage of shift
        percdiff1.(vow) = diff1.(vow).*(100/shiftvec(1));
        percdiff1_mean.(vow) = diff1_mean.(vow).*(100/shiftvec(1));
        percdiff2.(vow) = diff2.(vow).*(100/shiftvec(2));
        percdiff2_mean.(vow) = diff2_mean.(vow).*(100/shiftvec(2));
        percdiff2d.(vow) = diff2d.(vow).*(100/magShift);
        percdiff2d_mean.(vow) = diff2d_mean.(vow).*(100/magShift);

        % calculate dot products (projection and efficiency)
        for itrial = 1:length(diff1.(vow)) % for each trial
            proj.(vow)(itrial) = dot([diff1.(vow)(itrial) diff2.(vow)(itrial)],-shiftvec)/magShift;
        end
        proj_mean.(vow) = dot([diff1_mean.(vow) diff2_mean.(vow)],-shiftvec)/magShift;
        effproj.(vow) = proj.(vow).*(100./diff2d.(vow));
        effproj_mean.(vow) = proj_mean.(vow).*(100./diff2d_mean.(vow));
        effdist.(vow) = diff2d.(vow) - proj.(vow);
        effdist_mean.(vow) = diff2d_mean.(vow) - proj_mean.(vow);
        percproj.(vow) = proj.(vow).*(100/magShift);
        percproj_mean.(vow) = proj_mean.(vow).*(100/magShift);

    end
end

% construct struct
compByVowel.diff1 = diff1; %meanCompByVowel.diff1 = diff1_mean;
compByVowel.diff2 = diff2; %meanCompByVowel.diff2 = diff2_mean;
compByVowel.diff2d = diff2d; %meanCompByVowel.diff2d = diff2d_mean;
compByVowel.fracdiff1 = fracdiff1; %meanCompByVowel.fracdiff1 = fracdiff1_mean;
compByVowel.fracdiff2 = fracdiff2; %meanCompByVowel.fracdiff2 = fracdiff2_mean;
compByVowel.centdist = centdist;
compByVowel.centdistdiff = centdistdiff;
compByVowel.normcentdist = normcentdist;
if isfield(expt,'shifts')
    compByVowel.percdiff1 = percdiff1; %meanCompByVowel.percdiff1 = percdiff1_mean;
    compByVowel.percdiff2 = percdiff2; %meanCompByVowel.percdiff2 = percdiff2_mean;
    compByVowel.percdiff2d = percdiff2d; %meanCompByVowel.percdiff2d = percdiff2d_mean;
    compByVowel.proj = proj; %meanCompByVowel.proj = proj_mean;
    compByVowel.percproj = percproj; %meanCompByVowel.percproj = percproj_mean;
    compByVowel.effproj = effproj; %meanCompByVowel.effproj = effproj_mean;
    compByVowel.effdist = effdist; %meanCompByVowel.effdist = effdist_mean;
end
