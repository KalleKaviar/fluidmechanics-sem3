clear all; close all;
% kordan p? vingprofilen (mm)
chord = 149;
% h?jden p? m?tstr?ckan
Hts = 500;
% tryckh?lens placering l?ngs kordan + sista punkten (x/c)
xc = [0 0.027 0.047 0.095 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1];
% motsvarande y-koordinater
yc = 5*0.18*(0.2969*sqrt(xc) - 0.126*xc - 0.3516*xc.^2 + ...
0.2843*xc.^3 - 0.1015*xc.^4);
% l?s in m?tdata
%idata = xlsread('protokollsid1_ex1.xls');
indata = xlsread('sh1_gr_16.xls');
indata2 = xlsread('protokollsid2_ex1.xls');
[nrow,ncol] = size(indata);
% extrahera anfallsvinklar
alfa_in = indata(1,4:ncol-1);
% ibland ?r de sista elementen i vektorn alfa_in 'NAN'
% s?tt is?fall ialfa till antal NAN-element
ialfa = 0;
alfad = alfa_in(1:end-ialfa);
%-----------------------------------------------------------------------------
% Sem 2 - tryckfrdelning runt vingen
%-----------------------------------------------------------------------------
% extrahera m?tningar av ?versidan och undersidan
h_u = indata(2:13,4:ncol-1-ialfa);
h_l = indata([2 14:24],4:ncol-1-ialfa);
% extrahera andra m?tningar
h_inf = indata(25,4:ncol-1-ialfa);
h_0 = indata(26,4:ncol-1-ialfa);
h_ro = indata(27,4:ncol-1-ialfa);
h_fl = indata(28,4:ncol-1-ialfa);
% Om vingprofilen vinklas ned?t (ist?llet f?r upp?t) under laborationen
% blir lyftkraften riktad ned?t (ist?llet f?r upp?t), vilket brukar skapa
% frvirring. Om vingprofilen ?r riktad ?t "r?tt" h?ll, kan ni kommentera
% bort tv? fljande rader.
%h_temp = h_u; h_u = h_l; h_l = h_temp;
%h_temp = h_ro; h_ro = h_fl; h_fl = h_temp;
% definiera matriser d?r kolumn 'i' inneh?ller tryckkoefficient f?r
% anfallsvinkeln 'i'
cp_u = zeros(length(xc),length(alfad));
cp_l = zeros(length(xc),length(alfad));
% Loopa ?ver anfallsvinklar fr ber?kning av tryckkoefficienten
for k=1:length(alfad)
% ber?kning av tryckkoefficienten f?r anfallsvinkel 'k' (ovansidan)
cp_u(1:length(xc)-1,k) = (h_u(:,k) - h_inf(k))./(h_0(k) - h_inf(k));
% ****** ni ska ber?kna tryckkoefficienten p? undersidan (cp_l) *****
% sista punkten (x/c=1) har vi inte m?tv?rden, s? vi tar medelv?rdet
% av de tv? sista punkterna
cp_u(:,k) = [cp_u(1:length(xc)-1,k) ; (cp_u(12,k) + cp_l(12,k))/2];
cp_l(:,k) = [cp_l(1:length(xc)-1,k) ; (cp_u(12,k) + cp_l(12,k))/2];
end
% ber?kning av normalkraftskoefficienten (C_{N,p}).
% Se integralerna (26) och (27) i lab PMet.
% Numeriskt integrering kan g?ras med trapezoidregeln
C_Np = trapz(xc,cp_l-cp_u);
% ******* ni ska r?kna ut tangentialkraftskoefficientern (C_Tp) ********
% ******* ni ska r?kna ut motst?nd- och lyftkraft (C_Dp och C_Lp) ********
% ******* plotta (1-cp_l) och (1-cp_u) som funktion av xc f?r varje anfallsvinkel
% ******* plotta kurva med $C_{T,p}$, som funktion av anfallsvinkeln
% ******* plotta kurva med $C_{D,p}$, som funktion av anfallsvinkeln
% ******* plotta kurva med $C_{L,p}$, som funktion av anfallsvinkeln