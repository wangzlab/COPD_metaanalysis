#!bin/perl
## This is a script to integrate the outputs from previous steps ##
## to generate compounds, host targets, confidence score, interaction type, meta-analysis fold change and p-values for the host targets ##
## for each individual microbial enzymes of interest ##
## results are generated for each enzyme EC number separately in the compound_annotation folder to be further triaged to link microbiome-host signatures ##

open (IN, "cmpd_selected.txt"); 
### tab delimited compound list with "compound\tsmile\tpubchemID\tchebiID\tstitchID", output from 5_convert_metacyc_to_stitch.pl ####
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
open (IN, "/database/stitch/compound_target_match.txt");
### tab delimited compound target match list, output from 6_parse_stitch_database.pl ###
while (<IN>) {
	chop;
	@a=split("\t",$_);
	next if ($a[2] eq '');
	$interaction{$a[0]}{$a[2]}=$a[4]."\t".$a[9];
}
open (IN, "metaanalysis.txt");
### tab delimited files for each gene, its fold change and P-value in the meta-analysis, as gene\tfold-change\traw-pvalue\tfdr-pvalue ###
while (<IN>) {
	chop;
	@a=split("\t",$_);
	$metaanalysis{$a[0]}=$a[1]."\t".$a[3];
}
### list of compounds that are putatively human-derived and need to be filtered ###
open (IN, "human_cmpd_list");
while (<IN>) {
	chop;
	$human{$_}=1;
}

open (IN, "microbial_metabolic_reactions.txt");
### list of selected microbial metabolic reactions from the metagenomic inference, formatted as EC number\tleft compounds\tright compounds###
### left and right compounds were further separated by ";" ###
while (<IN>) {
	chop;
	@a=split("\t",$_);
	($id)=($a[0]=~ /EC:(\S+)/);
	@b=split(";",$a[1]);
	@c=split(";",$a[2]);
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
