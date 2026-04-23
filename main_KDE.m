%% Influence Index distributions (Career vs Single) - 2x2 panel with KDE
% - Top row: Ratio p = X/N
% - Bottom row: I = log2(p/p0)
% - Left column: Career
% - Right column: Single
% - Within each subplot: KDE for mean (solid), low/high (dashed)

clear; close all; clc;

%% Parameters
p0 = 0.02;                % baseline
bwMethod = 'scott';        % KDE bandwidth rule ('scott','silverman' or numeric)
minN_for_plot = 1;         % optional filter by N if you want (e.g., 30)
doFilterByN = false;       % set true if you want to exclude tiny denominators
exportPNG = false;         % set true to export figure
bwMethod = 'plug-in';

careerFile = 'Career.xlsx';
singleFile = 'Single.xlsx';

%% Load data
Tcar = readtable(careerFile, 'VariableNamingRule', 'preserve');
Tsin = readtable(singleFile, 'VariableNamingRule', 'preserve');


% ---- Column name mapping (edit here if your headers differ) ----
% Expected columns (case-insensitive match recommended):
% N: 'Primary analysis authors'
% p: 'Ratio (p)' or 'Ratio'
% I: 'I'
% p_lo: 'p_lo'
% p_up: 'p_up'
% I_lo: 'I_low' or 'I_lo'
% I_up: 'I_up'
colN   = "Primary analysis authors";
colP   = "Ratio (p)";      % or "Ratio"
colI   = "I";
colPlo = "p_lo";
colPup = "p_up";
colIlo = "I_low";
colIup = "I_up";

% Robust getter (will error early if a column is missing)
getcol = @(T, name) T.(name);

% Extract
car.N   = Tcar.("Primary analysis authors");
car.p   = Tcar.("Ratio (p)");
car.I   = Tcar.("I");
car.plo = Tcar.("p_lo");
car.pup = Tcar.("p_up");
car.Ilo = Tcar.("I_low");
car.Iup = Tcar.("I_up");


sin.N   = Tsin.("Primary analysis authors");
sin.p   = Tsin.("Ratio (p)");
sin.I   = Tsin.("I");
sin.plo = Tsin.("p_lo");
sin.pup = Tsin.("p_up");
sin.Ilo = Tsin.("I_low");
sin.Iup = Tsin.("I_up");

%% Optional sanity checks (highly recommended)
% Recompute I from p and compare (to catch base mistakes)
car.I_chk = log2(car.p./p0);
sin.I_chk = log2(sin.p./p0);

car.maxAbsErrI = max(abs(car.I - car.I_chk), [], 'omitnan');
sin.maxAbsErrI = max(abs(sin.I - sin.I_chk), [], 'omitnan');

fprintf('Career: max |I - log2(p/p0)| = %.3g\n', car.maxAbsErrI);
fprintf('Single: max |I - log2(p/p0)| = %.3g\n', sin.maxAbsErrI);

%% Filtering & cleaning
cleanTriplet = @(N, m, lo, up) deal( ...
    N(:), ...
    m(:), ...
    lo(:), ...
    up(:));

[car.N, car.p,  car.plo, car.pup] = cleanTriplet(car.N, car.p,  car.plo, car.pup);
[car.N, car.I,  car.Ilo, car.Iup] = cleanTriplet(car.N, car.I,  car.Ilo, car.Iup);
[sin.N, sin.p,  sin.plo, sin.pup] = cleanTriplet(sin.N, sin.p,  sin.plo, sin.pup);
[sin.N, sin.I,  sin.Ilo, sin.Iup] = cleanTriplet(sin.N, sin.I,  sin.Ilo, sin.Iup);

if doFilterByN
    fcar = car.N >= minN_for_plot;
    fsin = sin.N >= minN_for_plot;

    car.p   = car.p(fcar);   car.plo = car.plo(fcar); car.pup = car.pup(fcar);
    car.I   = car.I(fcar);   car.Ilo = car.Ilo(fcar); car.Iup = car.Iup(fcar);

    sin.p   = sin.p(fsin);   sin.plo = sin.plo(fsin); sin.pup = sin.pup(fsin);
    sin.I   = sin.I(fsin);   sin.Ilo = sin.Ilo(fsin); sin.Iup = sin.Iup(fsin);
end

