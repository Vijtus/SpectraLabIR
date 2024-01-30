% -----------------------------------
% Spectral Data Analysis
% -----------------------------------
% -------------------------
% 1. Data Loading
% -------------------------
% absorption of Ru(bpy)3 in DMSO-d6.
data1 = readmatrix('Ru(bpy)3 in DMSO-d6_SPACER_0.10MM.txt');
data2 = readmatrix('Ru(bpy)3 in DMSO-d6.txt');
% -------------------------
% 2. Data Transformation
% -------------------------
% more suitable for quantitative analysis.
data_transformed1 = [data1(:,1), -log10(data1(:,2)/100)];
data_transformed2 = [data2(:,1), -log10(data2(:,2)/100)];
% -------------------------
% 3. Noise Removal Setup
% -------------------------
% Define parameters for the noise removal process.
window_size = 29; % Window size for moving variance calculation
threshold_variance1 = 1.00;
threshold_diff1 = 0.05;
threshold_variance2 = 2.0;
threshold_diff2 = 0.11;
% -------------------------
% 4. Noise Removal Execution
% -------------------------
cleaned_data1 = remove_noise_rate_of_change(data_transformed1, window_size, threshold_variance1, threshold_diff1);
cleaned_data2 = remove_noise_rate_of_change(data_transformed2, window_size, threshold_variance2, threshold_diff2);
% -------------------------
% 5. Define Custom Plot Range
% -------------------------
% relevant portions of the data are plotted.
valid_indices1 = ~isnan(cleaned_data1(:,2));
custom_range1 = [min(data_transformed1(valid_indices1,1)) max(data_transformed1(valid_indices1,1))];
valid_indices2 = ~isnan(cleaned_data2(:,2));
custom_range2 = [min(data_transformed2(valid_indices2,1)) max(data_transformed2(valid_indices2,1))];
% -------------------------
% 6. Polynomial Fitting
% -------------------------
% of the data and allows for easier analysis.
degree = 3;
for data_idx = 1:2
    if data_idx == 1; dataX = data1; cleaned_dataX = cleaned_data{1}; else; dataX = data2; cleaned_dataX = cleaned_data{2}; end
    filtered_dataX = filter_data_for_lar(cleaned_dataX);
    if data_idx == 1; data1 = dataX; else; data2 = dataX; end
