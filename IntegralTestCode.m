clear;
clc;
% MATLAB script for Riemann Sum approximation and visualization

% Prompt user for inputs
fx_str = input('Enter function f(x): ', 's');
gx_str = input('Enter function g(x) (or "0" for area under one curve, "none" to omit): ', 's');
a = input('Enter lower bound a: ');
b = input('Enter upper bound b: ');
n = input('Enter number of rectangles (n): ');
method = input('Choose method (left, right, trapezoidal, simpsons): ', 's');

% Replace normal operators with element-wise ones
fx_str = strrep(fx_str, '^', '.^');
fx_str = strrep(fx_str, '*', '.*');
fx_str = strrep(fx_str, '/', './');

gx_str = strrep(gx_str, '^', '.^');
gx_str = strrep(gx_str, '*', '.*');
gx_str = strrep(gx_str, '/', './');

% Convert input functions to function handles
fx = str2func(['@(x) ' fx_str]);

omit_gx = strcmpi(gx_str, 'none'); % Check if g(x) should be omitted
if ~omit_gx
    gx = str2func(['@(x) ' gx_str]);
    % Handle special case for g(x) = 0
    if strcmp(gx_str, '0')
        gx = @(x) zeros(size(x)); % Set g(x) as zero function, ensuring correct size
    end
else
    gx = @(x) zeros(size(x)); % Ensure g(x) is treated as zero when omitted
end

% Generate x values
width = (b - a) / n; % Width of each rectangle
x = linspace(a, b, n+1); % Ensure correct spacing

% Compute heights based on method
if strcmpi(method, 'left')
    x_rects = x(1:end-1);
    heights_f = fx(x(1:end-1));
    heights_g = gx(x(1:end-1));
elseif strcmpi(method, 'right')
    x_rects = x(2:end);
    heights_f = fx(x(2:end));
    heights_g = gx(x(2:end));
elseif strcmpi(method, 'trapezoidal')
    x_rects = x(1:end-1);
    heights_f = (fx(x(1:end-1)) + fx(x(2:end))) / 2;
    heights_g = (gx(x(1:end-1)) + gx(x(2:end))) / 2;
elseif strcmpi(method, 'simpsons')
    x_rects = x(1:2:end-1);
    heights_f = fx(x(1:2:end-1));
    heights_g = gx(x(1:2:end-1));
    if mod(n, 2) == 1
        error('Simpson''s rule requires an even number of intervals.');
    end
else
    error('Invalid method chosen.');
end

% Ensure heights_g has the same size as heights_f
if numel(heights_g) == 1
    heights_g = heights_g * ones(size(heights_f));
end

% Compute area approximation
if strcmpi(method, 'left') || strcmpi(method, 'right')
    area_sum = sum((heights_f - heights_g) * width);
elseif strcmpi(method, 'trapezoidal')
    area_sum = sum((fx(x(1:end-1)) + fx(x(2:end))) / 2 * width);
elseif strcmpi(method, 'simpsons')
    area_sum = (width/3) * (fx(a) + 4*sum(fx(x(2:2:end-1))) + 2*sum(fx(x(3:2:end-2))) + fx(b));
end

% Plot functions
hold on;
fplot(fx, [a b], 'b', 'LineWidth', 2);
if ~omit_gx && ~strcmp(gx_str, '0')
    fplot(gx, [a b], 'r', 'LineWidth', 2);
end

% Draw rectangles or trapezoids based on method
for i = 1:length(x_rects)
    x_rect = [x_rects(i), x_rects(i)+width, x_rects(i)+width, x_rects(i)];
    y_rect = [heights_g(i), heights_g(i), heights_f(i), heights_f(i)];
    fill(x_rect, y_rect, 'g', 'EdgeColor', 'k', 'FaceAlpha', 0.5);
end

% Display results
disp(['Approximation using ', method, ' rule: ', num2str(area_sum)]);
hold off;
