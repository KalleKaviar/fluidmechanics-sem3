%% format_data.m
% Reads raw data from GroupB2.xlsx and creates the formatted template files
% that SG1217_Projekt.m expects.
%
% Raw data layout (each row = one angle of attack, 13 rows x 67 cols):
%   Col  7 (G):     Alpha (angle of attack)
%   Col  8 (H):     Nose
%   Col  9-19 (I-S):   Top 1-11 (upper surface)
%   Col 20-30 (T-AD):  Bottom 1-11 (lower surface)
%   Col 31 (AE):    Floor pressure
%   Col 32 (AF):    Roof pressure
%   Col 33-56 (AG-BD): Total pressure rake (24 pitot tubes)
%   Col 57-65 (BE-BM): Static pressure rake (9 tubes)
%   Col 66 (BN):    Prandtl tube stagnation  -> h_0
%   Col 67 (BO):    Prandtl tube free stream -> h_inf
%
% See WP_Excel_guide.pdf for the mapping details.

clear all; close all;

raw = readmatrix('GroupB2.xlsx');
[nAlpha, ~] = size(raw);
fprintf('Read %d measurements from GroupB2.xlsx\n', nAlpha);

% Angles of attack
alpha = raw(:, 7)';
fprintf('Angles: %s\n', mat2str(alpha));

%% ===== Wing template (GroupB2_wing.xlsx) =====
% Format expected by SG1217_Projekt.m via xlsread:
%   Row 1 in matrix -> Excel row 3:  angle headers
%   Rows 2-13       -> Excel rows 4-15:  upper surface (nose + top 1-11)
%   Rows 14-24      -> Excel rows 16-26: lower surface (bottom 1-11)
%   Row 25          -> Excel row 27: h_inf  (free stream static)
%   Row 26          -> Excel row 28: h_0    (stagnation)
%   Row 27          -> Excel row 29: h_ro   (roof/tak)
%   Row 28          -> Excel row 30: h_fl   (floor/golv)
%
%   Columns 1-3 are labels (NaN in numeric), column 4:end-1 is data,
%   last column is trailing label.

nDataCols = nAlpha;
nCols = 3 + nDataCols + 1;   % 3 label cols + data + 1 trailing

% Build cell array (30 rows x nCols)
wing = cell(30, nCols);

% Row 3: angle of attack header
wing(3, 1:3) = {'rör nr:', 'anfallsvinkel', ''};
for i = 1:nAlpha
    wing{3, 3+i} = alpha(i);
end
wing{3, nCols} = 'rör nr';

% Helper: fill a template row from a raw column
fill_row = @(excelRow, tubeNr, label, sublabel, rawCol) ...
    deal();  % not used as anonymous, see loop below

% Row 4 (nose, tube 1) <- raw col 8 (H)
wing(4,1:3) = {1, 'nose', ''};
wing{4, nCols} = 1;

% Rows 5-15 (upper surface, tubes 2-12) <- raw cols 9-19 (I-S = Top 1-11)
for row = 5:15
    tubeNr = row - 3;
    wing(row, 1:3) = {tubeNr, 'Översida', ''};
    wing{row, nCols} = tubeNr;
end

% Rows 16-26 (lower surface, tubes 13-23) <- raw cols 20-30 (T-AD = Bottom 1-11)
for row = 16:26
    tubeNr = row - 3;
    wing(row, 1:3) = {tubeNr, 'Undersida', ''};
    wing{row, nCols} = tubeNr;
end

% Row 27 (h_inf, tube 24)
wing(27, 1:3) = {24, 'Friström', 'h_inf'};
wing{27, nCols} = 24;

% Row 28 (h_0, tube 25)
wing(28, 1:3) = {25, 'Stagnation', 'h_0'};
wing{28, nCols} = 25;

% Row 29 (roof/tak, tube 26)
wing(29, 1:3) = {26, 'Tak', 'h_inf,t'};
wing{29, nCols} = 26;

% Row 30 (floor/golv, tube 27)
wing(30, 1:3) = {27, 'Golv', 'h_inf,g'};
wing{30, nCols} = 27;

