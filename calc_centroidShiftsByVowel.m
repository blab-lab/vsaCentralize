function [shifts,fCen] = calc_centroidShiftsByVowel(dataPath,bMels)
%CALC_CENTROIDSHIFTSBYVOWEL  Get mean centroid shift vector per vowel.
%   SHIFTS = CALC_CENTROIDSHIFTSBYVOWEL(DATAPATH,BMELS)

if nargin < 1, bMels = 1; end

load(fullfile(dataPath,'expt.mat'),'expt');
vowels = expt.vowels;
maxScaleFact = max(expt.shiftScaleFact);

fmtMeans = calc_vowelMeans(fullfile(dataPath,'pre')); % get means from pre
fCen = calc_vowelCentroid(fmtMeans); % get centroid

if bMels % convert to mels
    fCen = hz2mels(fCen);
    for v = 1:length(vowels)
        vow = vowels{v};
        fmtMeans.(vow) = hz2mels(fmtMeans.(vow));
    end
    units = 'mels';
else
    units = 'hz';
end

% calculate difference vector
shifts.(units) = cell(1,length(vowels));
for v = 1:length(vowels)
    vow = vowels{v};
    shifts.(units){v} = maxScaleFact*[fCen(1)-fmtMeans.(vow)(1) fCen(2)-fmtMeans.(vow)(2)];
end