end
excluded_indices2 = setdiff(cleaned_data2(:, 1), filtered_data2(:, 1));
excluded_data2 = cleaned_data2(ismember(cleaned_data2(:, 1), excluded_indices2), :);
coeffs1 = polyfit(filtered_data1(:,1), filtered_data1(:,2), degree);
coeffs2 = polyfit(filtered_data2(:,1), filtered_data2(:,2), degree);
fitted_curve1 = polyval(coeffs1, cleaned_data1(:,1));
fitted_curve2 = polyval(coeffs2, cleaned_data2(:,1));
% -------------------------
% 7. Compute Residuals
% -------------------------
residuals1 = cleaned_data1(:,2) - fitted_curve1;
residuals2 = cleaned_data2(:,2) - fitted_curve2;
% -------------------------
% 8. Data Visualization
% -------------------------
blue_color = [0 0 1];
gray_color = [0.7 0.7 0.7];
red_color = [1 0 0];
% Initialize a figure for plotting.
figure;
set(gcf, 'WindowState', 'maximized');
% Plot the original data for File 1
subplot(4,2,1);
plot(data1(:,1), data1(:,2), 'Color', blue_color);
title('Original Data - File 1');
xlabel('Wavenumber (cm^{-1})');
ylabel('Transmittance (%)');
set(gca, 'XDir','reverse'); % In spectroscopy, wns often decrease from left to right.
xlim([min(data1(:,1)) max(data1(:,1))]);
ylim([min(data1(:,2)) max(data1(:,2))]);
grid on;
create_button(gca, @viewOriginalData1, data1, blue_color, [], [], 'left');
% Plot the original data for File 2
subplot(4,2,2);
plot(data2(:,1), data2(:,2), 'Color', blue_color);
title('Original Data - File 2');
xlabel('Wavenumber (cm^{-1})');
ylabel('Transmittance (%)');
set(gca, 'XDir','reverse');
xlim([min(data2(:,1)) max(data2(:,1))]);
ylim([min(data2(:,2)) max(data2(:,2))]);
grid on;
create_button(gca, @viewOriginalData2, data2, blue_color, [], [], 'right');
subplot(4,2,3);
plot(cleaned_data1(:,1), cleaned_data1(:,2), 'Color', blue_color);
hold on; % Hold the current plot, so we can overlay additional data on top.
plot(cleaned_data1(isnan(cleaned_data1(:,2)),1), data_transformed1(isnan(cleaned_data1(:,2)),2), 'Color', gray_color);
title('Aggressive Noise Removal - File 1');
xlabel('Wavenumber (cm^{-1})');
ylabel('Absorbance');
set(gca, 'XDir','reverse');
xlim([min(data_transformed1(:,1)) max(data_transformed1(:,1))]);
ylim([min(data_transformed1(:,2)) max(data_transformed1(:,2))]);
grid on;
create_button(gca, @viewNoiseRemovedData1, cleaned_data1, blue_color, gray_color, data_transformed1, 'left');
subplot(4,2,4);
plot(cleaned_data2(:,1), cleaned_data2(:,2), 'Color', blue_color);
hold on;
plot(cleaned_data2(isnan(cleaned_data2(:,2)),1), data_transformed2(isnan(cleaned_data2(:,2)),2), 'Color', gray_color);
title('Aggressive Noise Removal - File 2');
xlabel('Wavenumber (cm^{-1})');
ylabel('Absorbance');
set(gca, 'XDir','reverse');
xlim([min(data_transformed2(:,1)) max(data_transformed2(:,1))]);
ylim([min(data_transformed2(:,2)) max(data_transformed2(:,2))]);
grid on;
create_button(gca, @viewNoiseRemovedData2, cleaned_data2, blue_color, gray_color, data_transformed2, 'right');
excluded_indices1 = setdiff(cleaned_data1(:, 1), filtered_data1(:, 1));
excluded_data1 = cleaned_data1(ismember(cleaned_data1(:, 1), excluded_indices1), :);
% Plot the polynomial fitted data for File 1
% Plot the polynomial fitted data for File 1
subplot(4,2,5);
% Plot the fitted polynomial curve first
plot(cleaned_data1(valid_indices1,1), fitted_curve1(valid_indices1), 'r', 'LineWidth', 1.5); 
hold on;
% Plot the original data over the fitted curve
valid_indices1 = ~isnan(cleaned_data1(:,2));
plot(cleaned_data1(valid_indices1,1), cleaned_data1(valid_indices1,2), 'Color', blue_color);
for i = 1:length(excluded_data1)
    current_excluded_x = excluded_data1(i, 1);
    % Find the previous valid data point
    prev_valid_x = max(cleaned_data1(valid_indices1 & cleaned_data1(:,1) < current_excluded_x, 1));
    next_valid_x = min(cleaned_data1(valid_indices1 & cleaned_data1(:,1) > current_excluded_x, 1));
    % Plot gray lines to connect the excluded data points to the neighboring valid data points
    if ~isempty(prev_valid_x)
        plot([prev_valid_x, current_excluded_x], [cleaned_data1(cleaned_data1(:,1)==prev_valid_x, 2), excluded_data1(i, 2)], '-', 'Color', gray_color, 'LineWidth', 1);
    end
    if ~isempty(next_valid_x)
        plot([current_excluded_x, next_valid_x], [excluded_data1(i, 2), cleaned_data1(cleaned_data1(:,1)==next_valid_x, 2)], '-', 'Color', gray_color, 'LineWidth', 1);
    end
