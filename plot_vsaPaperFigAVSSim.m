%gen_simulatedVSA.m
iyF1 = 450;
% aeF1 = 950;
aeF1 = 950;
aaF1 = 900;
uwF1 = 500;
iyF2 = 1800;
% aeF2 = 1500;
aeF2 = 1500;
% aaF2 = 1200;
aaF2 = 1200;
% uwF2 = 1200;
uwF2 = 1200;

expandFact = 30;
% iyF1 = hz2mel(450);
% aeF1 = hz2mel(950);
% aaF1 = hz2mel(900);
% uwF1 = hz2mel(500);
% iyF2 = hz2mel(1800);
% aeF2 = hz2mel(1500);
% aaF2 = hz2mel(1200);
% uwF2 = hz2mel(1200);

%baseline data
f1.iy = iyF1; f1.ae = aeF1; f1.aa = aaF1; f1.uw = uwF1;
f2.iy = iyF2; f2.ae = aeF2; f2.aa = aaF2; f2.uw = uwF2;
fData(1).f1 = f1;
fData(1).f2 = f2;
baselineVSA = calc_VSA(fData(1));
baselineAVS = calc_AVS(fData(1));
fmtMeans.iy = [iyF1 iyF2];
fmtMeans.ae = [aeF1 aeF2];
fmtMeans.aa = [aaF1 aaF2];
fmtMeans.uw = [uwF1 uwF2];
% p = calc_pertField('in',fmtMeans,0,0);
% baseDist(1) = sqrt((f1.iy-p.fCen(1))^2+(f2.iy-p.fCen(2))^2);
% baseDist(2) = sqrt((f1.ae-p.fCen(1))^2+(f2.iy-p.fCen(2))^2);
% baseDist(3) = sqrt((f1.aa-p.fCen(1))^2+(f2.iy-p.fCen(2))^2);
% baseDist(4) = sqrt((f1.uw-p.fCen(1))^2+(f2.iy-p.fCen(2))^2);

%simulation 1
f1.iy = iyF1-expandFact; f1.ae = aeF1+expandFact; f1.aa = aaF1+expandFact; f1.uw = uwF1-expandFact;
f2.iy = iyF2+expandFact; f2.ae = aeF2+expandFact; f2.aa = aaF2-expandFact; f2.uw = uwF2-expandFact;
fData(2).f1 = f1;
fData(2).f2 = f2;
sim1VSA = calc_VSA(fData(2));
sim1AVS = calc_AVS(fData(2));
% sim1Dist(1) = sqrt((f1.iy-p.fCen(1))^2+(f2.iy-p.fCen(2))^2);
% sim1Dist(2) = sqrt((f1.ae-p.fCen(1))^2+(f2.iy-p.fCen(2))^2);
% sim1Dist(3) = sqrt((f1.aa-p.fCen(1))^2+(f2.iy-p.fCen(2))^2);
% sim1Dist(4) = sqrt((f1.uw-p.fCen(1))^2+(f2.iy-p.fCen(2))^2);
fprintf('sim 1 norm AVS: %d\n', sim1AVS/baselineAVS)
fprintf('sim 1 norm VSA: %d\n', sim1VSA/baselineVSA)
% fprintf('sim 1 change in distance: %d, %d, %d, %d\n', ...
%     sim1Dist(1)-baseDist(1),sim1Dist(2)-baseDist(2),...
%     sim1Dist(3)-baseDist(3),sim1Dist(4)-baseDist(4))

% %simulation 2
% f1.iy = iyF1-expandFact; f1.ae = aeF1+expandFact; f1.aa = aaF1+expandFact; f1.uw = uwF1+0.5*expandFact;
% f2.iy = iyF2-expandFact; f2.ae = aeF2-expandFact; f2.aa = aaF2-expandFact; f2.uw = uwF2+1.5*expandFact;
f1.iy = iyF1-1.0*expandFact; f1.ae = aeF1+1*expandFact; f1.aa = aaF1+1*expandFact; f1.uw = uwF1+1*expandFact;
f2.iy = iyF2+1*expandFact; f2.ae = aeF2+1*expandFact; f2.aa = aaF2-1*expandFact; f2.uw = uwF2+1*expandFact;
fData(3).f1 = f1;
fData(3).f2 = f2;
sim2VSA = calc_VSA(fData(3));
sim2AVS = calc_AVS(fData(3));
% sim2Dist(1) = sqrt((f1.iy-p.fCen(1))^2+(f2.iy-p.fCen(2))^2);
% sim2Dist(2) = sqrt((f1.ae-p.fCen(1))^2+(f2.iy-p.fCen(2))^2);
% sim2Dist(3) = sqrt((f1.aa-p.fCen(1))^2+(f2.iy-p.fCen(2))^2);
% sim2Dist(4) = sqrt((f1.uw-p.fCen(1))^2+(f2.iy-p.fCen(2))^2);
fprintf('sim 2 norm AVS: %d\n', sim2AVS/baselineAVS)
fprintf('sim 2 norm VSA: %d\n', sim2VSA/baselineVSA)
% fprintf('sim 2 change in distance: %d, %d, %d, %d\n', ...
%     sim2Dist(1)-baseDist(1),sim2Dist(2)-baseDist(2),...
%     sim2Dist(3)-baseDist(3),sim2Dist(4)-baseDist(4))

%plot simulations
plotColors = {'k','b','r'};
h_fig = figure;
for i = 1:3
    f1 = fData(i).f1;
    f2 = fData(i).f2;
    plot([f1.iy f1.ae f1.aa f1.uw f1.iy],...
        [f2.iy f2.ae f2.aa f2.uw f2.iy],...
        strcat('--o',plotColors{i}));
    hold on
end
% plot(fCen(1),fCen(2),'+k')
labelFontSize = 16;

set(0, 'DefaultTextInterpreter', 'tex')

h_text(1) = text(iyF1+20, iyF2-50,'/i/','FontSize',labelFontSize);
h_text(2) = text(aeF1-50, aeF2-50,'/æ/','FontSize',labelFontSize);
h_text(2) = text(aaF1-50, aaF2+50,'/?/','FontSize',labelFontSize);
h_text(2) = text(uwF1+25, uwF2+50,'/u/','FontSize',labelFontSize);
xlabel('F1 (mels)')
ylabel('F2 (mels)')
legend