% Drop NaNs / invalids
valid = @(x) x(isfinite(x));

car.p   = valid(car.p);   car.plo = valid(car.plo); car.pup = valid(car.pup);
car.I   = valid(car.I);   car.Ilo = valid(car.Ilo); car.Iup = valid(car.Iup);
sin.p   = valid(sin.p);   sin.plo = valid(sin.plo); sin.pup = valid(sin.pup);
sin.I   = valid(sin.I);   sin.Ilo = valid(sin.Ilo); sin.Iup = valid(sin.Iup);

%% Plot settings
figure('Color','w','Position',[100 100 1100 750]);

tiledlayout(2,2,'TileSpacing','compact','Padding','compact');

% Helper: KDE plot (mean/low/up)
plotKDE3 = @(xMean, xLo, xUp, xLabel, titleStr) localPlotKDE3(xMean, xLo, xUp, xLabel, titleStr, bwMethod);

% --- (1,1) Career ratio p
nexttile(1);
plotKDE3(car.p, car.plo, car.pup, 'Ratio p = X/N', 'Career: Ratio');

% --- (1,2) Single ratio p
nexttile(2);
plotKDE3(sin.p, sin.plo, sin.pup, 'Ratio p = X/N', 'Single-year: Ratio');

% --- (2,1) Career I
nexttile(3);
plotKDE3(car.I, car.Ilo, car.Iup, sprintf('I = log_2(p/%.2f)', p0), 'Career: Influence Index');

% --- (2,2) Single I
nexttile(4);
plotKDE3(sin.I, sin.Ilo, sin.Iup, sprintf('I = log_2(p/%.2f)', p0), 'Single-year: Influence Index');

% Global title
sgtitle('Institutional influence distributions (Career vs Single-year)', 'FontWeight','bold');

if exportPNG
    exportgraphics(gcf, 'Influence_KDE_2x2.png', 'Resolution', 300);
end

%% ---- Local function (at end of script) ----
function localPlotKDE3(xMean, xLo, xUp, xLabel, titleStr, bwMethod)
meanColor = [0 0.45 0.74];        % bleu foncé
lowColor  = [0.6 0.75 0.9];       % bleu clair
upColor   = [0.95 0.7 0.5];       % orange clair
alphaFill = 0.30;

    if numel(xMean) < 5
        plot(nan, nan);
        title(titleStr, 'Color','k');
        xlabel(xLabel, 'Color','k');
        ylabel('Density', 'Color','k');
        set(gca,'Color','w','XColor','k','YColor','k');
        return;
    end

    allx = [xMean(:); xLo(:); xUp(:)];
    q = quantile(allx, [0.01 0.99]);
    xi = linspace(q(1), q(2), 400);

    fM = ksdensity(xMean, xi, 'Bandwidth', bwMethod);
    fL = ksdensity(xLo,   xi, 'Bandwidth', bwMethod);
    fU = ksdensity(xUp,   xi, 'Bandwidth', bwMethod);

    mainColor = [0 0.45 0.74];
    fillAlpha = 0.25;

    hold on;

    % --- Low uncertainty (lower bound)
    fill([xi fliplr(xi)], ...
         [zeros(size(fL)) fliplr(fL)], ...
         lowColor, ...
         'FaceAlpha', alphaFill, ...
         'EdgeColor','none');
    
    % --- Up uncertainty (upper bound)
    fill([xi fliplr(xi)], ...
         [zeros(size(fU)) fliplr(fU)], ...
         upColor, ...
         'FaceAlpha', alphaFill, ...
         'EdgeColor','none');
    
    % --- Mean KDE (on top)
    plot(xi, fM, 'Color', meanColor, 'LineWidth', 2);


    plot(xi, fM, 'Color', meanColor, 'LineWidth', 2);

    grid on;
    set(gca, ...
        'Color','w', ...
        'XColor','k', ...
        'YColor','k', ...
        'LineWidth',1, ...
        'GridColor',[0.8 0.8 0.8], ...
        'GridAlpha',0.3);

    box on;

    title(titleStr, 'FontWeight','bold', 'Color','k');
    xlabel(xLabel, 'Color','k');
    ylabel('Density', 'Color','k');

    legend({'Lower 95%','Upper 95%','Mean'}, ...
           'TextColor','k', ...
           'Box','off', ...
           'Location','best');

    xlim(q);
end
