%% verify_data.m - Verify the formatted template files
indata = xlsread('GroupB2_wing.xlsx');
[nrow, ncol] = size(indata);
fprintf('Wing template size: %d x %d\n', nrow, ncol);

% Check angles
alfa_in = indata(1, 4:ncol-1);
fprintf('Angles: %s\n', mat2str(alfa_in));

% Check h_inf and h_0
h_inf = indata(25, 4:ncol-1);
h_0   = indata(26, 4:ncol-1);
nose  = indata(2, 4:ncol-1);
cp_nose_alpha0 = (nose(1) - h_inf(1)) / (h_0(1) - h_inf(1));
fprintf('h_inf(alpha=0) = %.4f\n', h_inf(1));
fprintf('h_0(alpha=0)   = %.4f\n', h_0(1));
fprintf('nose(alpha=0)  = %.4f\n', nose(1));
fprintf('cp at nose (alpha=0) = %.4f  (should be ~1.0)\n', cp_nose_alpha0);

% Check upper surface at alpha=14
k = find(alfa_in == 14);
h_u_top1 = indata(3, 3+k);
cp_top1 = (h_u_top1 - h_inf(k)) / (h_0(k) - h_inf(k));
fprintf('cp at top1 (alpha=14) = %.4f  (should be large negative)\n', cp_top1);

% Check rake template
indata2 = xlsread('GroupB2_rake.xlsx');
[nrow2, ncol2] = size(indata2);
fprintf('\nRake template size: %d x %d\n', nrow2, ncol2);
y_tot = indata2(4:27, 4)';
fprintf('y_tot range: %.0f to %.0f mm (%d points)\n', y_tot(1), y_tot(end), length(y_tot));
y_stat = indata2(28:36, 4)';
fprintf('y_stat range: %.0f to %.0f mm (%d points)\n', y_stat(1), y_stat(end), length(y_stat));
