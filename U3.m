C_N_raw = Cn;
C_T_raw = Ct; 
alpha_deg_raw = alfad;

[alpha_deg, sortIdx] = sort(alpha_deg_raw);
C_N = C_N_raw(sortIdx);
C_T = C_T_raw(sortIdx);

alpha_rad = alpha_deg * (pi/180); 

C_L = C_N .* cos(alpha_rad) - C_T .* sin(alpha_rad);

C_D = C_N .* sin(alpha_rad) + C_T .* cos(alpha_rad);

figure('Color', 'w', 'Name', 'Lyftkraftskurva');
plot(alpha_deg, C_L, '-o', 'LineWidth', 1.5, 'MarkerFaceColor', 'b');
xlabel('\alpha (grader)'); 
ylabel('C_{L,p}');
title('Lift');
grid on;


figure('Color', 'w', 'Name', 'Motståndskurva');
plot(alpha_deg, C_D, '-s', 'Color', [0.85 0.33 0.1], 'LineWidth', 1.5, 'MarkerFaceColor', [0.85 0.33 0.1]);
xlabel('\alpha (grader)'); 
ylabel('C_{D,p}');
title('Drag');
grid on;

figure('Color', 'w', 'Name', 'Motståndspolar');
plot(C_D, C_L, '-d', 'Color', 'k', 'LineWidth', 1.5, 'MarkerFaceColor', 'k');
xlabel('C_{D,p}'); 
ylabel('C_{L,p}');
title('Lift v. Drag');
grid on;
