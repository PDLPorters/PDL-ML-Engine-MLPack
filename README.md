# PDL::ML::Engine::MLPack

`mlpack` C++17 classical machine learning bindings for [PDL](https://pdl.perl.org/), backed by Armadillo via C99 XS and a C++17 bridge.

## Prerequisites

- Perl 5.10+
- `PDL` (>= 2.080)
- `mlpack` headers (`libmlpack-dev`) and Armadillo (`libarmadillo-dev`)
- C++17 compiler

## Installation

```bash
perl Makefile.PL
make
make test
make install
```

Or with `cpanm`:

```bash
cpanm .
```

## Quickstart

```perl
use strict;
use warnings;
use PDL;
use PDL::ML::Engine::MLPack qw(mlpack_version linear_regression kmeans);

print 'mlpack version: ', mlpack_version(), "\n";

# Linear regression (OLS)
my $X = double([[1, 0], [0, 1], [1, 1], [2, 1], [1, 2], [2, 2]]);
my $y = double([3, 4, 6, 8, 9, 11]);
my ($params, $preds) = linear_regression($X, $y, lambda => 0.0);

# K-Means clustering
my $pts = double([[0.0, 0.0], [0.1, 0.1], [10.0, 10.0], [10.1, 10.1]]);
my ($assignments, $centroids) = kmeans($pts, 2);
```

## Examples & Documentation

- Runnable quickstart: [examples/quickstart.pl](examples/quickstart.pl) (`perl examples/quickstart.pl`)
- Full API documentation and tutorial: `perldoc PDL::ML::Engine::MLPack`
