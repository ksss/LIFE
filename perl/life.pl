#! /usr/bin/env perl

use strict;
use warnings;

use Time::HiRes;

my $time = shift || 0.1;
my $n = 0;
my ($start, $diff);
my $live = '■';
my $dead = '□';
my $world;
my $life;

# ./life.pl < file
for (my $i = 0; <STDIN>; $i++) {
	$world->[$i] = [map { ($_ eq 1) ? $live : $dead } split(/\s/)];
}

$life = new GAME::OF::LIFE(
	live => $live,
	dead => $dead,
	world => $world,
);

$life->add([
	[qw/□ ■ □/],
	[qw/□ □ ■/],
	[qw/■ ■ ■/],
]);

while (1) {
	print "\33c"; # flash
	$start = Time::HiRes::time;
	$life->next();
	$diff = Time::HiRes::time - $start;
	print $n++ . " : " . $diff . "\n";
	die "Error: input time is too short => '$time'" if ($time - $diff < 0);
	Time::HiRes::sleep($time - $diff);
}

package GAME::OF::LIFE;

use Carp;

sub new {
	my ($class, %opts) = @_;
	my $live = defined $opts{live} ? $opts{live} : '■';
	my $dead = defined $opts{dead} ? $opts{dead} : '□';
	my $world = defined $opts{world} ? $opts{world} : undef;

	bless {
		live  => $live,
		dead  => $dead,
		world => $world,
	}, $class;
}

sub add {
	my ($self, $world, $size) = @_;
	$size = defined $size ? $size : $#{$world->[0]} + 1;
	for my $y (0..$size) {
		for my $x (0..$size) {
			$self->{world}->[$y]->[$x] = (defined $world->[$y]->[$x]) ? $world->[$y]->[$x]
				: defined $self->{world}->[$y]->[$x] ? $self->{world}->[$y]->[$x]
				: $self->{dead};
		}
	}
	$self;
}

sub next {
	my ($self, $print) = @_;
	croak "unset world" unless defined $self->{world};
	my $live  = $self->{live};
	my $dead  = $self->{dead};
	my $world = $self->{world};
	my $size  = $#{$world->[0]} + 1;
	my $next_world;

	$print = defined $print ? $print : 1;

	for my $y (0..$size - 1) {
		my $ys = $y == 0 ? 0 : ($y - 1);
		my $ye = $y == ($size - 1) ? ($size - 1) : ($y + 1);
		for my $x (0..$size - 1) {
			my $xs = $x == 0 ? 0 : ($x - 1);
			my $xe = $x == ($size - 1) ? ($size - 1) : ($x + 1);
			my $count = 0;
			for (my $i = $ys; $i <= $ye; $i++) {
				for (my $j = $xs; $j <= $xe; $j++) {
					$count++ if $world->[$i]->[$j] eq $live;
				}
			}
			$next_world->[$y][$x] = ($count == 3) ? $live
				: ($count == 4) ? $world->[$y]->[$x]
				: $dead;
		}
		print join(' ', @{$next_world->[$y]}) . "\n" if $print;
	}
	$self->{world} = $next_world;
};

1;
