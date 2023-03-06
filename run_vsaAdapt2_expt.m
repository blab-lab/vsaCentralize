function expt = run_vsaAdapt2_expt(expt,bTestMode)
%RUN_VSAADAPT2_EXPT  Run VSA pilot adaptation experiment.
%   RUN_VSAADAPT2_EXPT(EXPT,BTESTMODE)

if nargin < 1, expt = []; end
if nargin < 2 || isempty(bTestMode), bTestMode = 0; end

%% set up stimuli
expt.name = 'vsaAdapt2';
if ~isfield(expt,'snum'), expt.snum = get_snum; end
if ~isfield(expt,'gender'), expt.gender = get_gender; end

% assign participant to group
subjPath = get_acoustSavePath(expt.name,expt.snum);
groups = {'adapt','null'};
if ~isfield(expt,'group')
    %[expt.group,expt.groupnum] = get_sgroup(subjPath,groups);
    unusedGroups = get_unusedDirs(subjPath,groups);
    if isempty(unusedGroups)
        group = input('All groups already exist as folders for this subject! Please enter a group name: ', 's');
        expt.group = check_sgroup(group, groups); % check that group is valid
        expt.groupnum = find(strcmp(expt.group,groups));
    else
        if any(strcmp(unusedGroups,'null'))
            expt.group = 'null';
            expt.groupnum = find(strcmp(expt.group,groups));
        else
            rp = randperm(length(unusedGroups));
            expt.group = unusedGroups{rp(1)};
            expt.groupnum = find(strcmp(expt.group,groups));
        end
    end
else
    expt.group = check_sgroup(expt.group, groups);
    expt.groupnum = find(strcmp(expt.group,groups));
end
expt.dataPath = fullfile(subjPath,expt.group);

% stimuli
expt.conds = {'baseline' 'ramp' 'hold' 'washout' 'retention'};
expt.words = {'bead' 'bad' 'booed' 'bod'};

% timing
expt.timing.stimdur = 1.5;         % time stim is on screen, in seconds
expt.timing.interstimdur = .75;    % minimum time between stims, in seconds
expt.timing.interstimjitter = .75; % maximum extra time between stims (jitter)

nwords = length(expt.words);
if bTestMode
    testModeReps = 3;
    nPre = testModeReps*nwords;
    nBaseline = testModeReps*nwords;
    nRamp = testModeReps*nwords;
    nHold = testModeReps*nwords;
    nWashout = testModeReps*nwords;
    nRetention = testModeReps*nwords;
    delayMin = .01;
    expt.breakFrequency = testModeReps*nwords;
else
    nPre = 10*nwords;
    nBaseline = 15*nwords;
    nRamp = 10*nwords;
    nHold = 80*nwords;
    nWashout = 10*nwords;
    nRetention = 10*nwords;
    delayMin = 10;
    expt.breakFrequency = 30;
end
delaySecs = delayMin * 60;

%% set up calibration phase
exptpre = expt;
exptpre.dataPath = fullfile(expt.dataPath,'pre');
exptpre.conds = {'baseline'};
exptpre.ntrials = nPre;
exptpre.breakTrials = nPre;

% get default LPC order if previously defined
if exist(subjPath,'dir')        % if subject folder exists
    ngroups = length(groups);   % look for 'pre' folder in other group
    for g = 1:ngroups-1
         othergroupnum = mod(expt.groupnum+1,ngroups);
        if ~othergroupnum, othergroupnum = ngroups; end
        predir = fullfile(subjPath,groups{othergroupnum},'pre');
        if exist(predir,'dir')          % if 'pre' folder exists
            fprintf('Previous calibration directory found... ');
            nlpcfile = fullfile(predir,'nlpc.mat');
            if exist(nlpcfile,'file')   % if nlpc.mat file exists
                load(nlpcfile,'nlpc');
                fprintf('setting default LPC order to %d.\n',nlpc);
                exptpre.audapterParams.nLPC = nlpc;
            else
                fprintf('but no nlpc data found. Using default LPC order.\n');
            end
        end
    end
