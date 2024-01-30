% ------- DATA LOADING SECTION -------

% Define the paths to the files
file_paths = {
    'Ru(bpy)3 in DMSO-d6_SPACER_0.10MM.txt';
    'Ru(bpy)3 in DMSO-d6.txt';
    % ... Add as many paths as you have files
};

% Initialize an empty array of structures
data_structures = struct();

% Loop through each file
for i = 1:length(file_paths)
    % Open the file
    fileID = fopen(file_paths{i}, 'r');
    
    % Initialize metadata structure
    metadata = struct();
    
    % Read the file line by line
    line = fgetl(fileID);
    while ischar(line)
        % Check if line contains metadata (starts with '##')
        if startsWith(line, '##')
            % Extract metadata key and value
            tokens = split(line, '=');
            key = strtrim(tokens{1}(3:end)); % Remove '##' and whitespace
            value = strtrim(tokens{2});
            
            % Sanitize the key for valid field name
            key = matlab.lang.makeValidName(key);
            
            % Save to metadata structure
            metadata.(key) = value;
        else
            % If not metadata, then it's data. Break out of the loop
            break;
        end
        
        % Read the next line
        line = fgetl(fileID);
    end
    
    % Now, read the actual data
    data = fscanf(fileID, '%f %f', [2, Inf])'; % Assuming two columns of data
    
    % Close the file
    fclose(fileID);
    
    % Save metadata and data to the main structure
    data_structures(i).metadata = metadata;
    data_structures(i).data = data;
end

% ------- PLOTTING SECTION -------

% Calculate the number of datasets
num_datasets = length(data_structures);


% Calculate the number of rows for the subplots
num_rows = ceil(2 * num_datasets / 2); % Multiply num_datasets by 2 to account for absorbance plots

% Create a figure and make it fullscreen
fig = figure('Units', 'normalized', 'OuterPosition', [0 0 1 1]);

% Adjust font sizes based on the number of datasets
if num_datasets > 6
    axis_font_size = 8;
    title_font_size = 10;
else
    axis_font_size = 10;
    title_font_size = 12;
end

% Loop through each dataset and plot the data
for i = 1:num_datasets
    % Create a subplot
    ax = subplot(num_rows, 2, i);
    
    % Extract data for the current dataset
    data = data_structures(i).data;
    x_data = data(:, 1);
    y_data = data(:, 2);
    
    % Plot the data
    plot(ax, x_data, y_data);
    
    % Set x & y axis limits and invert x-axis direction
    xlim([min(x_data) max(x_data)]);
    ylim([min(y_data) max(y_data)]);
    set(ax, 'XDir', 'reverse');
    
    % Extract filename from the path for the title
    [~, filename, ~] = fileparts(file_paths{i});
    title_str = ['Original Data: ' filename];
    title(title_str, 'FontSize', title_font_size);
    
    x_label = data_structures(i).metadata.XUNITS;
    y_label = data_structures(i).metadata.YUNITS;
    xlabel(x_label, 'FontSize', axis_font_size);
    ylabel(y_label, 'FontSize', axis_font_size);
    ax.FontSize = axis_font_size;
    grid on;
    
    % Add a button below the subplot
    button_pos = [ax.Position(1) ax.Position(2)-0.09 ax.Position(3) 0.03];
    
    % Calculate absorbance
    absorbance = -log10(y_data);
    
    % Create a subplot for absorbance
    ax_absorbance = subplot(num_rows, 2, num_datasets + i); % Note the change in num_rows multiplier
    % Plot the absorbance data
    plot(ax_absorbance, x_data, absorbance);
    % Set x & y axis limits and invert x-axis direction
    xlim([min(x_data) max(x_data)]);
    ylim([min(absorbance) max(absorbance)]);
    set(ax_absorbance, 'XDir', 'reverse');
    % Extract filename from the path for the title
    [~, filename, ~] = fileparts(file_paths{i});
    title_str_absorbance = ['Absorbance Data: ' filename];
    title(title_str_absorbance, 'FontSize', title_font_size);
    xlabel(x_label, 'FontSize', axis_font_size);
    ylabel('Absorbance', 'FontSize', axis_font_size);
    ax_absorbance.FontSize = axis_font_size;
    grid on;
    % Add a button below the subplot for absorbance
    button_pos_absorbance = [ax_absorbance.Position(1) ax_absorbance.Position(2)-0.08 ax_absorbance.Position(3) 0.03];
    uicontrol('Style', 'pushbutton', 'String', 'View Absorbance Plot', ...
              'Units', 'normalized', 'Position', button_pos_absorbance, ...
              'Callback', {@showPlot, x_data, absorbance, title_str_absorbance, x_label, 'Absorbance'});
uicontrol('Style', 'pushbutton', 'String', 'View Plot', ...
              'Units', 'normalized', 'Position', button_pos, ...
              'Callback', {@showPlot, x_data, y_data, title_str, x_label, y_label});
end

% Provide a super title for the entire figure
sgtitle('All Datasets');

% ------- FUNCTION DEFINITIONS -------

function showPlot(~, ~, x_data, y_data, title_str, x_label, y_label)
    figure; % Create a new figure
    plot(x_data, y_data);
    xlim([min(x_data) max(x_data)]); % Apply dynamic rescaling
    ylim([min(y_data) max(y_data)]);
    set(gca, 'XDir', 'reverse'); % Invert x-axis direction
    title(title_str);
    xlabel(x_label);
    ylabel(y_label);
    grid on;
end