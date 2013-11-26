#!/soft/perl5.8/bin/perl

open(CLUES,"clues.db");

while (<CLUES>) {
    chop;
    if (! /\#\#\#/) {
	($foo_clue,$foo_target)=split(':');
	chop($foo_target);
	@foo_cluewords = split(' ',$foo_clue);
	$len = @foo_cluewords;
	
	for ($i=0;$i<$len;$i++) {
	    $clueword{$foo_cluewords[$i]} += 1;
	    $dbclueword_t++;
	}

	# count each unique clue and target...
	$clue{$foo_clue} += 1;
	$target{$foo_target} += 1;
	$clue_r{$foo_target} = $foo_clue;

	# but index all clues and targets together
	$clue_c[$dbtarget_t] = $foo_clue;
	$target_c[$dbtarget_t] = $foo_target;

	# increment counter
	$dbtarget_t++;
    }
}

close(CLUES);

foreach (keys %target) {
    # given target word, return index number
    $target_i{$_} = $target_t;
    # given index number, return target
    $target_c{$target_t} = $_;
    $target_t++;
}


$clueword_t = 0;
foreach (keys %clueword) {
    # given clue word, return index number
    $clueword_i{$_} = $clueword_t;
    $clueword_t++;
}

#print "$clueword_t total unique clue words\n";
#print "$dbclueword_t total clue words\n";
#print "$target_t total unique targets\n";
#print "$dbtarget_t total targets\n";
#printf "Uniqueness of targets: %.4f\n", $target_t/$dbtarget_t;
#printf "Uniqueness of clue words: %.4f\n", $clueword_t/$dbclueword_t;

# enter in clue
#print "Enter clue: ";
$myclue = <STDIN>;
chop($myclue);

while ($myclue ne "no mas") {
    #print "looking for answer to $myclue\n";
    # compute vector of myclue
    @mywords = split(' ',$myclue);
    $len = @mywords;
    $sum = 0;
    $myvector[$clueword_t] = 0;
    for ($i=0;$i<$len;$i++) {
	if ($clueword{$mywords[$i]} > 0) {
	    # the factor here should be inv. proportional to the
	    # relative occurence in training set
	    $comp = -1 * log($clueword{$mywords[$i]}/$clueword_t);
	    $myvector[$clueword_i{$mywords[$i]}] = $comp;
	    $sum += $myvector[$clueword_i{$mywords[$i]}]**2;
	}
    }
    $length = sqrt($sum);

    # normalize vector of myclue
    for ($i=0;$i<$len;$i++) {
	if ($clueword{$mywords[$i]} > 0) {
	    $myvector[$clueword_i{$mywords[$i]}] /= $length;
	}
    }
    
   # put myclue into decomposed term space
    open(US,"us.txt");
    $idx = 0;
    $counter = 0;
    $term = <US>;
    while (<US>) {
	chop($_);
	$us = $_;
	$qprime{$idx} += $myvector[$counter] * $us;
	$counter++;
	if ($counter>=$clueword_t) {
	    $counter = 0;
	    $idx++;
	}
    }
    close(US);
    
    # compute cosine of clue vector and database clue vector
    open(V,'v.txt');
    $sum = 0;
    $idx = 0;
    $counter = 0;
    while (<V>) {
	chop($_);
	# read in and multiply
	$v = $_;
	$sum += $qprime{$idx} * $v;
	$idx++;
	
	# when counter has reached target_t, reset and
	# see if value is above beam
	if ($idx >= $term) {
	    if ($sum > 0.5) {
		#printf "Found possible answer(%.4f): $target_c{$counter} -> $clue_r{$target_c{$counter}}\n", $sum;
		print "$target_c{$counter} ";
	    }
	    $counter++;
	    $sum = 0;
	    $idx = 0;
	}
    }
    print "\n";
    close(V);

    for ($i=0;$i<$clueword_t;$i++) {
	$myvector[$i]=0;
    }
    for ($j=0;$j<$term;$j++) {
	$qprime{$j}=0;
    }
    # get another clue
    #print "\nEnter another clue: ";
    $myclue = <STDIN>;
    chop($myclue);
}
