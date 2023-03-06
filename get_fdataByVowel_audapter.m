function [fdataByVowel] = get_fdataByVowel_audapter(expt,data,cond)
%GET_FDATABYVOWEL_AUDAPTER  Get 
%   [fdataByVowel] = get_fdataByVowel_audapter(expt,data,cond)

if nargin < 3, cond = []; end

fdataByTrial = get_fdataByTrial_audapter(data);

vowels = expt.vowels;
for v = 1:length(vowels)
    vow = vowels{v};
    vowInds = expt.inds.vowels.(vow);
    if cond
        condInds = expt.inds.conds.(cond);
        vowInds = intersect(vowInds,condInds);
    end
    fdataByVowel.f1.(vow) = fdataByTrial.f1(vowInds);
    fdataByVowel.f2.(vow) = fdataByTrial.f2(vowInds);
end
