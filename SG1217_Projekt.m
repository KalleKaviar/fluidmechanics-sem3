clear all; close all;

% kordan p? vingprofilen (mm)
chord = 149;

% h?jden p? m?tstr?ckan
Hts   = 500;

% tryckh?lens placering l?ngs kordan + sista punkten (x/c)
xc = [0 0.027 0.047 0.095 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1];

% motsvarande y-koordinater
yc = 5*0.18*(0.2969*sqrt(xc) - 0.126*xc - 0.3516*xc.^2 + ...
    0.2843*xc.^3 - 0.1015*xc.^4);

% läs in mätdata (formaterade med format_data.m från GroupB2.xlsx)
indata  = xlsread('GroupB2_wing.xlsx');
indata2 = xlsread('GroupB2_rake.xlsx');
[nrow,ncol] = size(indata);

% extrahera anfallsvinklar
alfa_in  = indata(1,4:ncol-1);

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
h_0   = indata(26,4:ncol-1-ialfa);
h_ro  = indata(27,4:ncol-1-ialfa);
h_fl  = indata(28,4:ncol-1-ialfa);

% Om vingprofilen vinklas ned?t (ist?llet f?r upp?t) under laborationen
% blir lyftkraften riktad ned?t (ist?llet f?r upp?t), vilket brukar skapa
% frvirring. Om vingprofilen ?r riktad ?t "r?tt" h?ll, kan ni kommentera
% bort tv? fljande rader.
%h_temp = h_u; h_u = h_l; h_l = h_temp;
%h_temp = h_ro;    h_ro    = h_fl;    h_fl    = h_temp;

% definiera matriser d?r kolumn 'i' inneh?ller tryckkoefficient f?r
% anfallsvinkeln 'i'
cp_u = zeros(length(xc),length(alfad));
cp_l = zeros(length(xc),length(alfad));

% Loopa ?ver anfallsvinklar fr ber?kning av tryckkoefficienten
for k=1:length(alfad)
    
    % ber?kning av tryckkoefficienten f?r anfallsvinkel 'k' (ovansidan)
    cp_u(1:length(xc)-1,k) = (h_u(:,k) - h_inf(k))./(h_0(k) - h_inf(k));
    
    % ****** ni ska ber?kna  tryckkoefficienten p? undersidan (cp_l) *****

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


%-----------------------------------------------------------------------------
% Sem 4 - vakkrattan
%-----------------------------------------------------------------------------
% y-koordinater f?r totaltrycket och statiska trycket
y_tot  = indata2(4:27,4)';
y_stat = indata2(28:36,4)';

% v?tskepelare f?r totaltrycket och statiska trycket
h_tot  = indata2(4:27,5:end-ialfa-1); 
h_stat = indata2(28:36,5:end-ialfa-1);
h_stat_interp  = interp1(y_stat,h_stat,y_tot,'linear','extrap');

% v?tskepelare f?r fristr?mmen
h_02   = indata2(3,5:end-ialfa-1);
h_inf2 = indata2(2,5:end-ialfa-1);

% definiera matriser d?r kolumn 'i' inneh?ller hastighet ('u' eller u_irr)
u     = zeros(length(y_tot),length(alfad));
u_irr = zeros(length(y_tot),length(alfad));

% Loopa ?ver m?tpunkter fr ber?kning av hastighetskvot
% f?r alla anfallsvinklar
for i = 1:length(y_tot)
     %*** Ber?kna hastighetskvoten u(i)/u_inf ***
     % u(i,:) = 
     
     %*** Ber?kna hastighetskvoten u_irr(i)/u_inf ***
     %% u_irr(i,:)
    
end

% ------ Ber?kning av CD (??verkurs)-------
% Den kod som f?ljer r?knas CD ut p? mer tekniskt s?tt 
% ?n uttrycket f?r D' i f?rsta uppgiften, f?r att ta bort effekter 
% gr?nsskikt p? m?tstr?ckans golv och tak
    H = y_tot(1) - y_tot(length(y_tot));
    delta_irr_H = trapz(y_tot,u_irr-u)/H;
    
    for j = 1:length(alfad)
        up_irr(:,j)  = u_irr(:,j) - 1 - delta_irr_H(j);
    end

    t1 = delta_irr_H.^2;
    t2 = (2/H)*trapz(y_tot,u.*(u_irr-u));
    t3 = (2/H)*trapz(y_tot,up_irr.*(u_irr-u));
    t4 = (1/H)*trapz(y_tot,up_irr.^2);
    CD = -(t1 + t2 + t3 - t4)*(H/chord);
% ------ Slut p? ber?kning av CD -------


% ***** Plotta hastighetskvoten u(i)/U_inf f?r varje anfallsvinkel.  
% Var noga med skalorna i dessa diagram s? att man tydligt ser vaken.   
% Utanf?r vaken och utanf?r andra eventuella omr?den med visk?s str?mningen 
% ska denna kvot vara ungef?r lika med~1. ***

% ***** Plotta CD som funktion av anfallsvinkeln. 
% Plotta i samma figur C_Dp som du tog fram i seminarium 2 utifr?n 
% tryckf?rdelningen runt plattan *****

%-----------------------------------------------------------------------------
% Sem 5 - potentialteori
%-----------------------------------------------------------------------------
% ***** ni ska r?kna ut CD_{p,KJ}  *******


