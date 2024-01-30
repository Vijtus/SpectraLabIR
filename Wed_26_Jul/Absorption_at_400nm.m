% Load the data
data_new = load_data('Ru(bpy)3inDMSOsolution_2507_1719.txt');
data_old = load_data('Ru(bpy)3inDMSOsolution_2507_1752.txt');
data_dmso = load_data('Ru(bpy)3inDMSOsolution_2607_0910.txt');

% Separate the data into two arrays for convenience
wavelengths_new = data_new(:, 1); absorbances_new = data_new(:, 2);
wavelengths_old = data_old(:, 1); absorbances_old = data_old(:, 2);
wavelengths_dmso = data_dmso(:, 1); absorbances_dmso = data_dmso(:, 2);

% Print the absorbance at 400nm for each solution
disp(['Absorbance at 400nm for NEW solution: ', num2str(absorbances_new(wavelengths_new == 400), '%.3f')]);
disp(['Absorbance at 400nm for OLD solution: ', num2str(absorbances_old(wavelengths_old == 400), '%.3f')]);
disp(['Absorbance at 400nm for DMSO solution: ', num2str(absorbances_dmso(wavelengths_dmso == 400), '%.3f')]);

% Graph plot and annotation
figure;
hold on;

plot(wavelengths_new, absorbances_new, 'blue');
plot(wavelengths_old, absorbances_old, 'red');
plot(wavelengths_dmso, absorbances_dmso, 'green');

xlabel('Wavelength (nm)');
ylabel('Absorbance');
title('Comparison of Absorbance Spectra');
legend({'25 Jul (After Lunch)', '25 Jul (Before Lunch)', '26 Jul (Morning)'}, 'Location', 'northwest');

% Add text to the plot
abs_new = absorbances_new(wavelengths_new == 400);
abs_old = absorbances_old(wavelengths_old == 400);
abs_dmso = absorbances_dmso(wavelengths_dmso == 400);

% Make sure to convert the absorbance to string with the desired precision before placing it on the plot
text(400, abs_new, num2str(abs_new, '%.3f'), 'Color', 'blue');
text(400, abs_old, num2str(abs_old, '%.3f'), 'Color', 'red');
text(400, abs_dmso, num2str(abs_dmso, '%.3f'), 'Color', 'green');

% Add dot markers (set 'HandleVisibility' to 'off' to hide from legend)
plot(400, abs_new, 'bo', 'HandleVisibility', 'off');
plot(400, abs_old, 'ro', 'HandleVisibility', 'off');
plot(400, abs_dmso, 'go', 'HandleVisibility', 'off');

hold off;

% Function to load the data
function data = load_data(file_path)
    fid = fopen(file_path, 'rt');
    data = [];
    tline = fgetl(fid);
    count = 1;
    while ischar(tline)
        if count > 19 % Skip the first 19 lines (header)
            numbers = sscanf(tline, '%f');
            if numel(numbers) == 2 % We expect each line to contain two numbers
                data = [data; numbers']; % Add the numbers to the data matrix
            end
        end
        count = count + 1;
        tline = fgetl(fid);
    end
    fclose(fid);
end
