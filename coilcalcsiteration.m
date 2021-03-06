function coilcalcsiteration

% Outputs to the function are:
%   Oall    :
%   MMP     : Minimum mass parameters
%   MPP     : Minimum power parameters
%   MVP     : Minimum voltage parameters
%   MCostP  : Minimum cost parameters
%   MVCuP   : Minimum volts with copper parameters
%
% Delete all outputs if you would not like to get any unimportant tabulated
% results. DO NOT delete all outputs if running coilcalcsplotter.m; all
% outputs are taken as sub-parameters in the coilcalcsplotterm program.

clear; clc; close all;
%% Set up

%Determine feasible materials
Materials = {'Cu', 'Nb'}; %Materials to test
%TO TEST ONE MATERIAL ONLY
%Materials = Materials(1) or enter string;

Gauges = [24, 26, 28, 30, 35, 40]; %Gauges Tested
sf = 1.4; %Safety Factor

gmin = 0.17; %Set min g to achieve
gmax = 0.19; %Set max g to achieve
gIterations = 21; %Set number of steps between min and max g
AccelSpan = linspace(gmin,gmax,gIterations);

TminDays = 3; %Set min time for spin up to achieve
TmaxDays = 8; %Set max time for spin up to achieve
TimeIterations = 11; %Set number of steps between min and max time
TimeSpan = linspace(TminDays*24,TmaxDays*24,TimeIterations);

wmin = 5; %Set min w to achieve
wmax = 6; %Set max w to achieve
wIterations = 11; %Set number of steps between min and max w
wSpan = linspace(wmin,wmax,wIterations);

Turnsmin = 50; %Set min g to achieve
Turnsmax = 300; %Set max g to achieve
TurnsIterations = (Turnsmax - Turnsmin)/10 + 1; %Set number of steps between min and max g
TurnsSpan = linspace(Turnsmin,Turnsmax,TurnsIterations);

prcntCmin = 50; %Set min prcnt C possible
prcntCmax = 50; %Set max prcnt C possible
prcntCIterations = 1; %Set number of steps between prcnt C
prcntCSpan = linspace(prcntCmin,prcntCmax,prcntCIterations);

prcntT = 100;
numcoils = 1;
EndCoils = {'no'};

OUTPUTS = zeros((gIterations*length(Materials)*length(Gauges)*TimeIterations*wIterations...
    *TurnsIterations*prcntCIterations),20);

%% Enumeration/Iterations

i = 1;
for ia = 1:gIterations % iterate over accelerations
    acceleration = AccelSpan(ia);
    for im = 1:length(Materials) % iterate over materials
        material = Materials(im);
        for ig = 1:length(Gauges) % iterate over gauges
            gauge = Gauges(ig);
            for iti = 1:TimeIterations % iterate over spin up times
                time = TimeSpan(iti);
                for iw = 1:wIterations % iterate over w
                    w = wSpan(iw);
                    for itu = 1:TurnsIterations % iterate over number of turns
                        turns = TurnsSpan(itu);
                        for ipc = 1:prcntCIterations % iterate over percent C
                            prcntC = prcntCSpan(ipc);
                            
                            [radius,torque,current,voltageEnd,...
                                powerEnd,voltageCenter,powerCenter,...
                                massEnd,massCenter,massTotal,MinCost] = ...
                                coilcalcs(acceleration,w,time,turns,numcoils,...
                                material,gauge,prcntC,prcntT,sf,EndCoils);
                            
                            [OUTPUTS(i,:)] = [acceleration,im,...
                                gauge,time,w,turns,numcoils,prcntC,...
                                prcntT,radius,torque,current,...
                                powerEnd,powerCenter,...
                                massEnd,massCenter,massTotal,MinCost...
                                voltageEnd,voltageCenter];
                            
                            i = i+1;
                        end
                    end
                end
            end
        end
    end
end

%% Output Cutoffs

