function main()
    % Load the data
    data_new = load_data('Ru(bpy)3 in acetonitrile NEW solution.txt');
    data_old = load_data('Ru(bpy)3 in acetonitrile OLD solution.txt');
    data_dmso = load_data('Ru(bpy)3 in DMSO solution.txt');

    % Separate the data into wavelengths and absorbances
    wavelengths_new = data_new(:, 1);
    absorbances_new = data_new(:, 2);
    wavelengths_old = data_old(:, 1);
    absorbances_old = data_old(:, 2);
    wavelengths_dmso = data_dmso(:, 1);
    absorbances_dmso = data_dmso(:, 2);

    % Find the peaks near 450nm for each spectrum
    peak_new = find_peak_near(wavelengths_new, absorbances_new, 450);
    peak_old = find_peak_near(wavelengths_old, absorbances_old, 450);
    peak_dmso = find_peak_near(wavelengths_dmso, absorbances_dmso, 450);

    % Normalize the absorbances by dividing by the peak absorbance
    absorbances_new_normalized = absorbances_new / peak_new(2);
    absorbances_old_normalized = absorbances_old / peak_old(2);
    absorbances_dmso_normalized = absorbances_dmso / peak_dmso(2);

    % Shift the DMSO spectrum to the left by 5nm
    wavelengths_dmso_shifted = wavelengths_dmso - 5;

    % Create a plot
    figure
    hold on
    plot(wavelengths_new, absorbances_new_normalized, 'DisplayName', 'Ru(bpy)3 in acetonitrile NEW solution');
    plot(wavelengths_old, absorbances_old_normalized, 'DisplayName', 'Ru(bpy)3 in acetonitrile OLD solution');
    plot(wavelengths_dmso_shifted, absorbances_dmso_normalized, 'DisplayName', 'Ru(bpy)3 in DMSO solution (shifted)');

    % Set the labels and title
    xlabel('Wavelength (nm)')
    ylabel('Normalized Absorbance')
    title('Comparison of Normalized Absorbance Spectra with Shifted DMSO Spectrum')

    % Show the legend
    legend

    hold off
end

function data = load_data(file_path)
    fid = fopen(file_path);
    data = [];
    tline = fgetl(fid);
    count = 0;
    while ischar(tline)
        count = count + 1;
        if count > 19
            % Try to read two floats from the line
            numbers = sscanf(tline, '%f');
            if length(numbers) == 2
                % If successful, append to the data
                data = [data; numbers'];
            end
        end
        tline = fgetl(fid);
    end
    fclose(fid);
end

function peak = find_peak_near(wavelengths, absorbances, target)
    % Find the index of the closest wavelength to the target
    [~, closest_index] = min(abs(wavelengths - target));
    % Extract the sub-array of wavelengths within the window around the target
    window_wavelengths = wavelengths(max(1, closest_index - 10):min(closest_index + 10, length(wavelengths)));
    window_absorbances = absorbances(max(1, closest_index - 10):min(closest_index + 10, length(wavelengths)));
    % Find the index of the maximum absorbance within the window
    [~, peak_index] = max(window_absorbances);
    % Return the wavelength and absorbance at the peak
    peak = [window_wavelengths(peak_index), window_absorbances(peak_index)];
end
