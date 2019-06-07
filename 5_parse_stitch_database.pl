open (IN, "9606.protein_chemical.links.detailed.v5.0.tsv");
while (<IN>) {
	chop;
	s/9606\.//g;
	@a=split("\t",$_);
	next if ($a[6]<700);
	#$hash{$a[0]}{$a[1]}=$a[5];
	$score{$a[0]}{$a[1]}=$a[2]."\t".$a[3]."\t".$a[4]."\t".$a[5]."\t".$a[6];
}
open (IN, "9606.actions.v5.0.tsv");
while (<IN>) {
	chop;
	s/9606\.//g;
	@a=split("\t",$_);
	next if ($a[5]<700);
	$int{$a[0]}{$a[1]}=$a[2];
	$int{$a[1]}{$a[0]}=$a[2];
}

open (IN, "human_gene_ids.txt");
while (<IN>) {
	chop;
	@a=split("\t",$_);
	$geneid{$a[2]}=$a[9]."\t".$a[8];
}

open (IN, $ARGV[0]); #### stitch compound ID list #####
while (<IN>) {
	chop;
#	@a=split("\t",$_);
	$id=$_;
	if (exists $int{$id}) {
		for my $key (keys %{$int{$id}}) {
			print $id."\t".$key."\t".$geneid{$key}."\t".$int{$id}{$key}."\t".$score{$id}{$key}."\n";
		}
	}
}
