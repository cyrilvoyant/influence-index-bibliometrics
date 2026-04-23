%% CDF figure (Single left, Career right) with Q1/Q2/Q3 annotated
clear; close all; clc;

% Files
careerFile = 'Career.xlsx';
singleFile = 'Single.xlsx';

% Read tables (keep exact Excel headers)
Tcar = readtable(careerFile, 'VariableNamingRule','preserve');
Tsin = readtable(singleFile, 'VariableNamingRule','preserve');

% ---- Select variable to plot: "I" (recommended) or "Ratio (p)" ----
varName = "I";                 % or "Ratio (p)"
xLabel  = "I = log_2(p/0.02)"; % or "Ratio p = X/N"

% Extract + clean
x_car = Tcar.(varName);
x_sin = Tsin.(varName);
x_car = x_car(isfinite(x_car));
x_sin = x_sin(isfinite(x_sin));

% Quartiles
Q_car = quantile(x_car, [0.25 0.50 0.75]);
Q_sin = quantile(x_sin, [0.25 0.50 0.75]);

% Figure
figure('Color','w','Position',[120 120 1100 420]);
tiledlayout(1,2,'TileSpacing','compact','Padding','compact');

% Left: Single
nexttile;
plotCdfWithQuartiles(x_sin, Q_sin, 'Single-year', xLabel);

% Right: Career
nexttile;
plotCdfWithQuartiles(x_car, Q_car, 'Career', xLabel);

sgtitle("Empirical CDF with quartiles (Q1, median, Q3)", 'FontWeight','bold', 'Color','k');

% Export (vector PDF, white background)
exportgraphics(gcf, 'CDF_quartiles_1x2.pdf', 'ContentType','vector', 'BackgroundColor','white');


%% ---- Local function ----
function plotCdfWithQuartiles(x, Q, titleStr, xLabel)

    % Empirical CDF
    [F, X] = ecdf(x);

    % Plot CDF
    plot(X, F, 'LineWidth', 2); hold on;

    % Aesthetics (journal style)
    grid on; box on;
    set(gca, 'Color','w', 'XColor','k', 'YColor','k', 'LineWidth',1, ...
             'GridColor',[0.85 0.85 0.85], 'GridAlpha',0.35);
    ylim([0 1]);

    title(titleStr, 'FontWeight','bold', 'Color','k');
    xlabel(xLabel, 'Color','k');
    ylabel('F(x)', 'Color','k');

    % Quartile vertical lines + labels
    yText = [0.30 0.55 0.80]; % stagger to avoid overlap
    labels = {'Q1','Q2','Q3'};
    for k = 1:3
        xq = Q(k);
        xline(xq, '--', 'LineWidth', 1.5);

        % Place text near the curve (use yText levels)
        txt = sprintf('%s = %.3f', labels{k}, xq);
        text(xq, yText(k), txt, ...
             'VerticalAlignment','bottom', ...
             'HorizontalAlignment','left', ...
             'Color','k', 'FontSize',10, ...
             'BackgroundColor','w', 'Margin',2);
    end

    % Optional: show n
    text(0.02, 0.05, sprintf('n = %d', numel(x)), ...
         'Units','normalized', 'Color','k', ...
         'BackgroundColor','w', 'Margin',2);
end
