clear; clc;

% Riemann Sum Animation Script

% Prompt user for inputs
func = input('Enter function as a string (e.g., ''sin(x)'', ''x.^2''): ', 's');
func = strrep(func, '^', '.^'); % Ensure vectorized operations
func = strrep(func, '*', '.*');
func = strrep(func, '/', './');

a = input('Enter lower boundary (a): ');
b = input('Enter upper boundary (b): ');

while true
    N = input('Enter number of subdivisions (N, positive integer): ');
    if isnumeric(N) && N > 0 && mod(N,1) == 0
        break;
    else
        disp('Error: N must be a positive integer.');
    end
end

valid_methods = {'Left', 'Right', 'Midpoint', 'Trapezoidal'};
while true
    method = input('Enter method (Left, Right, Midpoint, Trapezoidal): ', 's');
    if ismember(method, valid_methods)
        break;
    else
        disp('Error: Invalid method. Choose Left, Right, Midpoint, or Trapezoidal.');
    end
end

f = str2func(['@(x) ' func]); % Convert string to function handle
x = linspace(a, b, 1000); % Fine grid for function plotting
y = f(x);
dx = (b - a) / N; % Width of each subinterval

figure;
hold on;
fplot(f, [a, b], 'b', 'LineWidth', 2);
xlabel('x'); ylabel('f(x)');
title(['Riemann Sum Approximation using ', method]);
grid on;
axis([a-0.1 b+0.1 min(0, min(y))-1 max(y)+1]);

% Store rectangles/trapezoids for animation
rects = gobjects(1, N);

for i = 1:N
    if strcmp(method, 'Left')
        xi = a + (i-1)*dx; % Left edge of rectangle
        height = f(xi);
        x_rect = [xi, xi, xi+dx, xi+dx];
        y_rect = [0, height, height, 0];
    elseif strcmp(method, 'Right')
        xi = a + i*dx; % Right edge of rectangle
        height = f(xi);
        x_rect = [xi-dx, xi-dx, xi, xi];
        y_rect = [0, height, height, 0];
    elseif strcmp(method, 'Midpoint')
        xi = a + (i-0.5)*dx; % Midpoint of rectangle
        height = f(xi);
        x_rect = [xi-dx/2, xi-dx/2, xi+dx/2, xi+dx/2];
        y_rect = [0, height, height, 0];
    elseif strcmp(method, 'Trapezoidal')
        x1 = a + (i-1)*dx;
        x2 = x1 + dx;
        y1 = f(x1);
        y2 = f(x2);
        x_rect = [x1, x1, x2, x2];
        y_rect = [0, y1, y2, 0];
    end
    
    % Store rectangles but do not display yet
    rects(i) = fill(x_rect, [0, 0, 0, 0], 'g', 'FaceAlpha', 0.5);
end

total_frames = 30;
for frame = 1:total_frames
    for i = 1:N
        thisFrame = (frame / total_frames)^2 * (3 - 2 * (frame / total_frames));
        if strcmp(method, 'Trapezoidal')
            x1 = a + (i-1)*dx;
            x2 = x1 + dx;
            y1 = f(x1);
            y2 = f(x2);
            new_y = [0, y1 * thisFrame, y2 * thisFrame, 0];
        elseif strcmp(method, 'Right')
            xi = a + i * dx;
            height = f(xi);
            new_y = [0, height * thisFrame, height * thisFrame, 0];
        elseif strcmp(method, 'Midpoint')
            xi = a + (i - 0.5) * dx;
            height = f(xi);
            new_y = [0, height * thisFrame, height * thisFrame, 0];
        else
            xi = a + (i-1) * dx;
            height = f(xi);
            new_y = [0, height * thisFrame, height * thisFrame, 0];
        end
        
        set(rects(i), 'YData', new_y);
    end
    pause(0.02);
end

hold off;
