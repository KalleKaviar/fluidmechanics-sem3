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

%% Q1(a): Maximum cp value
fprintf('=== Q1(a): Maximum cp ===\n');
fprintf('Max cp overall: %.4f\n', max(cp_u(:)));
[max_cp, idx] = max(cp_u(:));
[row_max, col_max] = ind2sub(size(cp_u), idx);
fprintf('  at x/c = %.3f, alpha = %.0f deg\n', xc(row_max), alfad(col_max));
fprintf('\n');

%% Q1(b): 1 - cp = (u/U_inf)^2  (derived analytically in README)

%% Q1(c): Plot 1-cp for each angle of attack
fprintf('=== Q1(c): Generating 1-cp plots ===\n');

% Create output directory for figures
if ~exist('figures', 'dir')
    mkdir('figures');
end

% Individual plots for each angle of attack
for k=1:length(alfad)
    fig = figure('Visible','off','Position',[100 100 600 450]);
    plot(xc, 1-cp_u(:,k), 'b-o', 'LineWidth', 1.5, 'MarkerSize', 5);
    hold on;
    plot(xc, 1-cp_l(:,k), 'r-s', 'LineWidth', 1.5, 'MarkerSize', 5);
    hold off;
    xlabel('x/c');
    ylabel('1 - c_p');
    title(sprintf('1 - c_p,  \\alpha = %g°', alfad(k)));
    legend('Upper surface', 'Lower surface', 'Location', 'best');
    grid on;
    ylim_max = max([1-cp_u(:,k); 1-cp_l(:,k)]) * 1.1;
    ylim_min = min([0, min([1-cp_u(:,k); 1-cp_l(:,k)]) * 1.1]);
    ylim([ylim_min, ylim_max]);
    saveas(fig, sprintf('figures/q1c_1-cp_alpha_%02d.png', round(alfad(k))));
    close(fig);
end

% Combined overview plot (all angles in subplots)
fig2 = figure('Visible','off','Position',[50 50 1400 900]);
nPlots = length(alfad);
nRows = 3; nCols = ceil(nPlots/nRows);
for k=1:nPlots
    subplot(nRows, nCols, k);
    plot(xc, 1-cp_u(:,k), 'b-o', 'LineWidth', 1.2, 'MarkerSize', 3);
    hold on;
    plot(xc, 1-cp_l(:,k), 'r-s', 'LineWidth', 1.2, 'MarkerSize', 3);
    hold off;
    xlabel('x/c'); ylabel('1-c_p');
    title(sprintf('\\alpha = %g°', alfad(k)));
    legend('Upper','Lower','Location','best','FontSize',6);
    grid on;
end
sgtitle('Pressure distribution: 1 - c_p vs x/c for all angles of attack');
saveas(fig2, 'figures/q1c_all_angles.png');
close(fig2);

fprintf('Plots saved to figures/\n');

%% Q1(d): Print summary for analysis
fprintf('\n=== Q1(d): Summary of cp distributions ===\n');
fprintf('Alpha  | min(cp_u)  | min(cp_l)  | cp_u(nose) | cp_l(nose)\n');
fprintf('-------|------------|------------|------------|----------\n');
for k=1:length(alfad)
    fprintf('%5.0f° | %10.3f | %10.3f | %10.3f | %10.3f\n', ...
        alfad(k), min(cp_u(:,k)), min(cp_l(:,k)), cp_u(1,k), cp_l(1,k));
end

% Find the minimum cp and where it occurs
[min_cp_val, min_idx] = min(cp_u(:));
[min_row, min_col] = ind2sub(size(cp_u), min_idx);
fprintf('\nMinimum cp = %.3f at x/c = %.3f, alpha = %g°\n', ...
    min_cp_val, xc(min_row), alfad(min_col));
