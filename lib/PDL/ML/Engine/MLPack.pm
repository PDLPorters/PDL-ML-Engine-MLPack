package PDL::ML::Engine::MLPack;

use strict;
use warnings;
use Exporter 'import';
use XSLoader;

use PDL::Core;
use PDL::Types;
use PDL::Slices;

our $VERSION = '0.011';

our @EXPORT_OK = qw(
    mlpack_version
    linear_regression
    kmeans
);

XSLoader::load('PDL::ML::Engine::MLPack', $VERSION);

sub linear_regression {
    my ($x, $y, %opts) = @_;
    my $lambda = exists $opts{lambda} ? $opts{lambda} : 0.0;
    return _xs_linear_regression($x->double(), $y->double(), $lambda);
}

sub kmeans {
    my ($x, $k) = @_;
    $k ||= 2;
    return _xs_kmeans($x->double(), $k);
}

1;

__END__

=encoding UTF-8

=head1 NAME

PDL::ML::Engine::MLPack - mlpack C++17 classical machine learning bindings for PDL

=head1 SYNOPSIS

    use PDL;
    use PDL::ML::Engine::MLPack qw(mlpack_version linear_regression kmeans);

    my $X = double([[1, 2], [2, 3], [3, 4], [4, 5]]);
    my $y = double([3, 5, 7, 9]);

    my ($params, $preds) = linear_regression($X, $y, lambda => 0.0);
    my ($assignments, $centroids) = kmeans($X, 2);

=head1 DESCRIPTION

C<PDL::ML::Engine::MLPack> binds L<PDL> ndarrays directly to C<mlpack> (C++17 classical
machine learning library backed by Armadillo) via C99 XS and a C++17 bridge.

=head1 FUNCTIONS

=head2 mlpack_version

=for ref

Return the linked C<mlpack> version string.

=for usage

    $ver = mlpack_version();

=head2 linear_regression

=for ref

Fit an OLS or Ridge (C<lambda>) linear regression model on a 2D PDL feature
matrix and 1D response vector, returning C<($params, $predictions)>.

=for usage

    ($params, $preds) = linear_regression($X, $y, lambda => 0.0);

=head2 kmeans

=for ref

Run K-Means clustering with C<$k> clusters on a 2D PDL matrix, returning
C<($assignments, $centroids)>.

=for usage

    ($assignments, $centroids) = kmeans($X, $k);

=head1 TUTORIAL

This tutorial adapts the classic C<mlpack> linear regression and K-Means
clustering quickstarts to idiomatic Perl and L<PDL>.

=head2 1. Ordinary Least Squares and Ridge Regression

Build a 2D feature matrix C<$X> (rows = samples, columns = features) and a 1D
target vector C<$y> as L<PDL> ndarrays, then fit a linear model with
C<linear_regression>:

    use strict;
    use warnings;
    use PDL;
    use PDL::ML::Engine::MLPack qw(mlpack_version linear_regression kmeans);

    print 'mlpack version: ', mlpack_version(), "\n";

    # True relation: y = 1 + 2*x1 + 3*x2
    my $X = double([
        [1, 0],
        [0, 1],
        [1, 1],
        [2, 1],
        [1, 2],
        [2, 2],
    ]);
    my $y = double([3, 4, 6, 8, 9, 11]);

    # OLS (lambda => 0.0)
    my ($params, $preds) = linear_regression($X, $y, lambda => 0.0);
    my $max_err = abs($preds - $y)->max();
    print 'OLS parameters: ', $params, "\n";
    print 'OLS max error:  ', $max_err, "\n";

    # L2-regularized Ridge regression (lambda > 0)
    my ($ridge_params, $ridge_preds) = linear_regression($X, $y, lambda => 0.1);
    print 'Ridge parameters: ', $ridge_params, "\n";

=head2 2. K-Means Clustering

Pass a 2D matrix of observations and the desired cluster count C<$k> to
C<kmeans> to obtain per-point cluster assignments and learned centroids:

    my $pts = double([
        [ 0.0,  0.0],
        [ 0.1,  0.1],
        [ 0.0,  0.2],
        [10.0, 10.0],
        [10.1, 10.1],
        [10.0, 10.2],
    ]);

    my ($assignments, $centroids) = kmeans($pts, 2);
    print 'Cluster assignments: ', $assignments, "\n";
    print 'Centroids: ', $centroids, "\n";

See F<examples/quickstart.pl> in the distribution for a complete runnable
script.

=head1 TYPES

Supports standard real numeric PDL types (C<byte>, C<short>, C<long>, C<longlong>, C<float>, C<double> as supported by the underlying library). Complex types (C<cfloat>, C<cdouble>) are not supported by this backend.

=head1 SEE ALSO

L<PDL>, L<PDL::XGBoost>, L<PDL::Torch>, L<PDL::FAISS>, L<PDL::DuckDB>

=head1 AUTHOR

C.J. Collier <cjac@google.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2026 Google LLC

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
