fileID = fopen('Ru(bpy)3 in DMSO-d6_SPACER_0.10MM.txt', 'r');
metadata_d1 = struct();
while true
    line = fgetl(fileID);
    if startsWith(line, '##') && contains(line, '=')
        field_name = strtrim(extractBetween(line, '##', '='));
        field_value = strtrim(extractAfter(line, '='));
        field_name = strrep(field_name{1}, ' ', '_');
        field_name = matlab.lang.makeValidName(field_name);
        metadata_d1.(field_name) = field_value;
    else
        break;
    end
end
fclose(fileID);
fileID = fopen('Ru(bpy)3 in DMSO-d6.txt', 'r');
metadata_d2 = struct();
while true
    line = fgetl(fileID);
    if startsWith(line, '##') && contains(line, '=')
        % Improved parsing of field_name
        field_name = strtrim(extractBetween(line, '##', '='));
        field_value = strtrim(extractAfter(line, '='));
        % Replace spaces with underscores, and ensure valid field name
        field_name = strrep(field_name{1}, ' ', '_');
        field_name = matlab.lang.makeValidName(field_name);
        metadata_d2.(field_name) = field_value;
    else
        break;
    end
end
fclose(fileID);

d1 = readmatrix('Ru(bpy)3 in DMSO-d6_SPACER_0.10MM.txt');
d2 = readmatrix('Ru(bpy)3 in DMSO-d6.txt');
A_d1 = [d1(:,1), -log10(d1(:,2)/100)];
A_d2 = [d2(:,1), -log10(d2(:,2)/100)];
win_sz = 29;
thr_var1 = 1.00;
thr_diff1 = 0.05;
thr_var2 = 2.0;
thr_diff2 = 0.11;
cln_d1 = rmv_ns_rate(A_d1, win_sz, thr_var1, thr_diff1);
cln_d2 = rmv_ns_rate(A_d2, win_sz, thr_var2, thr_diff2);
v_idx1 = ~isnan(cln_d1(:,2));
c_rng1 = [min(A_d1(v_idx1,1)) max(A_d1(v_idx1,1))];
v_idx2 = ~isnan(cln_d2(:,2));
c_rng2 = [min(A_d2(v_idx2,1)) max(A_d2(v_idx2,1))];
degree = 3;
flt_d1 = flt_data_lar(cln_d1);
flt_d2 = flt_data_lar(cln_d2);
excl_idx2 = setdiff(cln_d2(:, 1), flt_d2(:, 1));
excl_d2 = cln_d2(ismember(cln_d2(:, 1), excl_idx2), :);
coeffs1 = polyfit(flt_d1(:,1), flt_d1(:,2), degree);
coeffs2 = polyfit(flt_d2(:,1), flt_d2(:,2), degree);
fitted_crv1 = polyval(coeffs1, cln_d1(:,1));
fitted_crv2 = polyval(coeffs2, cln_d2(:,1));
residuals1 = cln_d1(:,2) - fitted_crv1;
residuals2 = cln_d2(:,2) - fitted_crv2;
blue_col = [0 0 1];
gray_col = [0.7 0.7 0.7];
red_col = [1 0 0];
figure;
set(gcf, 'WindowState', 'maximized');
subplot(4,2,1);
plot(d1(:,1), d1(:,2), 'Col', blue_col);
title('Orig Dt - File 1');
xlabel('Wnum (cm^{-1})');
ylabel('Transm (%)');
set(gca, 'XDir','reverse');
xlim([min(d1(:,1)) max(d1(:,1))]);
ylim([min(d1(:,2)) max(d1(:,2))]);
grid on;
crt_btn(gca, @viewOrigDt1, d1, blue_col, [], [], 'left');
subplot(4,2,2);
plot(d2(:,1), d2(:,2), 'Col', blue_col);
title('Orig Dt - File 2');
xlabel('Wnum (cm^{-1})');
ylabel('Transm (%)');
set(gca, 'XDir','reverse');
xlim([min(d2(:,1)) max(d2(:,1))]);
ylim([min(d2(:,2)) max(d2(:,2))]);
grid on;
crt_btn(gca, @viewOrigDt2, d2, blue_col, [], [], 'right');
subplot(4,2,3);
plot(cln_d1(:,1), cln_d1(:,2), 'Col', blue_col);
hold on;
plot(cln_d1(isnan(cln_d1(:,2)),1), A_d1(isnan(cln_d1(:,2)),2), 'Col', gray_col);
title('Aggr Ns Rmv - File 1');
xlabel('Wnum (cm^{-1})');
ylabel('Abs');
set(gca, 'XDir','reverse');
xlim([min(A_d1(:,1)) max(A_d1(:,1))]);
ylim([min(A_d1(:,2)) max(A_d1(:,2))]);
grid on;
crt_btn(gca, @viewNsRemovedDt1, cln_d1, blue_col, gray_col, A_d1, 'left');
subplot(4,2,4);
plot(cln_d2(:,1), cln_d2(:,2), 'Col', blue_col);
hold on;
plot(cln_d2(isnan(cln_d2(:,2)),1), A_d2(isnan(cln_d2(:,2)),2), 'Col', gray_col);
title('Aggr Ns Rmv - File 2');
xlabel('Wnum (cm^{-1})');
ylabel('Abs');
set(gca, 'XDir','reverse');
xlim([min(A_d2(:,1)) max(A_d2(:,1))]);
ylim([min(A_d2(:,2)) max(A_d2(:,2))]);
grid on;
crt_btn(gca, @viewNsRemovedDt2, cln_d2, blue_col, gray_col, A_d2, 'right');
excl_idx1 = setdiff(cln_d1(:, 1), flt_d1(:, 1));
excl_d1 = cln_d1(ismember(cln_d1(:, 1), excl_idx1), :);
subplot(4,2,5);
plot(cln_d1(v_idx1,1), fitted_crv1(v_idx1), 'r', 'LineWidth', 1.5); 
hold on;
v_idx1 = ~isnan(cln_d1(:,2));
plot(cln_d1(v_idx1,1), cln_d1(v_idx1,2), 'Col', blue_col);
for i = 1:length(excl_d1)
    curr_excl_x = excl_d1(i, 1);
    prev_valid_x = max(cln_d1(v_idx1 & cln_d1(:,1) < curr_excl_x, 1));
    next_valid_x = min(cln_d1(v_idx1 & cln_d1(:,1) > curr_excl_x, 1));
    if ~isempty(prev_valid_x)
        plot([prev_valid_x, curr_excl_x], [cln_d1(cln_d1(:,1)==prev_valid_x, 2), excl_d1(i, 2)], '-', 'Col', gray_col, 'LineWidth', 1);
    end
    if ~isempty(next_valid_x)
        plot([curr_excl_x, next_valid_x], [excl_d1(i, 2), cln_d1(cln_d1(:,1)==next_valid_x, 2)], '-', 'Col', gray_col, 'LineWidth', 1);
    end
