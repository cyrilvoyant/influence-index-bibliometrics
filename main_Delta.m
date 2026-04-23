%% Delta-I distributions: KDE + CDF with Q1/Q2/Q3
clear; close all; clc;

careerFile = 'Career.xlsx';
singleFile = 'Single.xlsx';

% Read tables (keep original headers)
Tcar = readtable(careerFile, 'VariableNamingRule','preserve');
Tsin = readtable(singleFile, 'VariableNamingRule','preserve');

% ---- Column names (edit ONLY if your headers differ) ----
colInst = "Institution";
colI    = "I";      % Influence Index in both files

% Keep only needed columns, then inner-join by institution
A = Tcar(:, cellstr([colInst colI]));
B = Tsin(:, cellstr([colInst colI]));

A.Properties.VariableNames = {'Institution','I_career'};
B.Properties.VariableNames = {'Institution','I_single'};

T = innerjoin(A, B, 'Keys', 'Institution');

% Delta I
dI = T.I_single - T.I_career;
dI = dI(isfinite(dI));

% Quartiles
Q = quantile(dI, [0.25 0.50 0.75]);

% ---- Figure: 1x2 (KDE left, CDF right) ----
figure('Color','w','Position',[120 120 1100 420]);
tiledlayout(1,2,'TileSpacing','compact','Padding','compact');

% (1) KDE
nexttile;
plotKDE_withQuartiles(dI, Q, "ΔI KDE", "ΔI = I_{single} - I_{career}");

% (2) CDF
nexttile;
plotCDF_withQuartiles(dI, Q, "ΔI empirical CDF", "ΔI = I_{single} - I_{career}");

sgtitle("Distribution of ΔI (recent momentum vs historical legacy)", ...
    'FontWeight','bold', 'Color','k');

exportgraphics(gcf, 'DeltaI_KDE_CDF.pdf', ...
    'ContentType','vector', 'BackgroundColor','white');


%% -------- Local functions --------
function plotKDE_withQuartiles(x, Q, titleStr, xLabel)
    x = x(:); x = x(isfinite(x));
    if numel(x) < 10
        plot(nan,nan); return;
    end

    % Grid and KDE
    qx = quantile(x, [0.01 0.99]);
    xi = linspace(qx(1), qx(2), 400);
    % automatic bandwidth
    [f0,~,bw] = ksdensity(x, xi, 'Bandwidth','plug-in');
    
    % smoothing factor (tune between 1.2 and 1.5)
    alpha = 1.6;
    
    % smoothed KDE
    f = ksdensity(x, xi, 'Bandwidth', alpha*bw);

    plot(xi, f, 'LineWidth', 2); hold on;

    styleAxes(titleStr, xLabel, 'Density');

    % Quartile lines + annotations
    yLevels = [0.85 0.65 0.45] * max(f); % staggered
    tags = {'Q1','Q2','Q3'};
    for k = 1:3
        xq = Q(k);
        xline(xq, '--', 'LineWidth', 1.5);
        text(xq, yLevels(k), sprintf('%s = %.3f', tags{k}, xq), ...
            'HorizontalAlignment','left', 'VerticalAlignment','bottom', ...
            'Color','k', 'FontSize',10, 'BackgroundColor','w', 'Margin',2);
    end

    % n
    text(0.02, 0.05, sprintf('n = %d', numel(x)), ...
        'Units','normalized', 'Color','k', 'BackgroundColor','w', 'Margin',2);
end

function plotCDF_withQuartiles(x, Q, titleStr, xLabel)
    x = x(:); x = x(isfinite(x));
    if numel(x) < 10
        plot(nan,nan); return;
    end

    [F, X] = ecdf(x);
    plot(X, F, 'LineWidth', 2); hold on;

    styleAxes(titleStr, xLabel, 'F(x)');
    ylim([0 1]);

    % Quartile lines + annotations (y positions staggered)
    yText = [0.30 0.55 0.80];
    tags = {'Q1','Q2','Q3'};
    for k = 1:3
        xq = Q(k);
        xline(xq, '--', 'LineWidth', 1.5);
        text(xq, yText(k), sprintf('%s = %.3f', tags{k}, xq), ...
            'HorizontalAlignment','left', 'VerticalAlignment','bottom', ...
            'Color','k', 'FontSize',10, 'BackgroundColor','w', 'Margin',2);
    end

    % n
    text(0.02, 0.05, sprintf('n = %d', numel(x)), ...
        'Units','normalized', 'Color','k', 'BackgroundColor','w', 'Margin',2);
end

function styleAxes(titleStr, xLabel, yLabel)
    grid on; box on;
    set(gca, 'Color','w', 'XColor','k', 'YColor','k', 'LineWidth',1, ...
        'GridColor',[0.85 0.85 0.85], 'GridAlpha',0.35);
    title(titleStr, 'FontWeight','bold', 'Color','k');
    xlabel(xLabel, 'Color','k');
    ylabel(yLabel, 'Color','k');
end
