open (IN, "/database/stitch/chemical.sources.v5.0.tsv"); #### stitch id mapping file #### 
while (<IN>) {
	chop;
	next if (/^#/);
	s/CID\S//g;
	@a=split("\t",$_);
	if (/PC\t(\d+)/) {
		$pc{$1}="CIDm".$a[0];
	}
	$merge{$a[1]}="CIDm".$a[0];
	if (/CHEBI:(\d+)/) {
		$chebi{$1}="CIDm".$a[0];
	} 
}

open (IN, $ARGV[0]);  #### tab delimited compound list with 'cmpd\tsmile\tpubchemID\tchebiID' #####
while (<IN>) {
	chop;
	@a=split("\t",$_);
	if ($chebi{$a[3]} ne $merge{$a[2]}) {
		print STDERR "chebi and pubchem IDs for $a[0] do not match\n";
	}
	else {
		print $_."\t".$merge{$a[2]}."\t".$pc{$a[2]}."\t".$chebi{$a[3]}."\n";
	}	
}
