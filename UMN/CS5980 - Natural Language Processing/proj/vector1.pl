#!/soft/perl5.8/bin/perl

open(CLUES,"clues.db");

while (<CLUES>) {
    chop;
    if (! /\#\#\#/) {
	($foo_clue,$foo_target)=split(':');
	@foo_cluewords = split(' ',$foo_clue);
	chop($foo_target);
	$len = @foo_cluewords;
	
	for ($i=0;$i<$len;$i++) {
	    $clueword{$foo_cluewords[$i]} += 1;
	    $dbclueword_t++;
	}

	# count each unique clue and target...
	$clue{$foo_clue} += 1;
	$target{$foo_target} += 1;

	# but index all clues and targets together
	$clue_c[$dbtarget_t] = $foo_clue;
	$target_c[$dbtarget_t] = $foo_target;

	# increment counter
	$dbtarget_t++;
    }
}

close(CLUES);

open (TARGETS,">target.txt");
foreach (keys %target) {
    # given target word, return index number
    $target_i{$_} = $target_t;
    print TARGETS "$target{$_} $_\n";
    $target_t++;
}
close(TARGETS);

open(CLUEWORDS,">cluewords.txt");
$clueword_t = 0;
foreach (keys %clueword) {
    # given clue word, return index number
    $clueword_i{$_} = $clueword_t;
    print CLUEWORDS "$clueword{$_} $_\n";
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
# compute vector of myclue
    $diff = $myclue ne "no mas";
    #print "looking for answer to '$myclue'...\n";
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
    
# normalize vector
    for ($i=0;$i<$len;$i++) {
	if ($clueword{$mywords[$i]} > 0) {
	    # anything that hasn't appeared with have zero contribution
	    $myvector[$clueword_i{$mywords[$i]}] /= $length;
	}
    }

# compute cosine of clue vector and database clue vector
    $sum = 0;
    for ($i=0;$i<$dbtarget_t;$i++) {
	$sum = 0;
	$sum1 = 0;
	# compute vector of database clue i
	@words = split(' ',$clue_c[$i]);
	$len = @words;
	for ($ii=0;$ii<$len;$ii++) {
	    # the factor here should be inv. proportional to the
	    # relative occurence in training set
	    $comp = -1 * log($clueword{$words[$ii]}/$clueword_t);
	    $vector[$clueword_i{$words[$ii]}] = $comp;
	    $sum1 += $vector[$clueword_i{$words[$ii]}]**2;
	}
	$length = sqrt($sum1);

	# normalize vector
	for ($ii=0;$ii<$len;$ii++) {
	    if ($clueword{$words[$ii]} > 0) {
		$vector[$clueword_i{$words[$ii]}] /= $length;
	    }
	}
	for ($j=0;$j<$clueword_t;$j++) {
	    $sum += $myvector[$j]*$vector[$j];
	}
	if ($sum > 0.67) {
	    #printf "Found possible answer(%.4f): $target_c[$i] -> $clue_c[$i]\n", $sum;
	    #print "$myclue XXX $clue_c[$i] -> $target_c[$i]\n";
	    print "$target_c[$i] ";
	}

	# clear out vecotr
	for ($ii=0;$ii<$len;$ii++) {
	    $vector[$clueword_i{$words[$ii]}] = 0;
	}
    }
    print "\n";

    # clear out myvector
    $len = @mywords;
    for ($i=0;$i<$len;$i++) {
	$myvector[$clueword_i{$mywords[$i]}] = 0;
    }

    # enter in clue
    #print "\nEnter clue: ";
    $myclue = <STDIN>;
    chop($myclue);
}




