use Test::Most tests => 2;

BEGIN {
    use_ok('Corinna')            or BAIL_OUT "Could not load Corinna";
    use_ok('Corinna::Pastorize') or BAIL_OUT "Could not load Corinna::Pastorize";
}
