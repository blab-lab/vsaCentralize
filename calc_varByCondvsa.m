function [datatable,datatableByCond] = calc_varByCondvsa(dataPaths,session)
%CALC_VARBYCOND  Calculate avg dist to vowel center by condition.
% session: null, adapt; different new construction
%   CALC_VARBYCOND(DATAPATHS)

nsubj = length(dataPaths);
stab = cell(1,nsubj);
stabByCond = cell(1,nsubj);
for s = 1:nsubj
    dataPath = dataPaths{s};
    fprintf('Processing subject %d: %s \n',s,dataPath);
    load(fullfile(dataPath,'expt.mat'),'expt');
    load(fullfile(dataPath,'dataVals.mat'),'dataVals');
    
    vowels = expt.vowels;
    %vowels = setdiff(vowels,'uw'); % don't analyze /u/ if it exists for some subj
    
    %reconstruct conditions
    switch session
        case 'null'
    expt.conds_new={'baseline', 'hold1','hold2','washout'};%,'retention'
    expt.inds.conds_new.baseline=1:120; %combine baseline and ramp
     expt.inds.conds_new.hold1=121:240;%(hold+wasout)/3
       expt.inds.conds_new.hold2=241:360;
         %expt.inds.conds_new.hold3=341:460;
           expt.inds.conds_new.washout=361:460;%retention
        case 'adapt'
     expt.conds_new={'baseline','ramp','hold1','hold2','retention'};
    expt.inds.conds_new.baseline=1:60; %baseline
    expt.inds.conds_new.ramp=61:100; %ramp
     expt.inds.conds_new.hold1=101:260;%hold/2
       expt.inds.conds_new.hold2=261:420;
           expt.inds.conds_new.retention=461:500;%retention
    end
    
    
    nconds = length(expt.conds_new);
    ctab = cell(1,nconds);
    ctabByCond = cell(1,nconds);
    for c = 1:nconds
        cond = expt.conds_new{c};
        
        % generate condition-specific dataVals,fdata
        dV.(cond) = dataVals(expt.inds.conds_new.(cond));
        [fmtdata.(cond),~,~,durdata,RTdata,trialinds.(cond)] = calc_fdata(expt,dV.(cond),'vowel');
        
        nvowels = length(vowels);
        vtab = cell(1,nvowels);
        vtabByCond = cell(1,nvowels);
        
        
        
        for v = 1:nvowels
            vow = vowels{v};
            vowdata_init = fmtdata.(cond).mels.(vow).first50ms;
            %vowdata_midp = fmtdata.(cond).mels.(vow).mid50p;
            vowdata_mid = fmtdata.(cond).mels.(vow).mid50ms;
            
            fact.cond = cond;
            fact.vowel = vow;
            fact.subj = s;
            
            %% all trials
            %duration
            dat.duration = durdata.s.(vow)';
            
             % RT
             dat.RT = RTdata.s.(vow)';
             
             % rawF1
             dat.rawF1_init=vowdata_init.rawavg.f1';
               dat.rawF1_mid=vowdata_mid.rawavg.f1';
               % rawF2
             dat.rawF2_init=vowdata_init.rawavg.f2';
               dat.rawF2_mid=vowdata_mid.rawavg.f2'; 
             
            % dists
            dat.initdists = vowdata_init.dist';
            dat.middists = vowdata_mid.dist';
            
            % dists normalized by baseline median distance
            dat.norminitdists = dat.initdists./fmtdata.baseline.mels.(vow).first50ms.meddist;
            dat.normmiddists = dat.middists./fmtdata.baseline.mels.(vow).mid50ms.meddist;
            
            % centering
            dat.centering = dat.initdists-dat.middists;
            
            fact.trialinds = trialinds.(cond).(vow);
            vtab{v} = get_datatable(dat,fact);
            clear dat;
            fact = rmfield(fact,'trialinds');
            
            %% summary data (by condition by vowel)
            %duration and duration std
            vowdata_dura = durdata.s.(vow);
            dat.dura=nanmean(vowdata_dura);
            dat.stddura=std(vowdata_dura);
            
             %RT and RT std
            vowdata_RT = RTdata.s.(vow);
            dat.RT=nanmean(vowdata_RT);
            dat.stdRT=std(vowdata_RT);
            
            
            
            % F1 and F2 std
            dat.stdf1_mid = std(vowdata_mid.rawavg.f1);
            dat.stdf2_mid = std(vowdata_mid.rawavg.f2);
            
            dat.stdf1_init = std(vowdata_init.rawavg.f1);
            dat.stdf2_init = std(vowdata_init.rawavg.f2); 
            
            
            % median
            dat.medf1 = vowdata_mid.med.f1;
            dat.medf2 = vowdata_mid.med.f2;
            
            %distance
            dat.initdists = nanmean(vowdata_init.dist);
            dat.middists = nanmean(vowdata_mid.dist);
            
            % area 
            [~,dat.area,~] = FitEllipse(vowdata_mid.rawavg.f1,vowdata_mid.rawavg.f2);
            
            %centering
            dat.centering = nanmean(vowdata_init.dist-vowdata_mid.dist);
            
            % centering perc
            dat.centperc = nanmean((vowdata_init.dist-vowdata_mid.dist)./(vowdata_mid.dist+eps));

            vtabByCond{v} = get_datatable(dat,fact);
            clear dat;
            
        end
        ctab{c} = vertcat(vtab{:});
        ctabByCond{c} = vertcat(vtabByCond{:});
        
    end
    stab{s} = vertcat(ctab{:});
    stabByCond{s} = vertcat(ctabByCond{:});
    
end

datatable = vertcat(stab{:});
datatableByCond = vertcat(stabByCond{:});

% %% stats
% 
% % dists
% %[p,t,stats] = anovan(datatable.dists,{datatable.cond datatable.vowel datatable.subj});
% %figure; [comparison,means,h,gnames] = multcompare(stats,'dimension',1);
% 
% % log dists: add epsilon to dists to avoid log(0)
% [p,t,stats] = anovan(log(datatable.middists+eps),{datatable.cond datatable.vowel datatable.subj},...
%     'model','interaction',...
%     'random',3,...
%     'varnames',datatable.Properties.VariableNames(end-3:end-1));
%     %'varnames',{'cond' 'vowel' 'subj'});
% figure; [comparison,means,h,gnames] = multcompare(stats,'dimension',1);