for i = 1:length(OUTPUTS)
    
    if OUTPUTS(i,12) > 0.6 %Current cutoff
        [OUTPUTS(i,:)] = 0;
    end
    
    if OUTPUTS(i,13) > 1 %Power End cutoff
        [OUTPUTS(i,:)] = 0;
    end
    
    if OUTPUTS(i,14) > 3 %Power Center cutoff
        [OUTPUTS(i,:)] = 0;
    end
    
    if OUTPUTS(i,15) > 0.16 %Mass End cutoff
        [OUTPUTS(i,:)] = 0;
    end
    
    if OUTPUTS(i,16) > 0.865 %Mass Center cutoff
        [OUTPUTS(i,:)] = 0;
    end
    
    if OUTPUTS(i,17) > 4 %Mass Total cutoff
        [OUTPUTS(i,:)] = 0;
    end
    
    if OUTPUTS(i,18) > 100 %cost cutoff
        [OUTPUTS(i,:)] = 0;
    end
    
    if OUTPUTS(i,19) > 7.2 %Volts End cutoff
        [OUTPUTS(i,:)] = 0;
    end
    
    if OUTPUTS(i,20) > 7.2 %Volts Center cutoff
        [OUTPUTS(i,:)] = 0;
    end
end

OUTPUTS(all(OUTPUTS==0,2),:)=[];

Oall = OUTPUTS;

%% Finding optimal sets

