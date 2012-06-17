#! /usr/bin/env perl

use strict;
use warnings;
use Time::HiRes;

my $life = GAME::OF::LIFE->new();
my $time = $ARGV[0] || 0.1;
my $n = 0;
my ($start, $diff);

while (1) {
	print "\33c"; # flash
	$start = Time::HiRes::time;
	$life->next();
	$diff = Time::HiRes::time - $start;
	print ++$n . " : " . $diff . "\n";
	exit 1 if ($time - $diff < 0);
	Time::HiRes::sleep($time - $diff);
}

package GAME::OF::LIFE;

sub new {
	my ($class, %opts) = @_;
	my $live = defined $opts{live} ? $opts{live} : '■';
	my $dead = defined $opts{dead} ? $opts{dead} : '□';
	my $world;
	my $size;
	for ($size = 0; <STDIN>; $size++) {
		$world->[$size] = [map { ($_ eq 1) ? $live : $dead } split(/\s/)];
	}

	bless {
		live  => $live,
		dead  => $dead,
		world => $world,
		size  => $size,
	}, $class;
}

sub next {
	my ($self) = @_;
	my $live  = $self->{live};
	my $dead  = $self->{dead};
	my $world = $self->{world};
	my $size  = $self->{size};
	my $next_world;

	for (my $y = 0; $y < $size; $y++) {
		for (my $x = 0; $x < $size; $x++) {
			my $xs = $x == 0 ? 0 : ($x - 1);
			my $xe = $x == ($size - 1) ? ($size - 1) : ($x + 1);
			my $ys = $y == 0 ? 0 : ($y - 1);
			my $ye = $y == ($size - 1) ? ($size - 1) : ($y + 1);
			my $count = 0;
			for (my $i = $ys; $i <= $ye; $i++) {
				for (my $j = $xs; $j <= $xe; $j++) {
					$count++ if $world->[$i][$j] eq $live;
				}
			}
			$next_world->[$y][$x] = ($count == 3) ? $live
				: ($count == 4) ? $world->[$y][$x]
				: $dead;
		}
		print join(' ', @{$next_world->[$y]}) . "\n";
	}
	$self->{world} = $next_world;
};

1;