end
title('LAR Fit Poly - File 1');
xlabel('Wnum (cm^{-1})');
ylabel('Abs');
set(gca, 'XDir','reverse');
xlim([min(cln_d1(v_idx1,1)) max(cln_d1(v_idx1,1))]);
ylim([min(cln_d1(v_idx1,2)) max(cln_d1(v_idx1,2))]);
grid on;
crt_btn(gca, @viewLARFitDt1, cln_d1, blue_col, 'red', fitted_crv1, 'left');
subplot(4,2,6);
v_idx2 = ~isnan(cln_d2(:,2));
plot(cln_d2(v_idx2,1), cln_d2(v_idx2,2), 'Col', blue_col);
hold on;
plot(cln_d2(v_idx2,1), fitted_crv2(v_idx2), 'r', 'LineWidth', 1.5);
for i = 1:length(excl_d2)
    curr_excl_x = excl_d2(i, 1);
    prev_valid_x = max(cln_d2(v_idx2 & cln_d2(:,1) < curr_excl_x, 1));
    next_valid_x = min(cln_d2(v_idx2 & cln_d2(:,1) > curr_excl_x, 1));
    if ~isempty(prev_valid_x)
        plot([prev_valid_x, curr_excl_x], [cln_d2(cln_d2(:,1)==prev_valid_x, 2), excl_d2(i, 2)], '-', 'Col', gray_col, 'LineWidth', 1);
    end
    if ~isempty(next_valid_x)
        plot([curr_excl_x, next_valid_x], [excl_d2(i, 2), cln_d2(cln_d2(:,1)==next_valid_x, 2)], '-', 'Col', gray_col, 'LineWidth', 1);
    end