end
title('LAR Fitted Polynomial - File 1');
xlabel('Wavenumber (cm^{-1})');
ylabel('Absorbance');
set(gca, 'XDir','reverse');
xlim([min(cleaned_data1(valid_indices1,1)) max(cleaned_data1(valid_indices1,1))]);
ylim([min(cleaned_data1(valid_indices1,2)) max(cleaned_data1(valid_indices1,2))]);
grid on;
create_button(gca, @viewLARFittedData1, cleaned_data1, blue_color, 'red', fitted_curve1, 'left');
subplot(4,2,6);
valid_indices2 = ~isnan(cleaned_data2(:,2));
plot(cleaned_data2(valid_indices2,1), cleaned_data2(valid_indices2,2), 'Color', blue_color);
hold on;
plot(cleaned_data2(valid_indices2,1), fitted_curve2(valid_indices2), 'r', 'LineWidth', 1.5);
for i = 1:length(excluded_data2)
    current_excluded_x = excluded_data2(i, 1);
    % Find the previous valid data point
    prev_valid_x = max(cleaned_data2(valid_indices2 & cleaned_data2(:,1) < current_excluded_x, 1));
    next_valid_x = min(cleaned_data2(valid_indices2 & cleaned_data2(:,1) > current_excluded_x, 1));
    % Plot gray lines to connect the excluded data points to the neighboring valid data points
    if ~isempty(prev_valid_x)
        plot([prev_valid_x, current_excluded_x], [cleaned_data2(cleaned_data2(:,1)==prev_valid_x, 2), excluded_data2(i, 2)], '-', 'Color', gray_color, 'LineWidth', 1);
    end
    if ~isempty(next_valid_x)
        plot([current_excluded_x, next_valid_x], [excluded_data2(i, 2), cleaned_data2(cleaned_data2(:,1)==next_valid_x, 2)], '-', 'Color', gray_color, 'LineWidth', 1);
    end
end
title('LAR Fitted Polynomial - File 2');
xlabel('Wavenumber (cm^{-1})');
ylabel('Absorbance');
set(gca, 'XDir','reverse');
xlim([min(cleaned_data2(valid_indices2,1)) max(cleaned_data2(valid_indices2,1))]);
ylim([min(cleaned_data2(valid_indices2,2)) max(cleaned_data2(valid_indices2,2))]);
grid on;
create_button(gca, @viewLARFittedData2, cleaned_data2, blue_color, 'red', fitted_curve2, 'right');
subplot(4,2,7);
plot(cleaned_data1(:,1), residuals1, 'Color', blue_color);
title('Residuals after Subtracting Fitted Polynomial - File 1');
xlabel('Wavenumber (cm^{-1})');
ylabel('Residual');
set(gca, 'XDir','reverse');
xlim(custom_range1);
ylim([min(residuals1(~isnan(residuals1))) max(residuals1(~isnan(residuals1)))]);
grid on;
create_button(gca, @viewResidualsData1, cleaned_data1(:,1), blue_color, 'none', residuals1, 'left');
subplot(4,2,8);
plot(cleaned_data2(:,1), residuals2, 'Color', blue_color);
title('Residuals after Subtracting Fitted Polynomial - File 2');
xlabel('Wavenumber (cm^{-1})');
ylabel('Residual');
set(gca, 'XDir','reverse');
xlim(custom_range2);
ylim([min(residuals2(~isnan(residuals2))) max(residuals2(~isnan(residuals2)))]);
grid on;
create_button(gca, @viewResidualsData2, cleaned_data2(:,1), blue_color, 'none', residuals2, 'right');
% -------------------------
% 9. Define Helper Functions
% -------------------------
% Noise Removal Function: 
% spectral data from unwanted noise.
function cleaned_data = remove_noise_rate_of_change(data, window_size, threshold_variance, threshold_diff)
    data_clean = data;
    overall_variance = var(data(:,2));
    for i = (window_size + 1):(length(data) - window_size)
        window_variance = var(data(i-window_size:i+window_size, 2));
        % Check if the variance within the window exceeds the threshold
        if window_variance > overall_variance * threshold_variance || ...
           any(abs(diff(data(i-window_size:i+window_size, 2))) > threshold_diff)
            data_clean(i-window_size:i+window_size, 2) = NaN;
        end
    end
    cleaned_data = data_clean;
end
% Data Filtering for Polynomial Fitting:
% based on a defined threshold.
function filtered_data = filter_data_for_lar(data)
    median_val = median(data(~isnan(data(:,2)),2));
    deviation = abs(data(:,2) - median_val);
    threshold = 0.1;  % This threshold can be adjusted as per requirement
    filtered_data = data(deviation <= threshold, :);
