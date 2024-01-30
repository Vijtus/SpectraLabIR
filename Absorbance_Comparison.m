function main()
    % Define the range of interest
    wavelength_min = 400;
    wavelength_max = 450;

    % Load the data using the new function
    data1 = load_data('Ru(bpy)3 in DMSO solution.txt');
    data2 = load_data('Ru(bpy)3 in acetonitrile OLD solution.txt');
    data3 = load_data('Ru(bpy)3 in acetonitrile NEW solution.txt');

    % Find the indices of the data points within this range for each dataset
    indices1 = find((data1(:,1) >= wavelength_min) & (data1(:,1) <= wavelength_max));
    indices2 = find((data2(:,1) >= wavelength_min) & (data2(:,1) <= wavelength_max));
    indices3 = find((data3(:,1) >= wavelength_min) & (data3(:,1) <= wavelength_max));

    % Calculate the peak absorbance within this range for each dataset
    [~, peak1_index] = max(data1(indices1,2));
    [~, peak2_index] = max(data2(indices2,2));
    [~, peak3_index] = max(data3(indices3,2));

    peak1_wavelength = data1(indices1(peak1_index),1);
    peak2_wavelength = data2(indices2(peak2_index),1);
    peak3_wavelength = data3(indices3(peak3_index),1);

    peak1_absorbance = data1(indices1(peak1_index),2);
    peak2_absorbance = data2(indices2(peak2_index),2);
    peak3_absorbance = data3(indices3(peak3_index),2);

    % Create the plot with all datasets
    figure
    hold on

    % Plot the first dataset (DMSO solution)
    plot(data1(:,1), data1(:,2), 'blue')

    % Plot the third dataset (new acetonitrile solution), but label it as the old solution
    plot(data3(:,1), data3(:,2), 'red')

    % Plot the second dataset (old acetonitrile solution), but label it as the new solution
    plot(data2(:,1), data2(:,2), 'green')

    % Add labels and a legend
    xlabel('Wavelength (nm)')
    ylabel('Absorbance')
    title('Absorbance Spectrum')
    legend('Ru(bpy)3 in DMSO', 'Old Acetonitrile Solution', 'New Acetonitrile Solution')
    grid on

    hold off
end

% Define the function to load data
function data = load_data(file_path)
    fileID = fopen(file_path, 'r');
    tline = fgetl(fileID);
    data = [];
    while ischar(tline)
        if strcmp(tline, 'XYDATA')
            tline = fgetl(fileID);
            while ~strcmp(tline, '[Measurement Information]')
                split_line = strsplit(tline);
                if numel(split_line) == 2
                    data = [data; str2double(split_line)];
                end
                tline = fgetl(fileID);
            end
        end
        tline = fgetl(fileID);
    end
    fclose(fileID);
end