function [VSA4,VSA3] = calc_VSA(fdataByVowel)
%CALC_VSA  Calculate the triangular vowel space area
%   [VSA] = calc_VSA(F1s,F2s) takes a struct Fxs with fields for each
%   vowel containing formant averages or a vector of values.
%
% VSA is calculated as in Skodda et al. 2012:
%   abs((F1_/i/ * (F2_/a/-F2_/u/)+
%       F1_/a/ * (F2_/u/-F2_/i/)+
%       F1_/u/ * (F2_/i/-F2_/a/)/2)
f1 = fdataByVowel.f1;
f2 = fdataByVowel.f2;

vowels = fieldnames(f1);
nvowels = length(vowels);

%check that vowels includes /i/, /u/, and /a/
if ~(any(strcmp(vowels,'aa')) && any(strcmp(vowels,'iy')) && any(strcmp(vowels,'uw')))
    error('fdataByVowel must contain data for the triangular corner vowels /i/, /u/, and /a/')
end

% if individual trials are provided instead of means, average trials
for v = 1:nvowels
    vow = vowels{v};
    if length(f1.(vowels{v})) > 1
        f1.(vow) = mean(f1.(vow),'omitnan');
        f2.(vow) = mean(f2.(vow),'omitnan');
    end
end

% % calc VSA from means
VSA3 = abs((f1.iy * (f2.aa - f2.uw) + ...
           f1.aa * (f2.uw - f2.iy) + ...
           f1.uw * (f2.iy - f2.aa))/2);

if nvowels>3
    %alternate VSA calculation, Heron's Formula, Neet et al. 2008
    a1 = sqrt((f1.iy-f1.ae)^2+(f2.iy-f2.ae)^2);
    b1 = sqrt((f1.ae-f1.uw)^2+(f2.ae-f2.uw)^2);
    c1 = sqrt((f1.iy-f1.uw)^2+(f2.iy-f2.uw)^2);
    s1 = 0.5*(a1+b1+c1);
    area1 = sqrt(s1*(s1-a1)*(s1-b1)*(s1-c1));
    a2 = sqrt((f1.uw-f1.ae)^2+(f2.uw-f2.ae)^2);
    b2 = sqrt((f1.aa-f1.uw)^2+(f2.aa-f2.uw)^2);
    c2 = sqrt((f1.aa-f1.ae)^2+(f2.aa-f2.ae)^2);
    s2 = 0.5*(a2+b2+c2);
    area2 = sqrt(s2*(s2-a2)*(s2-b2)*(s2-c2));
    VSA4 = area1+area2;
else
    VSA4 = NaN;
end
