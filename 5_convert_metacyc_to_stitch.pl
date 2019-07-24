#!bin/perl
## This is a simple script that convert MetaCyc compounds to STITCH compound ID ##
## for each compound in MetaCyc database, get its pubchem and chebi IDs and store in metacyc_cmpd_list ##
## chemical.sources.v5.0.tsv is from STITCH database ##
## The output is compound descriptions with STITCH IDs converted based on PubChem and CheBI IDs ##
## The two converted IDs should be identical, if not the script outputs the flag in standard error for the users to check discrepancies ##

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

open (IN, "metacyc_cmpd_list");  #### tab delimited compound list with 'Compound description\tSMILES structure\tPubchemID\tChebiID' #####
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