% Fill data columns (transpose: raw rows -> template columns)
for i = 1:nAlpha
    col = 3 + i;

    % Row 4: nose <- raw col 8
    wing{4, col} = raw(i, 8);

    % Rows 5-15: Top 1-11 <- raw cols 9-19
    for row = 5:15
        wing{row, col} = raw(i, 8 + (row - 4));   % cols 9..19
    end

    % Rows 16-26: Bottom 1-11 <- raw cols 20-30
    for row = 16:26
        wing{row, col} = raw(i, 19 + (row - 15));  % cols 20..30
    end

    % Row 27: h_inf <- raw col 67 (BO = free stream static)
    wing{27, col} = raw(i, 67);

    % Row 28: h_0 <- raw col 66 (BN = stagnation)
    wing{28, col} = raw(i, 66);

    % Row 29: roof <- raw col 32 (AF)
    wing{29, col} = raw(i, 32);

    % Row 30: floor <- raw col 31 (AE)
    wing{30, col} = raw(i, 31);
end

writecell(wing, 'GroupB2_wing.xlsx');
fprintf('Wing template saved to GroupB2_wing.xlsx\n');

%% ===== Rake template (GroupB2_rake.xlsx) =====
% Format expected by SG1217_Projekt.m via xlsread:
%   Row 1 in matrix -> Excel row 3:  angle headers
%   Row 2           -> Excel row 4:  h_inf (free stream)
%   Row 3           -> Excel row 5:  h_0 (stagnation)
%   Rows 4-27       -> Excel rows 6-29: total pressure rake (24 tubes)
%   Rows 28-36      -> Excel rows 30-38: static pressure rake (9 tubes)
%
%   Column 4 = y-coordinates (mm), columns 5+ = data

% y-coordinates for total pressure rake (24 tubes, 155 to -185 mm)
% 20 mm spacing at edges, 10 mm in the wake region
y_tot = [155 135 115 95 75 55 45 35 25 15 5 -5 ...
         -15 -25 -35 -45 -55 -65 -85 -105 -125 -145 -165 -185];

% y-coordinates for static pressure rake (9 tubes, 185 to -155 mm)
% 40 mm uniform spacing
y_stat = [185 145 105 65 25 -15 -55 -95 -155];

nRakeCols = 4 + nAlpha + 1;  % 3 label + 1 y-coord + data + 1 trailing
rake = cell(38, nRakeCols);

% Row 3: header
rake(3, 1:4) = {'rör nr:', 'anfallsvinkel', 'mm', ''};
for i = 1:nAlpha
    rake{3, 4+i} = alpha(i);
end
rake{3, nRakeCols} = 'rör nr';

% Row 4: h_inf (tube 1)
rake(4, 1:4) = {1, 'h_inf', '', ''};
rake{4, nRakeCols} = 1;

% Row 5: h_0 (tube 2)
rake(5, 1:4) = {2, 'h_0', '', ''};
rake{5, nRakeCols} = 2;

% Rows 6-29: total pressure rake (tubes 3-26)
for row = 6:29
    idx = row - 5;  % 1 to 24
    tubeNr = row - 3;
    rake{row, 1} = tubeNr;
    rake{row, 2} = 'h_tot';
    rake{row, 3} = sprintf('y=%d', y_tot(idx));
    rake{row, 4} = y_tot(idx);
    rake{row, nRakeCols} = tubeNr;
end

% Rows 30-38: static pressure rake (tubes 27-35)
for row = 30:38
    idx = row - 29;  % 1 to 9
    tubeNr = row - 3;
    rake{row, 1} = tubeNr;
    rake{row, 2} = 'h_stat';
    rake{row, 3} = sprintf('y=%d', y_stat(idx));
    rake{row, 4} = y_stat(idx);
    rake{row, nRakeCols} = tubeNr;
end

% Fill data columns
for i = 1:nAlpha
    col = 4 + i;

    % Row 4: h_inf <- raw col 67 (BO)
    rake{4, col} = raw(i, 67);

    % Row 5: h_0 <- raw col 66 (BN)
    rake{5, col} = raw(i, 66);

    % Rows 6-29: total pressure <- raw cols 33-56 (AG-BD)
    for row = 6:29
        rake{row, col} = raw(i, 32 + (row - 5));  % cols 33..56
    end

    % Rows 30-38: static pressure <- raw cols 57-65 (BE-BM)
    for row = 30:38
        rake{row, col} = raw(i, 56 + (row - 29));  % cols 57..65
    end
end

writecell(rake, 'GroupB2_rake.xlsx');
fprintf('Rake template saved to GroupB2_rake.xlsx\n');

fprintf('\nDone! Now update SG1217_Projekt.m to read from:\n');
fprintf('  indata  = xlsread(''GroupB2_wing.xlsx'');\n');
fprintf('  indata2 = xlsread(''GroupB2_rake.xlsx'');\n');