end
title('LAR Fit Poly - File 2');
xlabel('Wnum (cm^{-1})');
ylabel('Abs');
set(gca, 'XDir','reverse');
xlim([min(cln_d2(v_idx2,1)) max(cln_d2(v_idx2,1))]);
ylim([min(cln_d2(v_idx2,2)) max(cln_d2(v_idx2,2))]);
grid on;
crt_btn(gca, @viewLARFitDt2, cln_d2, blue_col, 'red', fitted_crv2, 'right');
subplot(4,2,7);
plot(cln_d1(:,1), residuals1, 'Col', blue_col);
title('Ress after Subtr Fit Poly - File 1');
xlabel('Wnum (cm^{-1})');
ylabel('Res');
set(gca, 'XDir','reverse');
xlim(c_rng1);
ylim([min(residuals1(~isnan(residuals1))) max(residuals1(~isnan(residuals1)))]);
grid on;
crt_btn(gca, @viewRessDt1, cln_d1(:,1), blue_col, 'none', residuals1, 'left');
subplot(4,2,8);
plot(cln_d2(:,1), residuals2, 'Col', blue_col);
title('Ress after Subtr Fit Poly - File 2');
xlabel('Wnum (cm^{-1})');
ylabel('Res');
set(gca, 'XDir','reverse');
xlim(c_rng2);
ylim([min(residuals2(~isnan(residuals2))) max(residuals2(~isnan(residuals2)))]);
grid on;
crt_btn(gca, @viewRessDt2, cln_d2(:,1), blue_col, 'none', residuals2, 'right');
function c_data = rmv_ns_rate(data, win_sz, thresh_variance, thresh_diff)
    dt_cln = data;
    overall_variance = var(data(:,2));
    for i = (win_sz + 1):(length(data) - win_sz)
        window_variance = var(data(i-win_sz:i+win_sz, 2));
        if window_variance > overall_variance * thresh_variance || ...
           any(abs(diff(data(i-win_sz:i+win_sz, 2))) > thresh_diff)
            dt_cln(i-win_sz:i+win_sz, 2) = NaN;
        end
    end
    c_data = dt_cln;
end
function flt_data = flt_data_lar(data)
    median_val = median(data(~isnan(data(:,2)),2));
    deviation = abs(data(:,2) - median_val);
    thresh = 0.1;
    flt_data = data(deviation <= thresh, :);
end
function crt_btn(ax, callback_fn, d1, col1, col2, d2, side)
    set(ax, 'Units', 'norm');
    ax_pos = get(ax, 'Pos');
    btn_width = 0.05;
    btn_height = ax_pos(4);
    if strcmp(side, 'left')
        x_pos = ax_pos(1) - btn_width - 0.04;
    elseif strcmp(side, 'right')
        x_pos = ax_pos(1) + ax_pos(3) + 0.02;
    end
    y_pos = ax_pos(2);
    if isempty(col2) && isempty(d2)
        uicontrol('Style', 'pushbutton', 'String', 'View', ...
                  'Units', 'norm', ...
                  'Pos', [x_pos y_pos btn_width btn_height], ...
                  'Callback', @(src,event) callback_fn(d1, col1));
    else
        uicontrol('Style', 'pushbutton', 'String', 'View', ...
                  'Units', 'norm', ...
                  'Pos', [x_pos y_pos btn_width btn_height], ...
                  'Callback', @(src,event) callback_fn(d1, col1, col2, d2));
    end
end
function viewOrigDt1(data, col)
    figure;
    plot(data(:,1), data(:,2), 'Col', col);
    title('Orig Dt - File 1');
    xlabel('Wnum (cm^{-1})');
    ylabel('Transm (%)');
    set(gca, 'XDir','reverse');
    xlim([min(data(:,1)) max(data(:,1))]);
    ylim([min(data(:,2)) max(data(:,2))]);
    grid on;
end
function viewOrigDt2(data, col)
    figure;
    plot(data(:,1), data(:,2), 'Col', col);
    title('Orig Dt - File 2');
    xlabel('Wnum (cm^{-1})');
    ylabel('Transm (%)');
    set(gca, 'XDir','reverse');
    xlim([min(data(:,1)) max(data(:,1))]);
    ylim([min(data(:,2)) max(data(:,2))]);
    grid on;
end
function viewNsRemovedDt1(c_data, col1, col2, trans_dt)
    figure;
    plot(c_data(:,1), c_data(:,2), 'Col', col1);
    hold on;
    plot(c_data(isnan(c_data(:,2)),1), trans_dt(isnan(c_data(:,2)),2), 'Col', col2);
    title('Aggr Ns Rmv - File 1');
    xlabel('Wnum (cm^{-1})');
    ylabel('Abs');
    set(gca, 'XDir','reverse');
    xlim([min(c_data(:,1)) max(c_data(:,1))]);
    ylim([min(trans_dt(:,2)) max(trans_dt(:,2))]);
    grid on;
end
function viewNsRemovedDt2(c_data, col1, col2, trans_dt)
    figure;
    plot(c_data(:,1), c_data(:,2), 'Col', col1);
    hold on;
    plot(c_data(isnan(c_data(:,2)),1), trans_dt(isnan(c_data(:,2)),2), 'Col', col2);
    title('Aggr Ns Rmv - File 2');
    xlabel('Wnum (cm^{-1})');
    ylabel('Abs');
    set(gca, 'XDir','reverse');
    xlim([min(c_data(:,1)) max(c_data(:,1))]);
    ylim([min(trans_dt(:,2)) max(trans_dt(:,2))]);
    grid on;
