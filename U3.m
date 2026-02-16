clear all

C_N = 1:13;
C_T = 2:14;

%C_N = [];
%C_T = [];
alpha = [0, 3, 6, 9, 12, 14, 16, 18, 19, 20, 21, 16, 13];

C_L = C_N .* cos(alpha) - C_T .* sin(alpha);
C_D = C_N .* sin(alpha) + C_T .* cos(alpha);
