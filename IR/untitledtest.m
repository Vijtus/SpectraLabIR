% Replace commas with dots in the file
filename = 'Rubpy3Cl2_Scan_1';
file_content = fileread(filename);
file_content = strrep(file_content, ',', '.');
new_filename = 'temp_file.txt';
fid = fopen(new_filename, 'w');
fwrite(fid, file_content);
fclose(fid);

% Read the modified data
data = dlmread(new_filename, '\t');

% Extract X, Y, and Z values
X = data(1, :);
Y = data(2:end, 1);
Z = data(2:end, 2:end);

% Check dimensions and trim if necessary
if size(Z, 2) < length(X)
    X = X(1:size(Z, 2));
end
if size(Z, 1) < length(Y)
    Y = Y(1:size(Z, 1));
end

% Create the meshgrid for 3D plotting
[X, Y] = meshgrid(X, Y);

% Plotting the 3D graph
figure;
surf(X, Y, Z);
colorbar;
xlabel('X');
ylabel('Y');
zlabel('Z');
title('3D Plot of the Data');

% Optionally, delete the temporary file
delete(new_filename);
