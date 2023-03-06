function [fdataByTrial] = get_fdataByTrial_audapter(data)
%GET_FDATABYTRIAL_AUDAPTER  Average each trial's Audapter track.
%   [fdataByTrial] = get_fdataByTrial_audapter(data)

ntrials = length(data);
fdataByTrial.f1 = NaN(1,ntrials);
fdataByTrial.f2 = NaN(1,ntrials);
for itrial = 1:ntrials
    ftrackSamps = data(itrial).fmts(:,1)>0;      % timepts when fmts are defined
    ftrack = data(itrial).fmts(ftrackSamps,:);   %
    ftrackLength = length(ftrack(:,1));     %
    if ftrackLength > 4
        p25 = round(ftrackLength/4);
        p50 = round(ftrackLength/2);
        fdataByTrial.f1(itrial) = mean(ftrack(p25:p50,1));   % average from 25-50%
        fdataByTrial.f2(itrial) = mean(ftrack(p25:p50,2));   %
    end
end