end
% Button Creation Function:
% to view data in detail.
function create_button(ax, callback_fn, data1, color1, color2, data2, side)
    set(ax, 'Units', 'normalized');
    ax_pos = get(ax, 'Position');
    btn_width = 0.05;
    btn_height = ax_pos(4);
    if strcmp(side, 'left')
        x_pos = ax_pos(1) - btn_width - 0.04;
    elseif strcmp(side, 'right')
        x_pos = ax_pos(1) + ax_pos(3) + 0.02;
    end
    y_pos = ax_pos(2);
    % Create the button based on provided data and callback function.
    if isempty(color2) && isempty(data2)
        uicontrol('Style', 'pushbutton', 'String', 'View', ...
                  'Units', 'normalized', ...
                  'Position', [x_pos y_pos btn_width btn_height], ...
                  'Callback', @(src,event) callback_fn(data1, color1));
    else
        uicontrol('Style', 'pushbutton', 'String', 'View', ...
                  'Units', 'normalized', ...
                  'Position', [x_pos y_pos btn_width btn_height], ...
                  'Callback', @(src,event) callback_fn(data1, color1, color2, data2));
    end
end
% display the relevant data.
function viewOriginalData1(data, color)
    figure;
    plot(data(:,1), data(:,2), 'Color', color);
    title('Original Data - File 1');
    xlabel('Wavenumber (cm^{-1})');
    ylabel('Transmittance (%)');
    set(gca, 'XDir','reverse');
    xlim([min(data(:,1)) max(data(:,1))]);
    ylim([min(data(:,2)) max(data(:,2))]);
    grid on;
end
function viewOriginalData2(data, color)
    figure;
    plot(data(:,1), data(:,2), 'Color', color);
    title('Original Data - File 2');
    xlabel('Wavenumber (cm^{-1})');
    ylabel('Transmittance (%)');
    set(gca, 'XDir','reverse');
    xlim([min(data(:,1)) max(data(:,1))]);
    ylim([min(data(:,2)) max(data(:,2))]);
    grid on;
end
function viewNoiseRemovedData1(cleaned_data, color1, color2, transformed_data)
    figure;
    plot(cleaned_data(:,1), cleaned_data(:,2), 'Color', color1);
    hold on;
    plot(cleaned_data(isnan(cleaned_data(:,2)),1), transformed_data(isnan(cleaned_data(:,2)),2), 'Color', color2);
    title('Aggressive Noise Removal - File 1');
    xlabel('Wavenumber (cm^{-1})');
    ylabel('Absorbance');
    set(gca, 'XDir','reverse');
    xlim([min(cleaned_data(:,1)) max(cleaned_data(:,1))]);
    ylim([min(transformed_data(:,2)) max(transformed_data(:,2))]);
    grid on;
end
function viewNoiseRemovedData2(cleaned_data, color1, color2, transformed_data)
    figure;
    plot(cleaned_data(:,1), cleaned_data(:,2), 'Color', color1);
    hold on;
    plot(cleaned_data(isnan(cleaned_data(:,2)),1), transformed_data(isnan(cleaned_data(:,2)),2), 'Color', color2);
    title('Aggressive Noise Removal - File 2');
    xlabel('Wavenumber (cm^{-1})');
    ylabel('Absorbance');
    set(gca, 'XDir','reverse');
    xlim([min(cleaned_data(:,1)) max(cleaned_data(:,1))]);
    ylim([min(transformed_data(:,2)) max(transformed_data(:,2))]);
    grid on;
end
function viewLARFittedData1(cleaned_data, color1, color2, fitted_curve)
    figure;
    valid_indices = ~isnan(cleaned_data(:,2));
    valid_x = cleaned_data(valid_indices,1);
    valid_y = cleaned_data(valid_indices,2);
    % Plot the blue data first
    plot(valid_x, valid_y, 'Color', color1);
    hold on;
    % Plot the fitted curve
    plot(valid_x, fitted_curve(valid_indices), 'Color', color2, 'LineWidth', 1.5);
    % Obtain the excluded data indices
    filtered_data = filter_data_for_lar(cleaned_data);
    excluded_indices = setdiff(cleaned_data(:, 1), filtered_data(:, 1));
    excluded_data = cleaned_data(ismember(cleaned_data(:, 1), excluded_indices), :);
    % For each excluded data point, connect it to the previous and next valid data point
    for i = 1:length(excluded_data)
        current_excluded_x = excluded_data(i, 1);
        % Find the previous valid data point
        prev_valid_x = max(valid_x(valid_x < current_excluded_x));
        next_valid_x = min(valid_x(valid_x > current_excluded_x));
        % Plot gray lines to connect the excluded data points to the neighboring valid data points
        if ~isempty(prev_valid_x)
            plot([prev_valid_x, current_excluded_x], [cleaned_data(cleaned_data(:,1)==prev_valid_x, 2), excluded_data(i, 2)], '-', 'Color', [0.7 0.7 0.7], 'LineWidth', 1);
        end
        if ~isempty(next_valid_x)
            plot([current_excluded_x, next_valid_x], [excluded_data(i, 2), cleaned_data(cleaned_data(:,1)==next_valid_x, 2)], '-', 'Color', [0.7 0.7 0.7], 'LineWidth', 1);
        end
    end
    title('LAR Fitted Polynomial - File 1');
    xlabel('Wavenumber (cm^{-1})');
    ylabel('Absorbance');
    set(gca, 'XDir','reverse');
    xlim([min(valid_x) max(valid_x)]);
    ylim([min(valid_y) max(valid_y)]);
    grid on;
