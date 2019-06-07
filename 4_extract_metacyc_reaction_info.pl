open (IN, "/database/metacyc/22.6/data/reactions.tab"); ### link to your own metacyc database #####
print "UNIQUE-ID\tEC-NUMBER\tENZYMATIC-REACTION\tLEFT\tRIGHT\tREACTION-DIRECTION\n";
while (<IN>) {
	chop;
	@a=split("\t",$_);
	$rxn=();
	$enzrxn=();
	$dir=();
	$left=();
	$right=();
	@d=();
	@b=();
	@c=();
	for my $val (@a) {
		if ($val =~ /UNIQUE-ID - (\S+)/) {
			$rxn=$1;
		}
		if ($val =~ /EC-NUMBER - (\S+)/) {
			$ec=$1;
		}
		if ($val =~ /ENZYMATIC-REACTION - (\S+)/) {
			push @d, $1;	
		}
		if ($val =~ /LEFT - (\S+)/) {
			push @b, $1;
		}
		if ($val =~ /RIGHT - (\S+)/) {
			push @c, $1;
		}
		if ($val =~ /REACTION-DIRECTION - (\S+)/) {
			$dir=$1;
		}
	}
	$enzrxn=join (";",@d);
	$left = join (";",@b);
	$right=join (";", @c);
	print $rxn."\t".$ec."\t".$enzrxn."\t".$left."\t".$right."\t".$dir."\n";
}
