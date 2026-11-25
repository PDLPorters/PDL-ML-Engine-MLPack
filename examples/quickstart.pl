# Copyright 2026 Google LLC
#
# Licensed under the the same terms as Perl itself (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

use strict;
use warnings;
use PDL;
use PDL::ML::Engine::MLPack qw(mlpack_version linear_regression kmeans);

print 'mlpack version: ', mlpack_version(), "\n";

# 1. Linear Regression: y = 1 + 2*x1 + 3*x2
my $X = double([
    [1, 0],
    [0, 1],
    [1, 1],
    [2, 1],
    [1, 2],
    [2, 2],
]);
my $y = double([3, 4, 6, 8, 9, 11]);

my ($params, $preds) = linear_regression($X, $y, lambda => 0.0);
my $max_err = abs($preds - $y)->max();
print 'OLS parameters: ', $params, "\n";
print 'OLS predictions: ', $preds, "\n";
print 'OLS max abs error: ', $max_err, "\n";

my ($ridge_params, $ridge_preds) = linear_regression($X, $y, lambda => 0.1);
print 'Ridge (lambda=0.1) parameters: ', $ridge_params, "\n";

# 2. K-Means Clustering on two well-separated clusters
my $pts = double([
    [ 0.0,  0.0],
    [ 0.1,  0.1],
    [ 0.0,  0.2],
    [10.0, 10.0],
    [10.1, 10.1],
    [10.0, 10.2],
]);

my ($assignments, $centroids) = kmeans($pts, 2);
print 'K-Means assignments: ', $assignments, "\n";
print 'K-Means centroids: ', $centroids, "\n";