if strcmp('yes',EndCoils)
    disp('Minimum output sets WITH coils in ends');
    
    % Minimum Mass
    [MinMass,MMI] = min(Oall(:,17)); %Find minimum mass and index
    MMP = Oall(MMI,:); % Find minimum mass parameters
    disp(' ');
    disp(['MINIMUM MASS (' num2str(MinMass) ') PARAMETERS:']);
    disp('------------------------------------------');
    disp(['material:         ' Materials(MMP(2)) ]);
    disp(['acceleration:     ' num2str(MMP(1)) '']);
    disp(['gauge:            ' num2str(MMP(3)) '']);
    disp(['time:             ' num2str(MMP(4)) '']);
    disp(['w:                ' num2str(MMP(5)) '']);
    disp(['turns:            ' num2str(MMP(6)) '']);
    disp(['numcoils:         ' num2str(MMP(7)) '']);
    disp(['prcntC:           ' num2str(MMP(8)) '']);
    disp(['radius:           ' num2str(MMP(10)) '']);
    disp(['torque:           ' num2str(MMP(11)) '']);
    disp(['current:          ' num2str(MMP(12)) '']);
    disp(['powerEnd:         ' num2str(MMP(13)) '']);
    disp(['powerCenter:      ' num2str(MMP(14)) '']);
    disp(['voltsEnd:         ' num2str(MMP(19)) '']);
    disp(['voltsCenter:      ' num2str(MMP(20)) '']);
    disp(['massEnd:          ' num2str(MMP(15)) '']);
    disp(['massCenter:       ' num2str(MMP(16)) '']);
    disp(['massTotal:        ' num2str(MMP(17)) '']);
    disp(['MinCost:          ' num2str(MMP(18)) '']);
    disp(' ');
    
    % Minimum Power
    PowerTotal = 2*Oall(:,13) + Oall(:,14);
    [MinPower,MPI] = min(PowerTotal); %Find minimum power and index
    MPP = Oall(MPI,:); % Find minimum power parameters
    disp(' ');
    disp(['MINIMUM POWER (' num2str(MinPower) ') PARAMETERS:']);
    disp('------------------------------------------');
    disp(['material:         ' Materials(MPP(2)) ]);
    disp(['acceleration:     ' num2str(MPP(1)) '']);
    disp(['gauge:            ' num2str(MPP(3)) '']);
    disp(['time:             ' num2str(MPP(4)) '']);
    disp(['w:                ' num2str(MPP(5)) '']);
    disp(['turns:            ' num2str(MPP(6)) '']);
    disp(['numcoils:         ' num2str(MPP(7)) '']);
    disp(['prcntC:           ' num2str(MPP(8)) '']);
    disp(['radius:           ' num2str(MPP(10)) '']);
    disp(['torque:           ' num2str(MPP(11)) '']);
    disp(['current:          ' num2str(MPP(12)) '']);
    disp(['powerEnd:         ' num2str(MPP(13)) '']);
    disp(['powerCenter:      ' num2str(MPP(14)) '']);
    disp(['voltsEnd:         ' num2str(MPP(19)) '']);
    disp(['voltsCenter:      ' num2str(MPP(20)) '']);
    disp(['massEnd:          ' num2str(MPP(15)) '']);
    disp(['massCenter:       ' num2str(MPP(16)) '']);
    disp(['massTotal:        ' num2str(MPP(17)) '']);
    disp(['MinCost:          ' num2str(MPP(18)) '']);
    disp(' ');
    
    %Minimum Volts
    VoltsTotal = 2*Oall(:,19) + Oall(:,20);
    [MinVolts,MVI] = min(VoltsTotal); %Find minimum volts and index
    MVP = Oall(MVI,:); % Find minimum power parameters
    disp(' ');
    disp(['MINIMUM VOLTAGE (' num2str(MinVolts) ') PARAMETERS:']);
    disp('------------------------------------------');
    disp(['material:         ' Materials(MVP(2)) ]);
    disp(['acceleration:     ' num2str(MVP(1)) '']);
    disp(['gauge:            ' num2str(MVP(3)) '']);
    disp(['time:             ' num2str(MVP(4)) '']);
    disp(['w:                ' num2str(MVP(5)) '']);
    disp(['turns:            ' num2str(MVP(6)) '']);
    disp(['numcoils:         ' num2str(MVP(7)) '']);
    disp(['prcntC:           ' num2str(MVP(8)) '']);
    disp(['radius:           ' num2str(MVP(10)) '']);
    disp(['torque:           ' num2str(MVP(11)) '']);
    disp(['current:          ' num2str(MVP(12)) '']);
    disp(['powerEnd:         ' num2str(MVP(13)) '']);
    disp(['powerCenter:      ' num2str(MVP(14)) '']);
    disp(['voltsEnd:         ' num2str(MVP(19)) '']);
    disp(['voltsCenter:      ' num2str(MVP(20)) '']);
    disp(['massEnd:          ' num2str(MVP(15)) '']);
    disp(['massCenter:       ' num2str(MVP(16)) '']);
    disp(['massTotal:        ' num2str(MVP(17)) '']);
    disp(['MinCost:          ' num2str(MVP(18)) '']);
    disp(' ');
    
    % Minimum Cost
    [MinCost,MCostI] = min(Oall(:,18)); %Find minimum cost and index
    MCostP = Oall(MCostI,:); % Find minimum cost parameters
    disp(' ');
    disp(['MINIMUM COST (' num2str(MinCost) ') PARAMETERS:']);
    disp('------------------------------------------');
    disp(['material:         ' Materials(MCostP(2)) ]);
    disp(['acceleration:     ' num2str(MCostP(1)) '']);
    disp(['gauge:            ' num2str(MCostP(3)) '']);
    disp(['time:             ' num2str(MCostP(4)) '']);
    disp(['w:                ' num2str(MCostP(5)) '']);
    disp(['turns:            ' num2str(MCostP(6)) '']);
    disp(['numcoils:         ' num2str(MCostP(7)) '']);
    disp(['prcntC:           ' num2str(MCostP(8)) '']);
    disp(['radius:           ' num2str(MCostP(10)) '']);
    disp(['torque:           ' num2str(MCostP(11)) '']);
    disp(['current:          ' num2str(MCostP(12)) '']);
    disp(['powerEnd:         ' num2str(MCostP(13)) '']);
    disp(['powerCenter:      ' num2str(MCostP(14)) '']);
    disp(['voltsEnd:         ' num2str(MCostP(19)) '']);
    disp(['voltsCenter:      ' num2str(MCostP(20)) '']);
    disp(['massEnd:          ' num2str(MCostP(15)) '']);
    disp(['massCenter:       ' num2str(MCostP(16)) '']);
    disp(['massTotal:        ' num2str(MCostP(17)) '']);
    disp(['MinCost:          ' num2str(MCostP(18)) '']);
    disp(' ');
    
    % Min volts Cu option (BEST FEASIBLE CASE)
    iCu = all(Oall(:,2) == 1,2);
    OallCu = Oall(logical(iCu),:);%All copper points
    CuVoltsTotal = 2*OallCu(:,19) + OallCu(:,20); %Find minimum Cu volts and index
    [MinVoltsCu,MVCuI] = min(CuVoltsTotal);
    MVCuP = Oall(MVCuI,:); % Find minimum volts with copper wire parameters
    disp(' ');
    disp(['MINIMUM VOLTS W COPPER (' num2str(MinVoltsCu) ') PARAMETERS:']);
    disp('------------------------------------------');
    disp(['material:         ' Materials(MVCuP(2)) ]);
    disp(['acceleration:     ' num2str(MVCuP(1)) '']);
    disp(['gauge:            ' num2str(MVCuP(3)) '']);
    disp(['time:             ' num2str(MVCuP(4)) '']);
    disp(['w:                ' num2str(MVCuP(5)) '']);
    disp(['turns:            ' num2str(MVCuP(6)) '']);
    disp(['numcoils:         ' num2str(MVCuP(7)) '']);
    disp(['prcntC:           ' num2str(MVCuP(8)) '']);
    disp(['radius:           ' num2str(MVCuP(10)) '']);
    disp(['torque:           ' num2str(MVCuP(11)) '']);
    disp(['current:          ' num2str(MVCuP(12)) '']);
    disp(['powerEnd:         ' num2str(MVCuP(13)) '']);
    disp(['powerCenter:      ' num2str(MVCuP(14)) '']);
    disp(['voltsEnd:         ' num2str(MVCuP(19)) '']);
    disp(['voltsCenter:      ' num2str(MVCuP(20)) '']);
    disp(['massEnd:          ' num2str(MVCuP(15)) '']);
    disp(['massCenter:       ' num2str(MVCuP(16)) '']);
    disp(['massTotal:        ' num2str(MVCuP(17)) '']);
    disp(['MinCost:          ' num2str(MVCuP(18)) '']);
    disp(' ');
    
