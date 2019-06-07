open (IN, "cmpd_selected.txt"); 
### create tab delimited compound list with "compound\tsmile\tpubchemID\tchebiID\tstitchID"####
while (<IN>) {
	chop;
	@a=split("\t",$_);
	$pc{$a[0]}=$a[2]; #### map pubchem ID ####
	$chebi{$a[0]}=$a[3]; #### map chEBI ID ######
	for my $i (1..$#a) {
		if ($a[$i]=~ /CID/) {
			$comp{$a[0]}{$a[$i]}=1;
		}
	}
}
open (IN, "/database/stitch/compound_receptor_all_idmatch.txt");
while (<IN>) {
	chop;
	@a=split("\t",$_);
	next if ($a[2] eq '');
	$interaction{$a[0]}{$a[2]}=$a[4]."\t".$a[9];
}
open (IN, "metaanalysis.txt");
while (<IN>) {
	chop;
	@a=split("\t",$_);
	$metaanalysis{$a[0]}=$a[1]."\t".$a[3];
}
open (IN, "human_cmpd_list");
while (<IN>) {
	chop;
	$human{$_}=1;
}

open (IN, "metabolic_reactions.txt");
while (<IN>) {
	chop;
	@a=split("\t",$_);
	($id)=($a[0]=~ /EC:(\S+)/);
	@b=split(";",$a[3]);
	@c=split(";",$a[4]);
	open (OUT, ">>compound_annotation/$id.txt");
	for my $cmpd (@b) {
		next if (! exists $comp{$cmpd} or exists $human{$cmpd});
		for my $key (keys %{$comp{$cmpd}}) {
			for my $key2 (keys %{$interaction{$key}}) {
				print OUT $cmpd."\tLEFT\t".$pc{$cmpd}."\t".$chebi{$cmpd}."\t".$key."\t".$key2."\t".$interaction{$key}{$key2}."\t".$metaanalysis{$key2}."\n";
			}
		}
	}
	for my $cmpd (@c) {
		next if (! exists $comp{$cmpd} or exists $human{$cmpd});
		for my $key (keys %{$comp{$cmpd}}) {
			for my $key2 (keys %{$interaction{$key}}) {
				print OUT $cmpd."\tRIGHT\t".$pc{$cmpd}."\t".$chebi{$cmpd}."\t".$key."\t".$key2."\t".$interaction{$key}{$key2}."\t".$metaanalysis{$key2}."\n";
			}
		}
	}
}
