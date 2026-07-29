function ddeplane_matlab()
% DDEPLANE_MATLAB  pplane-style interactive tool for a scalar DDE
%
%     x'(t) = f( x(t), x(t-tau) )      (one constant delay, autonomous)
%
% projected onto the plane (x(t-tau), x(t)), using dde23.
%
% Click a point (a, b) in the plane -> interpreted as the initial
% history x(-tau) = a, x(0) = b, LINEARLY INTERPOLATED in between.
% dde23 integrates forward and the resulting trajectory is drawn
% parametrically as (x(t-tau), x(t)) for t >= 0.
%
% NOTE ON THE BACKGROUND FIELD:
%   Only the vertical direction (rate of change of x(t)) is a genuine
%   function of the point (x(t-tau), x(t)); the horizontal coordinate's
%   rate of change depends on history further back and is NOT determined
%   by the point alone. So only a vertical "derivative field" is shown,
%   not a full 2D vector field -- trajectories in this projection CAN
%   cross themselves, unlike a true phase plane.
%
% Press 'q' or close the window to quit.

    % ---------------------------------------------------------------
    % 1. DEFINE YOUR SCALAR DDE HERE:  x'(t) = f(x(t), xlag)
    %    xlag = x(t - tau).  Must be autonomous (no explicit t dependence).
    % ---------------------------------------------------------------
    tau = 1.5;
    alpha = 0.75
    f   = @(x, xlag) x - x.^3 - alpha * xlag;     % example: bistable delayed feedback

    % ---------------------------------------------------------------
    % 2. WINDOW / RESOLUTION
    % ---------------------------------------------------------------
    xlims  = [-1 1];
    ylims  = [-1 1];
    tmax   = 50;
    nGrid  = 21;      % resolution of the vertical derivative field
    nPts   = 2000;    % trajectory sampling resolution

    % ---------------------------------------------------------------
    % Vertical "instantaneous derivative" field
    % ---------------------------------------------------------------
    [Xg, Yg] = meshgrid(linspace(xlims(1), xlims(2), nGrid), ...
                         linspace(ylims(1), ylims(2), nGrid));
    Dg = f(Yg, Xg);                                  % f(x, xlag), x=Yg, xlag=Xg
    scale = 0.8 * diff(ylims) / nGrid;
    Dmax = max(abs(Dg(:)));
    if Dmax == 0
        Dmax = 1;
    end
    Dn = Dg ./ Dmax * scale;

    % ---------------------------------------------------------------
    % Figure setup
    % ---------------------------------------------------------------
    fig = figure('Name', 'DDE Phase Plane (dde23)', 'NumberTitle', 'off', ...
                 'Color', 'w', 'Position', [100 100 640 620]);
    ax = axes('Parent', fig, 'Position', [0.12 0.10 0.83 0.78]);
    hold(ax, 'on');

    quiver(ax, Xg, Yg, zeros(size(Dn)), Dn, 0, ...
           'Color', [0.72 0.72 0.75], 'LineWidth', 0.75, 'MaxHeadSize', 0.5);
    plot(ax, xlims, xlims, '--', 'Color', [0.55 0.55 0.55], 'LineWidth', 1.1);

    xlim(ax, xlims); ylim(ax, ylims);
    xlabel(ax, 'x(t-\tau)', 'FontSize', 12);
    ylabel(ax, 'x(t)', 'FontSize', 12);
    title(ax, {'Click a point to set the initial history (linear interpolation)', ...
               'gray arrows = vertical derivative only  \cdot  \times marks t=\tau  \cdot  press q to quit'}, ...
          'FontSize', 10, 'FontWeight', 'normal');

    grid(ax, 'on');
    ax.GridAlpha = 0.25;
    ax.GridLineStyle = ':';
    axis(ax, 'equal');
    box(ax, 'on');
    set(ax, 'FontSize', 11, 'LineWidth', 1, 'Color', [0.985 0.985 0.99], ...
        'TickDir', 'out', 'Layer', 'top');

    quitFlag = false;
    set(fig, 'KeyPressFcn', @keyHandler);
    colors = [0 0.447 0.741; 0.850 0.325 0.098; 0.466 0.674 0.188; ...
              0.494 0.184 0.556; 0.929 0.694 0.125; 0.301 0.745 0.933; ...
              0.635 0.078 0.184];
    colorIdx = 1;

    % ---------------------------------------------------------------
    % Interactive click loop
    % ---------------------------------------------------------------
    while ~quitFlag && ishandle(fig)
        [a, b, button] = ginput(1);
        if isempty(a) || quitFlag
            break;
        end

        if button == 1
            % history(t): linear, history(-tau)=a, history(0)=b
            history = @(t) a + (b - a) .* (t + tau) / tau;
            ddefun  = @(t, y, Z) f(y, Z);

            sol = dde23(ddefun, tau, history, [0, tmax]);

            tt = linspace(0, tmax, nPts);
            xt = deval(sol, tt);
            xtau = zeros(size(tt));
            for i = 1:numel(tt)
                s = tt(i) - tau;
                if s <= 0
                    xtau(i) = history(s);
                else
                    xtau(i) = deval(sol, s);
                end
            end

            c = colors(mod(colorIdx - 1, size(colors, 1)) + 1, :);
            colorIdx = colorIdx + 1;

            plot(ax, a, b, 'o', 'MarkerFaceColor', c, ...
                 'MarkerEdgeColor', 'k', 'MarkerSize', 6, 'LineWidth', 0.75);
            plot(ax, xtau, xt, '-', 'Color', c, 'LineWidth', 1.5);

            % Mark t = tau: this is where the curve switches from the
            % (linear, user-chosen) history to the actual dde23 solution.
            % A visible kink here is EXPECTED, not a plotting bug -- see
            % README for why.
            xJ = deval(sol, 0);
            yJ = deval(sol, tau);
            plot(ax, xJ, yJ, 'x', 'Color', c, 'MarkerSize', 8, 'LineWidth', 1.5);
        end
    end

    function keyHandler(~, event)
        if strcmpi(event.Key, 'q')
            quitFlag = true;
        end
    end
end