else
    disp('Minimum output sets WITHOUT coils in ends');
    
    % Minimum Mass
    [MinMass,MMI] = min(Oall(:,17)); %Find minimum mass and index
    MMP = Oall(MMI,:); % Find minimum mass parameters
    disp(' ');
    disp(['MINIMUM MASS (' num2str(MinMass) ') PARAMETERS:']);
    disp('------------------------------------------');
    disp(['material:         ' Materials(MMP(2)) ]);
    disp(['acceleration:     ' num2str(MMP(1)) '']);
    disp(['gauge:            ' num2str(MMP(3)) '']);
    disp(['time:             ' num2str(MMP(4)) '']);
    disp(['w:                ' num2str(MMP(5)) '']);
    disp(['turns:            ' num2str(MMP(6)) '']);
    disp(['numcoils:         ' num2str(MMP(7)) '']);
    disp(['prcntC:           ' num2str(MMP(8)) '']);
    disp(['radius:           ' num2str(MMP(10)) '']);
    disp(['torque:           ' num2str(MMP(11)) '']);
    disp(['current:          ' num2str(MMP(12)) '']);
    disp(['powerCenter:      ' num2str(MMP(14)) '']);
    disp(['voltsCenter:      ' num2str(MMP(20)) '']);
    disp(['massCenter:       ' num2str(MMP(16)) '']);
    disp(['MinCost:          ' num2str(MMP(18)) '']);
    disp(' ');
    
    % Minimum Power
    PowerTotal = 2*Oall(:,13) + Oall(:,14);
    [MinPower,MPI] = min(PowerTotal); %Find minimum power and index
    MPP = Oall(MPI,:); % Find minimum power parameters
    disp(' ');
    disp(['MINIMUM POWER (' num2str(MinPower) ') PARAMETERS:']);
    disp('------------------------------------------');
    disp(['material:         ' Materials(MPP(2)) ]);
    disp(['acceleration:     ' num2str(MPP(1)) '']);
    disp(['gauge:            ' num2str(MPP(3)) '']);
    disp(['time:             ' num2str(MPP(4)) '']);
    disp(['w:                ' num2str(MPP(5)) '']);
    disp(['turns:            ' num2str(MPP(6)) '']);
    disp(['numcoils:         ' num2str(MPP(7)) '']);
    disp(['prcntC:           ' num2str(MPP(8)) '']);
    disp(['radius:           ' num2str(MPP(10)) '']);
    disp(['torque:           ' num2str(MPP(11)) '']);
    disp(['current:          ' num2str(MPP(12)) '']);
    disp(['powerCenter:      ' num2str(MPP(14)) '']);
    disp(['voltsCenter:      ' num2str(MPP(20)) '']);
    disp(['massCenter:       ' num2str(MPP(16)) '']);
    disp(['MinCost:          ' num2str(MPP(18)) '']);
    disp(' ');
    
    %Minimum Volts
    VoltsTotal = 2*Oall(:,19) + Oall(:,20);
    [MinVolts,MVI] = min(VoltsTotal); %Find minimum volts and index
    MVP = Oall(MVI,:); % Find minimum power parameters
    disp(' ');
    disp(['MINIMUM VOLTAGE (' num2str(MinVolts) ') PARAMETERS:']);
    disp('------------------------------------------');
    disp(['material:         ' Materials(MVP(2)) ]);
    disp(['acceleration:     ' num2str(MVP(1)) '']);
    disp(['gauge:            ' num2str(MVP(3)) '']);
    disp(['time:             ' num2str(MVP(4)) '']);
    disp(['w:                ' num2str(MVP(5)) '']);
    disp(['turns:            ' num2str(MVP(6)) '']);
    disp(['numcoils:         ' num2str(MVP(7)) '']);
    disp(['prcntC:           ' num2str(MVP(8)) '']);
    disp(['radius:           ' num2str(MVP(10)) '']);
    disp(['torque:           ' num2str(MVP(11)) '']);
    disp(['current:          ' num2str(MVP(12)) '']);
    disp(['powerCenter:      ' num2str(MVP(14)) '']);
    disp(['voltsCenter:      ' num2str(MVP(20)) '']);
    disp(['massCenter:       ' num2str(MVP(16)) '']);
    disp(['MinCost:          ' num2str(MVP(18)) '']);
    disp(' ');
    
    % Minimum Cost
    [MinCost,MCostI] = min(Oall(:,18)); %Find minimum cost and index
    MCostP = Oall(MCostI,:); % Find minimum cost parameters
    disp(' ');
    disp(['MINIMUM COST (' num2str(MinCost) ') PARAMETERS:']);
    disp('------------------------------------------');
    disp(['material:         ' Materials(MCostP(2)) ]);
    disp(['acceleration:     ' num2str(MCostP(1)) '']);
    disp(['gauge:            ' num2str(MCostP(3)) '']);
    disp(['time:             ' num2str(MCostP(4)) '']);
    disp(['w:                ' num2str(MCostP(5)) '']);
    disp(['turns:            ' num2str(MCostP(6)) '']);
    disp(['numcoils:         ' num2str(MCostP(7)) '']);
    disp(['prcntC:           ' num2str(MCostP(8)) '']);
    disp(['radius:           ' num2str(MCostP(10)) '']);
    disp(['torque:           ' num2str(MCostP(11)) '']);
    disp(['current:          ' num2str(MCostP(12)) '']);
    disp(['powerCenter:      ' num2str(MCostP(14)) '']);
    disp(['voltsCenter:      ' num2str(MCostP(20)) '']);
    disp(['massCenter:       ' num2str(MCostP(16)) '']);
    disp(['MinCost:          ' num2str(MCostP(18)) '']);
    disp(' ');
    
    % Min volts Cu option (BEST FEASIBLE CASE)
    iCu = all(Oall(:,2) == 1,2);
    OallCu = Oall(logical(iCu),:);%All copper points
    CuVoltsTotal = 2*OallCu(:,19) + OallCu(:,20); %Find minimum Cu volts and index
    [MinVoltsCu,MVCuI] = min(CuVoltsTotal);
    MVCuP = Oall(MVCuI,:); % Find minimum volts with copper wire parameters
    disp(' ');
    disp(['MINIMUM VOLTS W COPPER (' num2str(MinVoltsCu) ') PARAMETERS:']);
    disp('------------------------------------------');
    disp(['material:         ' Materials(MVCuP(2)) ]);
    disp(['acceleration:     ' num2str(MVCuP(1)) '']);
    disp(['gauge:            ' num2str(MVCuP(3)) '']);
    disp(['time:             ' num2str(MVCuP(4)) '']);
    disp(['w:                ' num2str(MVCuP(5)) '']);
    disp(['turns:            ' num2str(MVCuP(6)) '']);
    disp(['numcoils:         ' num2str(MVCuP(7)) '']);
    disp(['prcntC:           ' num2str(MVCuP(8)) '']);
    disp(['radius:           ' num2str(MVCuP(10)) '']);
    disp(['torque:           ' num2str(MVCuP(11)) '']);
    disp(['current:          ' num2str(MVCuP(12)) '']);
    disp(['powerCenter:      ' num2str(MVCuP(14)) '']);
    disp(['voltsCenter:      ' num2str(MVCuP(20)) '']);
    disp(['massCenter:       ' num2str(MVCuP(16)) '']);
    disp(['MinCost:          ' num2str(MVCuP(18)) '']);
    disp(' ');
end

end