end
function viewLARFittedData2(cleaned_data, color1, color2, fitted_curve)
    figure;
    valid_indices = ~isnan(cleaned_data(:,2));
    valid_x = cleaned_data(valid_indices,1);
    valid_y = cleaned_data(valid_indices,2);
    % Plot the blue data first
    plot(valid_x, valid_y, 'Color', color1);
    hold on;
    % Plot the fitted curve
    plot(valid_x, fitted_curve(valid_indices), 'Color', color2, 'LineWidth', 1.5);
    % Obtain the excluded data indices
    filtered_data = filter_data_for_lar(cleaned_data);
    excluded_indices = setdiff(cleaned_data(:, 1), filtered_data(:, 1));
    excluded_data = cleaned_data(ismember(cleaned_data(:, 1), excluded_indices), :);
    % For each excluded data point, connect it to the previous and next valid data point
    for i = 1:length(excluded_data)
        current_excluded_x = excluded_data(i, 1);
        % Find the previous valid data point
        prev_valid_x = max(valid_x(valid_x < current_excluded_x));
        next_valid_x = min(valid_x(valid_x > current_excluded_x));
        % Plot gray lines to connect the excluded data points to the neighboring valid data points
        if ~isempty(prev_valid_x)
            plot([prev_valid_x, current_excluded_x], [cleaned_data(cleaned_data(:,1)==prev_valid_x, 2), excluded_data(i, 2)], '-', 'Color', [0.7 0.7 0.7], 'LineWidth', 1);
        end
        if ~isempty(next_valid_x)
            plot([current_excluded_x, next_valid_x], [excluded_data(i, 2), cleaned_data(cleaned_data(:,1)==next_valid_x, 2)], '-', 'Color', [0.7 0.7 0.7], 'LineWidth', 1);
        end
    end
    title('LAR Fitted Polynomial - File 2');
    xlabel('Wavenumber (cm^{-1})');
    ylabel('Absorbance');
    set(gca, 'XDir','reverse');
    xlim([min(valid_x) max(valid_x)]);
    ylim([min(valid_y) max(valid_y)]);
    grid on;
end
function viewResidualsData1(x_data, color, ~, residuals)
    figure;
    valid_indices = ~isnan(residuals);
    valid_x = x_data(valid_indices);
    valid_y = residuals(valid_indices);
    plot(valid_x, valid_y, 'Color', color);
    title('Residuals after Subtracting Fitted Polynomial - File 1');
    xlabel('Wavenumber (cm^{-1})');
    ylabel('Residual');
    set(gca, 'XDir','reverse');
    xlim([min(valid_x) max(valid_x)]);
    ylim([min(valid_y) max(valid_y)]);
    grid on;
end
function viewResidualsData2(x_data, color, ~, residuals)
    figure;
    valid_indices = ~isnan(residuals);
    valid_x = x_data(valid_indices);
    valid_y = residuals(valid_indices);
    plot(valid_x, valid_y, 'Color', color);
    title('Residuals after Subtracting Fitted Polynomial - File 2');
    xlabel('Wavenumber (cm^{-1})');
    ylabel('Residual');
    set(gca, 'XDir','reverse');
    xlim([min(valid_x) max(valid_x)]);
    ylim([min(valid_y) max(valid_y)]);
    grid on;
end