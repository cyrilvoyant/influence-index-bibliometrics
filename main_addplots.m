%% Figures 1–3: (1) Scatter I_single vs I_career, (2) Caterpillar ΔI with CI, (3) ΔI vs N and CI-width vs N
clear; close all; clc;

careerFile = 'Career.xlsx';
singleFile = 'Single.xlsx';

% Read tables with original Excel headers preserved
Tcar = readtable(careerFile, 'VariableNamingRule','preserve');
Tsin = readtable(singleFile, 'VariableNamingRule','preserve');

% ---- Robust column picking (edit candidate names only if needed) ----
colInst_candidates = {'Institution','Inst','institution'};
colN_candidates    = {'Primary analysis authors','Primary_analysis_authors','N','Eligible','Eligible authors'};
colI_candidates    = {'I','Influence Index','InfluenceIndex'};
colIlow_candidates = {'I_low','I lo','I_lo','I lower','I_lower'};
colIup_candidates  = {'I_up','I up','I_up ','I upper','I_upper'};

inst_car = pickVar(Tcar, colInst_candidates);
N_car    = pickVar(Tcar, colN_candidates);
I_car    = pickVar(Tcar, colI_candidates);
Ilow_car = pickVar(Tcar, colIlow_candidates);
Iup_car  = pickVar(Tcar, colIup_candidates);

inst_sin = pickVar(Tsin, colInst_candidates);
N_sin    = pickVar(Tsin, colN_candidates);
I_sin    = pickVar(Tsin, colI_candidates);
Ilow_sin = pickVar(Tsin, colIlow_candidates);
Iup_sin  = pickVar(Tsin, colIup_candidates);

% Build minimal tables and inner-join by institution
A = table(string(inst_car), N_car, I_car, Ilow_car, Iup_car, ...
    'VariableNames', {'Institution','N_career','I_career','I_career_low','I_career_up'});

B = table(string(inst_sin), N_sin, I_sin, Ilow_sin, Iup_sin, ...
    'VariableNames', {'Institution','N_single','I_single','I_single_low','I_single_up'});

T = innerjoin(A, B, 'Keys', 'Institution');

% Clean rows (finite)
isOK = isfinite(T.I_career) & isfinite(T.I_single) & isfinite(T.N_career) & isfinite(T.N_single) & ...
       isfinite(T.I_career_low) & isfinite(T.I_career_up) & isfinite(T.I_single_low) & isfinite(T.I_single_up);
T = T(isOK,:);

% ΔI and conservative CI propagation:
% ΔI = I_single - I_career
T.dI = T.I_single - T.I_career;
% conservative bounds: lowest = single_low - career_up ; highest = single_up - career_low
T.dI_low = T.I_single_low - T.I_career_up;
T.dI_up  = T.I_single_up  - T.I_career_low;
T.dI_CIwidth = T.dI_up - T.dI_low;

% Choose N for "precision proxy" (use single-year N by default; or min of both)
T.N_ref = T.N_single;              % change to min(T.N_single,T.N_career) if you prefer
% T.N_ref = min(T.N_single, T.N_career);

fprintf('Matched institutions: n = %d\n', height(T));

%% =========================
% FIGURE 1 — Scatter I_single vs I_career (+ y=x)
% =========================
figure('Color','w','Position',[120 120 900 650]);
ax = gca;

% Point size scaling by N_ref (robust)
N = T.N_ref;
Nq = quantile(N, [0.05 0.95]);
Nclip = min(max(N, Nq(1)), Nq(2));
sMin = 20; sMax = 120;
S = sMin + (Nclip - Nq(1)) ./ max(eps, (Nq(2)-Nq(1))) * (sMax-sMin);

% Color by ΔI
scatter(T.I_career, T.I_single, S, T.dI, 'filled', 'MarkerFaceAlpha',0.85, 'MarkerEdgeColor','none');
hold on;

% Identity line y=x
xy = [min([T.I_career;T.I_single]) max([T.I_career;T.I_single])];
plot(xy, xy, '--', 'Color',[0.25 0.25 0.25], 'LineWidth',1.5);

grid on; box on;
styleAxes(ax);
xlabel('I_{career} = log_2(p_{career}/0.02)', 'Color','k');
ylabel('I_{single} = log_2(p_{single}/0.02)', 'Color','k');
title('Institution-level scatter: I_{single} vs I_{career}', 'FontWeight','bold', 'Color','k');

cb = colorbar;
cb.Label.String = '\Delta I = I_{single} - I_{career}';
cb.Color = 'k';

text(0.02,0.04, sprintf('n = %d', height(T)), 'Units','normalized', ...
    'Color','k','BackgroundColor','w','Margin',2);

exportgraphics(gcf, 'Fig1_Scatter_I_single_vs_I_career.pdf', ...
    'ContentType','vector', 'BackgroundColor','white');


