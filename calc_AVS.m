function [AVS] = calc_AVS(fdataByVowel)
%CALC_AVS  Calculate average vowel spacing between vowel means.
%   [AVS] = calc_AVS(F1s,F2s) takes a struct Fxs with fields for each
%   vowel containing formant averages or a vector of values.

vowels = fieldnames(fdataByVowel.f1);
nvowels = length(vowels);

% if individual trials are provided instead of means, average trials
for v = 1:nvowels
    vow = vowels{v};
    if length(fdataByVowel.f1.(vowels{1})) > 1
        fdataByVowel.f1.(vow) = mean(fdataByVowel.f1.(vow),'omitnan');
        fdataByVowel.f2.(vow) = mean(fdataByVowel.f2.(vow),'omitnan');
    end
end

% calc AVS from means
dists = NaN(nvowels-1,nvowels-1);

paircount = 0;
for i = 1:nvowels-1
    for j = i+1:nvowels
        paircount = paircount+1;
        F1i = fdataByVowel.f1.(vowels{i});
        F1j = fdataByVowel.f1.(vowels{j});
        F2i = fdataByVowel.f2.(vowels{i});
        F2j = fdataByVowel.f2.(vowels{j});        
        dists(i,j-1) = sqrt( (F1i-F1j)^2 + (F2i-F2j)^2 );
    end
end
AVS = mean(dists(:),'omitnan');

% from Lane et al. 2001:
% AVS = (2 / npairs*(npairs-1) ) * sum of dists