end

%% set up main experiment
% ntrials
expt.ntrials = nBaseline + nRamp + nHold + nWashout + nRetention;
expt.breakTrials = expt.breakFrequency:expt.breakFrequency:expt.ntrials-nRetention;

% conds
expt.allConds = [1*ones(1,nBaseline) 2*ones(1,nRamp) 3*ones(1,nHold) 4*ones(1,nWashout) 5*ones(1,nRetention)];

% shifts
fieldDim = 257;
p.F1Min = 200;
p.F1Max = 1500;
p.F2Min = 500;
p.F2Max = 3500;
p.pertf1 = floor(p.F1Min:(p.F1Max-p.F1Min)/(fieldDim-1):p.F1Max);
p.pertf2 = floor(p.F2Min:(p.F2Max-p.F2Min)/(fieldDim-1):p.F2Max);
p.pertAmp2D = zeros(fieldDim,fieldDim); % define dummy pert field
p.pertPhi2D = zeros(fieldDim,fieldDim); % define dummy pert field
p.bShift2D = 1; % flag for 2D experiment
expt.audapterParams = p;

if strcmp(expt.group,'adapt')
    maxScaleFact = .5;
elseif strcmp(expt.group,'null')
    maxScaleFact = 0;
end
% shiftScaleFact is a scalar between 0 and maxScaleFact that is used to scale shiftMag matrix
expt.shiftScaleFact = [zeros(1,nBaseline) linspace(0,maxScaleFact,nRamp) maxScaleFact*ones(1,nHold) zeros(1,nWashout+nRetention)];

%% save expt
if ~exist(expt.dataPath,'dir')
    mkdir(expt.dataPath)
end
exptfile = fullfile(expt.dataPath,'expt.mat');
bSave = savecheck(exptfile);
if bSave
    save(exptfile, 'expt')
    fprintf('Saved expt file: %s.\n',exptfile);
end

pertFieldOK = 0;
%% measure vowel space
while ~pertFieldOK
    % if ~exist(fullfile(exptpre.dataPath,'data.mat'),'file')
    exptpre = run_measureFormants_audapter(exptpre);
    % end
    
    %check LPC order
    check_audapterLPC(exptpre.dataPath)
    hGui = findobj('Tag','check_LPC');
    waitfor(hGui);
    
    load(fullfile(exptpre.dataPath,'nlpc'),'nlpc')
    
    %% calibrate 2D pert field
    fmtMeans = calc_vowelMeans(exptpre.dataPath);
    [p,h_pertField] = calc_pertField('in',fmtMeans,1);
    pertFieldCheck = input('Is the perturbation field OK? y/n: ','s');
    if strcmp(strip(pertFieldCheck),'y')
        pertFieldOK = 1;
    end
    try
        close(h_pertField)
    catch
    end
    
    %set lpc order
    p.nLPC = nlpc;
end
expt.audapterParams = add2struct(expt.audapterParams,p);

% resave expt
save(exptfile, 'expt');
fprintf('Saved pertfield to expt file: %s.\n',exptfile);

%% run adaptation experiment

conds2run = {'baseline'};
expt = run_vsaAdapt_audapter(expt,conds2run);

conds2run = {'ramp'};
expt = run_vsaAdapt_audapter(expt,conds2run);

conds2run = {'hold'};
expt = run_vsaAdapt_audapter(expt,conds2run);

conds2run = {'washout'};
expt = run_vsaAdapt_audapter(expt,conds2run);

%% run retention
time = clock;
starthr = time(4);
startmin = time(5) + delayMin;
if startmin > 59
    startmin = mod(startmin,60);
    starthr = starthr + 1;
    while starthr > 12
        starthr = starthr - 12;
    end
end
fprintf('Pausing for %d minutes. Experiment will resume at %d:%02d.\n',delayMin,starthr,startmin);
pause(delaySecs);
fprintf('Starting retention phase.\n');
conds2run = {'retention'};
expt = run_vsaAdapt_audapter(expt,conds2run);

