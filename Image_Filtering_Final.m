function image_filter_gui
    % Create a figure for the GUI
    fig = figure('Name', 'Image Filter GUI', 'NumberTitle', 'off', 'Position', [100, 100, 800, 600]);

    % Button to load image
    uicontrol('Style', 'pushbutton', 'String', 'Load Image', 'Position', [50, 500, 150, 40], 'Callback', @loadImage);

    % Buttons for selecting filter type
    uicontrol('Style', 'pushbutton', 'String', 'Apply Gaussian Filter', 'Position', [220, 500, 150, 40], 'Callback', @applyGaussianFilter);
    uicontrol('Style', 'pushbutton', 'String', 'Apply Mean Filter', 'Position', [390, 500, 150, 40], 'Callback', @applyMeanFilter);

    % Slider for adjusting sigma (Gaussian)
    sigmaSlider = uicontrol('Style', 'slider', 'Min', 0.1, 'Max', 10, 'Value', 1, 'Position', [560, 500, 180, 40], 'Callback', @updateSigma);
    addlistener(sigmaSlider, 'Value', 'PreSet', @updateSigmaText);

    % Text to display sigma value
    sigmaText = uicontrol('Style', 'text', 'String', 'Sigma: 1', 'Position', [750, 500, 80, 40]);

    % Axes to display original and filtered images - Adjusted positions for more vertical spacing
    axOriginal = axes('Parent', fig, 'Units', 'pixels', 'Position', [50, 200, 350, 250]);
    axFiltered = axes('Parent', fig, 'Units', 'pixels', 'Position', [400, 200, 350, 250]);

    % Button to save the filtered image
    uicontrol('Style', 'pushbutton', 'String', 'Download Filtered Image', 'Position', [300, 100, 200, 40], 'Callback', @saveImage);

    % Variables to store images
    originalImage = [];
    filteredImage = [];
    currentSigma = 1;

    function loadImage(~, ~)
        [filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp', 'Image Files (*.jpg, *.png, *.bmp)'}, 'Select an Image');
        if isequal(filename, 0)
            return;
        end
        imagePath = fullfile(pathname, filename);
        originalImage = imread(imagePath);
        axes(axOriginal);
        imshow(originalImage);
        title('Original Image');
    end

    function applyGaussianFilter(~, ~)
        if isempty(originalImage)
            errordlg('Load an image first!', 'Error');
            return;
        end

        % Make the Gaussian kernel
        sigma = currentSigma;   % Standard deviation from the slider
        kernelSize = 5;         % Size of the kernel
        kernel = zeros(kernelSize, kernelSize);
        w = 0;
        for i = 1:kernelSize
            for j = 1:kernelSize
                sq_dist = (i - (kernelSize+1)/2)^2 + (j - (kernelSize+1)/2)^2;
                kernel(i,j) = exp(-sq_dist / (2 * sigma^2));
                w = w + kernel(i,j);
            end
        end
        kernel = kernel / w;

        % Apply the Gaussian filter
        [m, n, ~] = size(originalImage);
        paddedImage = padarray(originalImage, [floor(kernelSize/2), floor(kernelSize/2)], 'replicate');
        filteredImage = zeros(size(originalImage));
        
        for i = 1:m
            for j = 1:n
                for k = 1:size(originalImage,3)  % Process each color channel
                    temp = double(paddedImage(i:i+kernelSize-1, j:j+kernelSize-1, k));
                    filteredImage(i,j,k) = sum(sum(temp .* kernel));
                end
            end
        end

        filteredImage = uint8(filteredImage);
        axes(axFiltered);
        imshow(filteredImage);
        title('Gaussian Filtered Image');
        
    end

    function applyMeanFilter(~, ~)
        if isempty(originalImage)
            errordlg('Load an image first!', 'Error');
            return;
        end
        
        % Create the averaging kernel
        kernelSize = 3;
        kernel = ones(kernelSize, kernelSize) / (kernelSize^2);
        
        % Apply the mean filter
        [m, n, ~] = size(originalImage);
        paddedImage = padarray(originalImage, [1, 1], 'replicate');
        filteredImage = zeros(size(originalImage));
        
        for i = 1:m
            for j = 1:n
                for k = 1:size(originalImage,3)  % Process each color channel
                    temp = double(paddedImage(i:i+kernelSize-1, j:j+kernelSize-1, k));
                    filteredImage(i,j,k) = sum(sum(temp .* kernel));
                end
            end
        end

        filteredImage = uint8(filteredImage);
        axes(axFiltered);
        imshow(filteredImage);
        title('Mean Filtered Image');
        
    end

    function updateSigma(~, ~)
        currentSigma = sigmaSlider.Value;
        set(sigmaText, 'String', sprintf('Sigma: %.2f', currentSigma));
    end

    function updateSigmaText(~, ~)
        % Dynamically update sigma text while adjusting the slider
        set(sigmaText, 'String', sprintf('Sigma: %.2f', sigmaSlider.Value));
    end

    function saveImage(~, ~)
        if isempty(filteredImage)
            errordlg('Apply a filter and generate an image to save!', 'Error');
            return;
        end
        [file, path] = uiputfile({'*.jpg;*.png;*.bmp', 'Save Filtered Image (*.jpg, *.png, *.bmp)'}, 'Save Image');
        if isequal(file, 0)
            return;
        end
        imwrite(filteredImage, fullfile(path, file));
    end
end
