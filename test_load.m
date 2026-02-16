%% Quick test: load data and compute cp
clear all; close all;

chord = 149;
Hts   = 500;
xc = [0 0.027 0.047 0.095 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1];
yc = 5*0.18*(0.2969*sqrt(xc) - 0.126*xc - 0.3516*xc.^2 + 0.2843*xc.^3 - 0.1015*xc.^4);

indata  = xlsread('GroupB2_wing.xlsx');
indata2 = xlsread('GroupB2_rake.xlsx');
[nrow,ncol] = size(indata);

alfa_in  = indata(1,4:ncol-1);
ialfa = 0;
alfad = alfa_in(1:end-ialfa);

h_u = indata(2:13,4:ncol-1-ialfa);
h_l = indata([2 14:24],4:ncol-1-ialfa);

h_inf = indata(25,4:ncol-1-ialfa);
h_0   = indata(26,4:ncol-1-ialfa);
h_ro  = indata(27,4:ncol-1-ialfa);
h_fl  = indata(28,4:ncol-1-ialfa);

fprintf('Angles: %s\n', mat2str(alfad));
fprintf('h_u size: %d x %d\n', size(h_u,1), size(h_u,2));
fprintf('h_l size: %d x %d\n', size(h_l,1), size(h_l,2));

% Compute cp for both surfaces
cp_u = zeros(length(xc),length(alfad));
cp_l = zeros(length(xc),length(alfad));

for k=1:length(alfad)
    cp_u(1:length(xc)-1,k) = (h_u(:,k) - h_inf(k))./(h_0(k) - h_inf(k));
    cp_l(1:length(xc)-1,k) = (h_l(:,k) - h_inf(k))./(h_0(k) - h_inf(k));

    cp_u(:,k) = [cp_u(1:length(xc)-1,k) ; (cp_u(12,k) + cp_l(12,k))/2];
    cp_l(:,k) = [cp_l(1:length(xc)-1,k) ; (cp_u(12,k) + cp_l(12,k))/2];
end

fprintf('\ncp_u at alpha=0:\n');
disp(cp_u(:,1)');
fprintf('cp_l at alpha=0:\n');
disp(cp_l(:,1)');

fprintf('Min cp overall: %.2f\n', min(cp_u(:)));
fprintf('Max cp overall: %.2f\n', max(cp_u(:)));
