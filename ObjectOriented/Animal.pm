package Animal;
use strict;
use warnings;

my $Voice       = "... (doesn't have any voice)";
my $limbs       = 0;
my $typeName    = "Undefined type";

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    return $self;
}

sub asay{
    say $voice;
}
1;
