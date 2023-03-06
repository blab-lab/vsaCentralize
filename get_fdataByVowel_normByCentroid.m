function [fdataByVowel] = get_fdataByVowel_normByCentroid(dataPath,trials,avgtype,avgval,bMels,toTrack)
%GET_FDATABYVOWEL  Get data for all trials of each vowel.
%   [fdataByVowel] = get_fdataByVowel(dataPath,trials) loads data from
%   DATAPATH, averages within a window in each trial, and returns each
%   trial's data separated by vowel. The optional argument TRIALS specifies
%   a subset of trials to use, rather than all trials, and can be a vector
%   of trial numbers or a character array specifying a condition name.

if nargin < 2, trials = []; end
if nargin < 3 || isempty(avgtype), avgtype = 'mid'; end
if nargin < 4 || isempty(avgval), avgval = 50; end
if nargin < 5 || isempty(bMels), bMels = 1; end
if nargin < 6 || isempty(toTrack), toTrack = {'f1' 'f2'}; end

load(fullfile(dataPath,'expt'),'expt')
load(fullfile(dataPath,'dataVals'),'dataVals')

fmtMeans = calc_vowelMeans(fullfile(dataPath,'pre')); % get means from pre
fCen = calc_vowelCentroid(fmtMeans); % get centroid
if bMels
    fCen = hz2mels(fCen);
end

% get data by trial and normalize by centroid
fdataByTrial = get_fdataByTrial(dataVals,avgtype,avgval,bMels,toTrack);
fdataByTrial.f1 = fdataByTrial.f1-fCen(1);
fdataByTrial.f2 = fdataByTrial.f2-fCen(2);

% split by vowel (and trial/condition)
vowels = expt.vowels;
for v = 1:length(vowels)
    vow = vowels{v};
    vowInds = expt.inds.vowels.(vow);
    if trials
        if ischar(trials) % if the name of a condition, get trialinds
            trials = expt.inds.conds.(trials);
        end               % otherwise use given trials
        vowInds = intersect(vowInds,trials);
    end
    fdataByVowel.f1.(vow) = fdataByTrial.f1(vowInds);
    fdataByVowel.f2.(vow) = fdataByTrial.f2(vowInds);
end
