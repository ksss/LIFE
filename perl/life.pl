#! /usr/bin/env perl

use strict;
use warnings;

my $world;
for (my $y = 0; <STDIN>; $y++) {
	my @a = split(/\s/);
	$world->[$y] = \@a;
}

my $height = @$world;
my $width = $height;

sub drow {
	my $buff = '';
	for (my $y = 0; $y < $height; $y++) {
		for (my $x = 0; $x < $width; $x++) {
			$buff .= $world->[$y][$x] == 1 ? "■ " : "□ ";
		}
		$buff .= "\n";
	}
	print "\33c"; # flash
	print $buff;
};

sub wnext {
	my $next_world;
	for (my $y = 0; $y < $height; $y++) {
		for (my $x = 0; $x < $width; $x++) {
			my $xs = $x == 0 ? 0 : ($x - 1);
			my $xe = $x == ($width - 1) ? ($width - 1) : ($x + 1);
			my $ys = $y == 0 ? 0 : ($y - 1);
			my $ye = $y == ($height - 1) ? ($height - 1) : ($y + 1);
			my $count = 0;
			for (my $i = $ys; $i <= $ye; $i++) {
				for (my $j = $xs; $j <= $xe; $j++) {
					$count++ if $world->[$i][$j] == 1;
				}
			}
			$next_world->[$y][$x] = ($count == 2) ? 0
							 : ($count == 3) ? 1
							 : ($count == 4) ? $world->[$y][$x]
							 : 0;
		}
	}
	$world = $next_world;
};

while (1) {
	drow();
	wnext();
	select(undef, undef, undef, 0.1);
}