end
function viewLARFitDt1(c_data, col1, col2, fitted_crv)
    figure;
    valid_indices = ~isnan(c_data(:,2));
    valid_x = c_data(valid_indices,1);
    valid_y = c_data(valid_indices,2);
    plot(valid_x, valid_y, 'Col', col1);
    hold on;
    plot(valid_x, fitted_crv(valid_indices), 'Col', col2, 'LineWidth', 1.5);
    flt_data = flt_data_lar(c_data);
    excl_idx = setdiff(c_data(:, 1), flt_data(:, 1));
    excl_data = c_data(ismember(c_data(:, 1), excl_idx), :);
    for i = 1:length(excl_data)
        curr_excl_x = excl_data(i, 1);
        prev_valid_x = max(valid_x(valid_x < curr_excl_x));
        next_valid_x = min(valid_x(valid_x > curr_excl_x));
        if ~isempty(prev_valid_x)
            plot([prev_valid_x, curr_excl_x], [c_data(c_data(:,1)==prev_valid_x, 2), excl_data(i, 2)], '-', 'Col', [0.7 0.7 0.7], 'LineWidth', 1);
        end
        if ~isempty(next_valid_x)
            plot([curr_excl_x, next_valid_x], [excl_data(i, 2), c_data(c_data(:,1)==next_valid_x, 2)], '-', 'Col', [0.7 0.7 0.7], 'LineWidth', 1);
        end
    end
    title('LAR Fit Poly - File 1');
    xlabel('Wnum (cm^{-1})');
    ylabel('Abs');
    set(gca, 'XDir','reverse');
    xlim([min(valid_x) max(valid_x)]);
    ylim([min(valid_y) max(valid_y)]);
    grid on;
end
function viewLARFitDt2(c_data, col1, col2, fitted_crv)
    figure;
    valid_indices = ~isnan(c_data(:,2));
    valid_x = c_data(valid_indices,1);
    valid_y = c_data(valid_indices,2);
    plot(valid_x, valid_y, 'Col', col1);
    hold on;
    plot(valid_x, fitted_crv(valid_indices), 'Col', col2, 'LineWidth', 1.5);
    flt_data = flt_data_lar(c_data);
    excl_idx = setdiff(c_data(:, 1), flt_data(:, 1));
    excl_data = c_data(ismember(c_data(:, 1), excl_idx), :);
    for i = 1:length(excl_data)
        curr_excl_x = excl_data(i, 1);
        prev_valid_x = max(valid_x(valid_x < curr_excl_x));
        next_valid_x = min(valid_x(valid_x > curr_excl_x));
        if ~isempty(prev_valid_x)
            plot([prev_valid_x, curr_excl_x], [c_data(c_data(:,1)==prev_valid_x, 2), excl_data(i, 2)], '-', 'Col', [0.7 0.7 0.7], 'LineWidth', 1);
        end
        if ~isempty(next_valid_x)
            plot([curr_excl_x, next_valid_x], [excl_data(i, 2), c_data(c_data(:,1)==next_valid_x, 2)], '-', 'Col', [0.7 0.7 0.7], 'LineWidth', 1);
        end
    end
    title('LAR Fit Poly - File 2');
    xlabel('Wnum (cm^{-1})');
    ylabel('Abs');
    set(gca, 'XDir','reverse');
    xlim([min(valid_x) max(valid_x)]);
    ylim([min(valid_y) max(valid_y)]);
    grid on;
end
function viewRessDt1(x_data, col, ~, residuals)
    figure;
    valid_indices = ~isnan(residuals);
    valid_x = x_data(valid_indices);
    valid_y = residuals(valid_indices);
    plot(valid_x, valid_y, 'Col', col);
    title('Ress after Subtr Fit Poly - File 1');
    xlabel('Wnum (cm^{-1})');
    ylabel('Res');
    set(gca, 'XDir','reverse');
    xlim([min(valid_x) max(valid_x)]);
    ylim([min(valid_y) max(valid_y)]);
    grid on;
end
function viewRessDt2(x_data, col, ~, residuals)
    figure;
    valid_indices = ~isnan(residuals);
    valid_x = x_data(valid_indices);
    valid_y = residuals(valid_indices);
    plot(valid_x, valid_y, 'Col', col);
    title('Ress after Subtr Fit Poly - File 2');
    xlabel('Wnum (cm^{-1})');
    ylabel('Res');
    set(gca, 'XDir','reverse');
    xlim([min(valid_x) max(valid_x)]);
    ylim([min(valid_y) max(valid_y)]);
    grid on;
end