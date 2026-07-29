# ddeplane_matlab

A `pplane`-style interactive phase-plane tool, adapted for a **scalar delay
differential equation (DDE) with one constant delay**, built on top of
MATLAB's `dde23`.

It is directly inspired by **PPLANE** (John Polking), which does this for
2D ODEs. This tool carries over the same interaction model — click a point,
see a trajectory — but a DDE is not a 2D system, so several things work
differently. Read this before drawing conclusions from what you see.

## What it solves

A scalar DDE of the form

```
x'(t) = f( x(t), x(t-tau) )
```

with one constant delay `tau`, no explicit time-dependence in `f`. Edit
`tau` and the function handle `f` at the top of `ddeplane_matlab.m`.

## What a click means — LINEAR initial history only

Clicking a point `(a, b)` is interpreted as the initial history

```
x(-tau) = a,   x(0) = b,   linearly interpolated in between.
```

**This tool only accepts linear initial histories.** A DDE's true initial
condition is an entire function on `[-tau, 0]`, not a point — this tool
restricts that function to the simplest two-parameter family (a straight
line) so that a single mouse click can specify it. It cannot represent
arbitrary history shapes (oscillating, piecewise, etc.).

## The plot is a projection — self-intersections are normal

The full state of a DDE at time `t` is the history segment on
`[t-tau, t]`, which is infinite-dimensional. The plane `(x(t-tau), x(t))`
shown here is a **projection** of that state onto two coordinates.

Because of this, the plotted curve **can and will cross itself** — this is
expected and does not indicate an error. In a true 2D ODE phase plane,
trajectories can never cross (that would violate uniqueness); no such
guarantee exists for this projection.

## What the gray arrows mean

The background arrows show **only the vertical direction** — the
instantaneous rate of change of `x(t)`, i.e. `f(x(t-tau), x(t))` evaluated
at each grid point. This is a genuine function of the plotted point, so it
is well-defined.

The rate of change of the *horizontal* coordinate, `x(t-tau)`, is **not**
determined by the point `(x(t-tau), x(t))` alone — it depends on history
further back in time that isn't visible in this 2D projection. So there is
no meaningful horizontal arrow to draw, and this is **not a full 2D vector
field** the way it would be for an ODE. Don't read the arrows as implying
a flow in both directions.

## No backward integration

Unlike the ODE version of this tool, **trajectories are only integrated
forward in time.** DDEs cannot, in general, be integrated backward:
evolving a DDE forward is a smoothing operation (it's why derivative
discontinuities in the history get progressively smoother at each `t = k*tau`,
see below), and smoothing is not invertible — recovering an earlier history
from a later one is generally ill-posed. `dde23` itself does not support
integrating backward, and neither does this tool.

## Why you'll often see a visible "kink" in the curve

Because the initial history is forced to be linear, its derivative at
`t=0` will generally **not** match the derivative the DDE itself would
produce there — i.e. the constant slope `(b-a)/tau` of your chosen line
usually isn't equal to `f(b, a)`. This creates a genuine jump in `x'(t)`
right at `t = tau`, which shows up as a visible bend in the plotted curve.
This is a real feature of the solution (a classic "method of steps"
artifact for DDEs with inconsistent initial data), **not a plotting bug.**

A small `×` marker is drawn on each trajectory at `t = tau` for exactly
this reason — that's where the curve switches from your chosen linear
history to the actual `dde23` solution, and where the kink is most
pronounced. The same discontinuity recurs at `t = 2*tau, 3*tau, ...` but
gets smoother each time (a genuine smoothing property of DDEs), so later
kinks are barely visible.

## Usage

```matlab
ddeplane_matlab
```

Left-click anywhere in the plane to draw a trajectory from that initial
history. Press `q` or close the window to quit.
