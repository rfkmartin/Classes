#!/soft/perl5.8/bin/perl

# Robert F.K. Martin
# ID 1505151
#
# Programming Assignment 2
#

# open and parse model
#
# assumes hw2.model uses only three delimiters:
# ' -> ' for production rule
# ' ' single space between non-terminals or terminals
# ' : ' between production rule and probability
open(HW2,"hw2.model");
$counter=0;
while (<HW2>) {
    chop;
    ($rule,$prob) = split(' : ');
    ($num,$div) = split('/',$prob);
    $thisprob = $num/$div;

    ($foo,$other) = split(' -> ',$rule);

    @words = split(/[\s]+/,$other);
    $len = @words;

    if ($len == 1) { # might be unary rule or terminal
	if ($words[0] eq $foo) { #unary rule
	    $rule_A{$counter} = $foo;
	    $rule_B{$counter} = $foo;
	    $rule_C{$counter} = 'NULL';
	    $rule_P{$counter} = $thisprob;
	    #print "A->A($counter): $foo -> $foo NULL $thisprob\n";
	}
	elsif ($NTerm_r{$words[0]} > 0) { # unary non-terminal
	    $rule_A{$counter} = $foo;
	    $rule_B{$counter} = $words[0];
	    $rule_C{$counter} = 'NULL';
	    $rule_P{$counter} = $thisprob;
	    print "A->B($counter): $foo -> $words[0] $thisprob\n";
	}
	else { # terminal
	    $rule_A{$counter} = $foo;
	    $rule_B{$counter} = $words[0];
	    $rule_C{$counter} = 'NULL';
	    $rule_P{$counter} = $thisprob;
	    print "A->a($counter): $foo -> $words[0] $thisprob\n";
	}
    }
    else {
	($word1,$word2) = split(' ', $other);
	$rule_A{$counter} = $foo;
	$rule_B{$counter} = $word1;
	$rule_C{$counter} = $word2;
	$rule_P{$counter} = $thisprob;
	print "A->B C($counter): $foo -> $word1 $word2 $thisprob\n";
    }
    $counter++;
}
close(HW2);
$num_Rules = $counter - 1;

$NUM_FRAMES=234;

# open and parse input file
# take words from file and
# set the probability at the
# associated span
open(HW2,'hw2.in');

while (<HW2>) {
    chop;
    ($word,$start,$end) = split(' ');
    $idx1 = $NUM_FRAMES*$start+$end-1;
    if ($word eq 'i') {
	$word = 'I';
    }

    $PI{$idx1} = 1;
    $PI_nt{$idx1} = 'NULL';
    $PI_lt{$idx1} = -1;
    $PI_rt{$idx1} = $word;
    $PI_b{$idx1} = $start;
    $PI_e{$idx1} = $end;
}
close(HW2);

# do the brunt of the work here
for ($span=1;$span<$NUM_FRAMES;$span++) {
    for ($begin=0;$begin<$NUM_FRAMES-$span;$begin++) {
	$end = $begin+$span;

	# A -> a
	# this can be done before we go into the next loop
	$idx3=$NUM_FRAMES*$begin+$end;
	for ($n=0;$n<$num_Rules;$n++) {
	    if (($PI_nt{$idx3} eq 'NULL') && ($PI_rt{$idx3} eq $rule_B{$n}) && ($rule_C{$n} eq 'NULL')){
		if ($PI_p{$idx3} < $rule_P{$n}) {
		    $PI_p{$idx3} = $rule_P{$n};
		    $PI_nt{$idx3} = $rule_A{$n};
		    $PI{$idx3} = 1;
		    print "$rule_A{$n} -> $rule_B{$n} $PI_b{$idx3} $PI_e{$idx3}\n";
		}
	    }
	}	

	for ($m=$begin;$m<$end;$m++) {
	    
	    # only continue if left branch has a beginning
	    $idx1=$NUM_FRAMES*$begin+$m;
	    $idx2=$NUM_FRAMES*($m+1)+$end;

	    # PI will not be 1 in cases of A->a B
	    if ($PI{$idx1} == 1) {
		for ($n=0;$n<$num_Rules;$n++) {
		    # only continue if non-terminals match 
		    # and a rule exists
		    $tProb=0;

		    # A -> B C
		    if (($PI_nt{$idx1} eq $rule_B{$n}) && ($PI_nt{$idx2} eq $rule_C{$n})) {
			#print "A -> B C: ";
			$tProb = $PI_p{$idx1}*$PI_p{$idx2}*$rule_P{$n};
			$PI{$idx3} = 1;
			if ($tProb > $PI_p{$idx3}) {
			    printf "$begin $end %.4f: ", $tProb;
			    $PI_p{$idx3} = $tProb;
			    $PI_nt{$idx3} = $rule_A{$n};
			    $PI_lt{$idx3} = $idx1;
			    $PI_rt{$idx3} = $idx2;
			    $PI_b{$idx3} = $PI_b{$idx1};
			    $PI_e{$idx3} = $PI_e{$idx2};
			    $text=&findtree($idx3);
			    print "\n";
			    $last = $idx3;
			}
		    }
		    # A -> a B
		    elsif (($PI_nt{$idx1} eq 'NULL') && ($PI_rt{$idx1} eq $rule_B{$n}) && ($PI_nt{$idx2} eq $rule_C{$n})) {
			#print "A -> a B: ";
			$tProb = $rule_P{$n}*$PI_p{$idx2};
			$PI{$idx3} = 1;
			if ($tProb > $PI_p{$idx3}) {
			    print "$begin $end %.4f ", $tProb;
			    $PI_p{$idx3} = $tProb;
			    $PI_nt{$idx3} = $rule_A{$n};
			    $PI_lt{$idx3} = $idx1;
			    $PI_rt{$idx3} = $idx2;
			    $PI_b{$idx3} = $PI_b{$idx1};
			    $PI_e{$idx3} = $end;
			    $text=&findtree($idx3);
			    print "\n";
			    $last = $idx3;
			}
		    }
		    # A -> B
		    elsif (($PI_nt{$idx3} eq $rule_B{$n}) && ($rule_C{$n} eq 'NULL')) {
			#print "$rule_A{$n} -> $rule_B{$n}:\n"; 
			$tProb = $rule_P{$n}*$PI_p{$idx3};
			$PI{$idx3} = 1;
			if ($tProb > $PI_p{$idx3}) {
			    $PI_p{$idx3} = $tProb;
			    $PI_nt{$idx3} = $rule_A{$n};
			    $text=&findtree($idx3);
			    print "\n";
			    $last = $idx3;
			}
		    }
		}
	    }
	}
    }
}


&findtree($last);
print "\n";

sub findtree {
    if ($PI_lt{$_[0]} > -1) {
	print "$PI_nt{$_[0]}($PI_b{$_[0]}, $PI_e{$_[0]}) [";
	&findtree($PI_lt{$_[0]});
	if ($PI_rt{$_[0]} != -1) {
	    &findtree($PI_rt{$_[0]});
	}
	else {
	    print "NULL ($PI_e{$PI_lt{$_[0]}}, $PI_e{$_[0]})";
	}
	print "]";
    }
    else {
	print "$PI_nt{$_[0]}($PI_b{$_[0]}, $PI_e{$_[0]}) [$PI_rt{$_[0]}] ";
    }
    return;
}
