%% Seminarium 3 - Fråga 1: Tryckkoefficienten cp
clear all; close all;

%% Data loading
chord = 149;  % mm
Hts   = 500;  % mm

% Pressure tap positions along chord (x/c) and NACA 0018 y-coordinates
xc = [0 0.027 0.047 0.095 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1];
yc = 5*0.18*(0.2969*sqrt(xc) - 0.126*xc - 0.3516*xc.^2 + ...
    0.2843*xc.^3 - 0.1015*xc.^4);

indata  = xlsread('GroupB2_wing.xlsx');
[nrow,ncol] = size(indata);

alfa_in  = indata(1,4:ncol-1);
ialfa = 0;
alfad = alfa_in(1:end-ialfa);

% Upper surface: nose + Top 1-11 (12 measurement points)
h_u = indata(2:13,4:ncol-1-ialfa);
% Lower surface: nose + Bottom 1-11 (12 measurement points)
h_l = indata([2 14:24],4:ncol-1-ialfa);

% Reference pressures
h_inf = indata(25,4:ncol-1-ialfa);  % free stream static
h_0   = indata(26,4:ncol-1-ialfa);  % stagnation

%% Compute pressure coefficients
cp_u = zeros(length(xc),length(alfad));
cp_l = zeros(length(xc),length(alfad));

for k=1:length(alfad)
    % Upper surface cp (12 measured points)
    cp_u(1:length(xc)-1,k) = (h_u(:,k) - h_inf(k))./(h_0(k) - h_inf(k));

    % Lower surface cp (12 measured points)
    cp_l(1:length(xc)-1,k) = (h_l(:,k) - h_inf(k))./(h_0(k) - h_inf(k));

    % Trailing edge (x/c=1): average of last upper and lower points
    cp_u(:,k) = [cp_u(1:length(xc)-1,k) ; (cp_u(12,k) + cp_l(12,k))/2];
    cp_l(:,k) = [cp_l(1:length(xc)-1,k) ; (cp_u(12,k) + cp_l(12,k))/2];
end

%% Fråga 2: Beräkning av lyftkraftskoefficienten CL
% Konvertera anfallsvinkeln till radianer
alfa_rad = alfad * (pi/180);
%% Beräkning av Cn och Ct
num_alfa = length(alfad);
Cn = zeros(1, num_alfa);
Ct = zeros(1, num_alfa);

for k = 1:num_alfa
    % 1. Beräkna Cn (Normal kraftkoefficient)
    % Integrera (Cp_undre - Cp_övre) över x/c
    Cn(k) = trapz(xc, cp_l(:,k) - cp_u(:,k));
    
    % 2. Beräkna Ct (Tangentiell kraftkoefficient)
    % Vi integrerar Cp över profilens tjocklek (yc).
    % Eftersom profilen är symmetrisk använder vi yc för både övre och undre.
    % Ct = integral(Cp_u * dy/dx * dx) - integral(Cp_l * dy/dx * dx)
    
    % Enklaste sättet i MATLAB med trapz:
    Ct_u = trapz(yc, cp_u(:,k)); 
    Ct_l = trapz(yc, cp_l(:,k));
    
    % Den totala tangentiella kraften från tryck:
    Ct(k) = Ct_u + Ct_l; 
end

%% Redovisa resultat
fprintf('Alfa (deg) |   Cn    |   Ct\n');
fprintf('-----------|---------|---------\n');
for k = 1:num_alfa
    fprintf('%10.2f | %7.4f | %7.4f\n', alfad(k), Cn(k), Ct(k));
end

%% Visualisering med Bar Plot (Lämpligt för hysteres/osorterad data)
figure('Color', 'w', 'Name', 'Kraftkoefficienter per mätpunkt');

% Skapa etiketter för x-axeln som visar både index och vinkel
labels = cell(1, length(alfad));
for i = 1:length(alfad)
    labels{i} = sprintf('%d (%.1f°)', i, alfad(i));
end

% Subplot 1: Cn (Normal kraft)
subplot(2,1,1);
bar(Cn, 'FaceColor', [0 0.4470 0.7410]); % Blå staplar
set(gca, 'XTick', 1:length(alfad), 'XTickLabel', labels);
xtickangle(45);
ylabel('C_n');
title('Normal kraftkoefficient (C_n) per mätpunkt');
grid on;

% Subplot 2: Ct (Tangentiell kraft)
subplot(2,1,2);
bar(Ct, 'FaceColor', [0.8500 0.3250 0.0980]); % Röda staplar
set(gca, 'XTick', 1:length(alfad), 'XTickLabel', labels);
xtickangle(45);
ylabel('C_t');
title('Tangentiell kraftkoefficient (C_t) per mätpunkt');
grid on;

% Justera layout
sgtitle('Aerodynamiska koefficienter för varje mätpunkt');