%% =========================
% FIGURE 2 — Caterpillar / forest plot of ΔI with 95% CI (sorted)
% =========================
% For readability you may not want all ~200 institutions. Set K=0 for all.
K = 50;  % show top-K by |ΔI|; set 0 to show all

T2 = T;
if K > 0 && height(T2) > K
    [~, idx] = sort(abs(T2.dI), 'descend');
    T2 = T2(idx(1:K), :);
end

% Sort by ΔI
T2 = sortrows(T2, 'dI', 'ascend');

figure('Color','w','Position',[120 120 1100 700]);
ax = gca;

y = (1:height(T2))';
x = T2.dI;
xlo = T2.dI_low;
xup = T2.dI_up;

% Horizontal CI lines
for i = 1:height(T2)
    plot([xlo(i) xup(i)], [y(i) y(i)], '-', 'Color',[0.55 0.55 0.55], 'LineWidth',1.2);
    hold on;
end

% Points
plot(x, y, 'o', 'MarkerSize',5, 'MarkerFaceColor',[0 0.45 0.74], 'MarkerEdgeColor','none');

% Reference ΔI=0
xline(0, ':', 'Color',[0.25 0.25 0.25], 'LineWidth',1.5);

grid on; box on;
styleAxes(ax);
xlabel('\Delta I = I_{single} - I_{career}', 'Color','k');
ylabel('Institutions (sorted)', 'Color','k');
titleStr = 'ΔI (single-year momentum) with conservative 95% CI';
if K > 0
    titleStr = sprintf('%s — top %d by |ΔI|', titleStr, K);
end
title(titleStr, 'FontWeight','bold', 'Color','k');

% Institution labels (optional: can be heavy; keep for K<=60)
yticks(y);
yticklabels(T2.Institution);
set(gca,'TickLabelInterpreter','none'); % preserve raw names
set(gca,'YDir','reverse');              % most negative on top (optional)

exportgraphics(gcf, 'Fig2_Caterpillar_DeltaI_CI.pdf', ...
    'ContentType','vector', 'BackgroundColor','white');


%% =========================
% FIGURE 3 — ΔI vs N (log-scale) and CI width vs N
% =========================
figure('Color','w','Position',[120 120 1100 420]);
tiledlayout(1,2,'TileSpacing','compact','Padding','compact');

% (3a) ΔI vs N
nexttile;
ax = gca;
scatter(T.N_ref, T.dI, 35, 'filled', 'MarkerFaceAlpha',0.75, 'MarkerEdgeColor','none');
hold on;
xlineRef = xline(0); %#ok<NASGU> % not needed; keep clean
yline(0, ':', 'Color',[0.25 0.25 0.25], 'LineWidth',1.5);

set(gca,'XScale','log');
grid on; box on;
styleAxes(ax);
xlabel('N (reference, log-scale)', 'Color','k');
ylabel('\Delta I', 'Color','k');
title('\Delta I vs N', 'FontWeight','bold', 'Color','k');

% (3b) CI width vs N
nexttile;
ax = gca;
scatter(T.N_ref, T.dI_CIwidth, 35, 'filled', 'MarkerFaceAlpha',0.75, 'MarkerEdgeColor','none');
set(gca,'XScale','log');
grid on; box on;
styleAxes(ax);
xlabel('N (reference, log-scale)', 'Color','k');
ylabel('CI width: \Delta I_{up} - \Delta I_{low}', 'Color','k');
title('Uncertainty (CI width) vs N', 'FontWeight','bold', 'Color','k');

exportgraphics(gcf, 'Fig3_DeltaI_vs_N_and_CIwidth.pdf', ...
    'ContentType','vector', 'BackgroundColor','white');


%% ===== Helper functions =====
function v = pickVar(T, candidates)
% pickVar: return table column matching the first candidate name found
    names = string(T.Properties.VariableNames);
    desc  = string(T.Properties.VariableDescriptions);
    candidates = string(candidates);

    % Try exact match on VariableNames
    for c = candidates
        idx = find(names == c, 1);
        if ~isempty(idx)
            v = T.(names(idx));
            return;
        end
    end

    % Try match on VariableDescriptions (when headers were modified earlier)
    for c = candidates
        idx = find(desc == c, 1);
        if ~isempty(idx)
            v = T.(names(idx));
            return;
        end
    end

    error('Missing required column. Tried: %s', strjoin(candidates, ', '));
end

function styleAxes(ax)
% styleAxes: consistent journal-like styling
    set(ax, 'Color','w', 'XColor','k', 'YColor','k', 'LineWidth',1, ...
        'GridColor',[0.85 0.85 0.85], 'GridAlpha',0.35, ...
        'FontName','Helvetica');
end
