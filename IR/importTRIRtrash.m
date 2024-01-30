% List of filenames
filenames = {'Rubpy3Cl2_Scan_1', 'Rubpy3Cl2_Average1'}; % Add more filenames as needed

% Define zoom window for each file [x_start, x_end, y_start, y_end]
% This is where the user can easily adjust the zoom area for each dataset
zoom_windows = {
    [0.2, 0.8, 0.2, 0.8]; % Zoom window for 'Rubpy3Cl2_Scan_1'
    [0.1, 0.7, 0.1, 0.7]  % Zoom window for 'AnotherFilename'
    % ... Add more zoom windows for additional datasets
};

% Create a figure
mainFig = figure;
set(mainFig, 'Position', get(0, 'Screensize'));

for idx = 1:length(filenames)
    % Replace commas with dots in the file
    filename = filenames{idx};
    file_content = fileread(filename);
    file_content = strrep(file_content, ',', '.');
    new_filename = ['temp_file_', num2str(idx), '.txt'];
    fid = fopen(new_filename, 'w');
    fwrite(fid, file_content);
    fclose(fid);

    % Read the modified data
    data = readmatrix(new_filename);

    % Extract X, Y, and Z values
    X = data(1, 2:end);
    Y = data(2:end, 1);
    Z = data(2:end, 2:end);

    % Create the meshgrid for 3D plotting
    [X, Y] = meshgrid(X, Y);

    % Plotting the 3D graph in the first subplot
    ax1 = subplot(length(filenames), 3, (idx-1)*3 + 1);
    surf(X, Y, Z);
    colorbar;
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    title(['3D Plot of ', filename]);

    % Plotting the color contour plot in the second subplot
    ax2 = subplot(length(filenames), 3, (idx-1)*3 + 2);
    contourf(X, Y, Z, 50); % '50' specifies the number of contour levels; adjust as needed
    colorbar;
    xlabel('X');
    ylabel('Y');
    title(['Color Contour Plot of ', filename]);

    % Overlay the red rectangle on the contour plot
    zoom_window = zoom_windows{idx};
    xlims = xlim(ax2);
    ylims = ylim(ax2);
    rectangle('Position', [zoom_window(1)*xlims(2), zoom_window(3)*ylims(2), (zoom_window(2)-zoom_window(1))*xlims(2), (zoom_window(4)-zoom_window(3))*ylims(2)],...
              'EdgeColor', 'r', 'LineWidth', 1.5);

    % Plotting the zoomed-in contour plot in the third subplot
    ax3 = subplot(length(filenames), 3, idx*3);
    contourf(X, Y, Z, 50); % '50' specifies the number of contour levels; adjust as needed
    xlim([zoom_window(1)*xlims(2), zoom_window(2)*xlims(2)]);
    ylim([zoom_window(3)*ylims(2), zoom_window(4)*ylims(2)]);
    colorbar;
    xlabel('X');
    ylabel('Y');
    title(['Zoomed-In Contour Plot of ', filename]);

    % Add button for 3D plot
    pos1 = get(ax1, 'Position');
    btnWidth = 0.1; % normalized width
    btnHeight = 0.05; % normalized height
    btnX = pos1(1) + (pos1(3) - btnWidth) / 2; % centering the button with respect to the subplot
    btnY = pos1(2) - btnHeight - 0.02; % placing the button a little below the subplot
    uicontrol('Style', 'pushbutton', 'String', 'View in New Window',...
              'Units', 'normalized',...
              'Position', [btnX btnY btnWidth btnHeight],...
              'Callback', {@displaySelectedPlot, X, Y, Z, '3D'});

    % Add button for contour plot
    pos2 = get(ax2, 'Position');
    btnX = pos2(1) + (pos2(3) - btnWidth) / 2; % centering the button with respect to the subplot
    btnY = pos2(2) - btnHeight - 0.02; % placing the button a little below the subplot
    uicontrol('Style', 'pushbutton', 'String', 'View in New Window',...
          'Units', 'normalized',...
          'Position', [btnX btnY btnWidth btnHeight],...
          'Callback', {@displaySelectedPlot, X, Y, Z, 'Contour', zoom_window});

    % Add button for zoomed-in contour plot
    pos3 = get(ax3, 'Position');
    btnX = pos3(1) + (pos3(3) - btnWidth) / 2; % centering the button with respect to the subplot
    btnY = pos3(2) - btnHeight - 0.02; % placing the button a little below the subplot
    uicontrol('Style', 'pushbutton', 'String', 'View in New Window',...
          'Units', 'normalized',...
          'Position', [btnX btnY btnWidth btnHeight],...
          'Callback', {@displaySelectedPlot, X, Y, Z, 'ZoomedIn', zoom_window});

    % Optionally, delete the temporary file
    delete(new_filename);
end

% Callback function to display the selected plot in a new window
function displaySelectedPlot(~, ~, X, Y, Z, plotType, zoom_window)
    figure;
    if strcmp(plotType, '3D')
        surf(X, Y, Z);
        colorbar;
        xlabel('X');
        ylabel('Y');
        zlabel('Z');
        title('3D Plot');
    elseif strcmp(plotType, 'Contour')
        contourf(X, Y, Z, 50);
        colorbar;
        xlabel('X');
        ylabel('Y');
        title('Color Contour Plot');
        
        % Draw the red rectangle in the new window
        xlims = xlim;
        ylims = ylim;
        rectangle('Position', [zoom_window(1)*xlims(2), zoom_window(3)*ylims(2), (zoom_window(2)-zoom_window(1))*xlims(2), (zoom_window(4)-zoom_window(3))*ylims(2)], 'EdgeColor', 'r', 'LineWidth', 1.5);
    else % ZoomedIn
    contourf(X, Y, Z, 50);
    xlims = xlim;
    ylims = ylim;
    xlim([zoom_window(1)*xlims(2), zoom_window(2)*xlims(2)]);
    ylim([zoom_window(3)*ylims(2), zoom_window(4)*ylims(2)]);
    colorbar;
    xlabel('X');
    ylabel('Y');
    title('Zoomed-In Contour Plot');
    end
end