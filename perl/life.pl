#! /usr/bin/env perl

use strict;
use warnings;

my $life = GAME::OF::LIFE->new(
	live => 1,
	dead => 0
);

while (1) {
	print "\33c"; # flash
	$life->drow();
	$life->next();
	select(undef, undef, undef, 0.1);
}

package GAME::OF::LIFE;

sub new {
	my ($class, %opts) = @_;
	my $live = defined $opts{live} ? $opts{live} : '■';
	my $dead = defined $opts{dead} ? $opts{dead} : '□';
	my $world;
	my $y;
	for ($y = 0; <STDIN>; $y++) {
		my @a = map {
			($_ eq 1) ? $live : $dead;
		} split(/\s/);
		$world->[$y] = \@a;
	}

	bless {
		world => $world,
		size => $y,
		live => $live,
		dead => $dead,
	}, $class;
}

sub drow {
	my ($self) = @_;
	my $buff = '';
	for (my $y = 0; $y < $self->{size}; $y++) {
		for (my $x = 0; $x < $self->{size}; $x++) {
			$buff .= $self->{world}->[$y][$x] . " ";
		}
		$buff .= "\n";
	}
	print $buff;
}

sub next {
	my ($self) = @_;
	my $next_world;
	for (my $y = 0; $y < $self->{size}; $y++) {
		for (my $x = 0; $x < $self->{size}; $x++) {
			my $xs = $x == 0 ? 0 : ($x - 1);
			my $xe = $x == ($self->{size} - 1) ? ($self->{size} - 1) : ($x + 1);
			my $ys = $y == 0 ? 0 : ($y - 1);
			my $ye = $y == ($self->{size} - 1) ? ($self->{size} - 1) : ($y + 1);
			my $count = 0;
			for (my $i = $ys; $i <= $ye; $i++) {
				for (my $j = $xs; $j <= $xe; $j++) {
					$count++ if $self->{world}->[$i][$j] eq $self->{live};
				}
			}
			$next_world->[$y][$x] = ($count == 3) ? $self->{live}
				: ($count == 4) ? $self->{world}->[$y][$x]
				: $self->{dead};
		}
	}
	$self->{world} = $next_world;
};

1;
