#!bin/perl
### This is the script to generate the PRMT score of the metabolites ###
### based on the combined fold change of microbial genes in the meta-analysis and the EMM matrix generated in the previous step ###

open (IN, "metaanalysis_microbial_genes.txt"); 
### This is a two column table for the microbial gene and its combined effect size in the meta-analysis ###
while (<IN>) {
	chop;
	@a=split("\t",$_);
	$zval{$a[0]}=$a[1];
}

open (IN, "EMM.txt");
### This is the EMM matrix generated in the previous step ###
$header=<IN>;
chop $header;
@headers=split("\t",$header);
while (<IN>) {
	chop;
	@a=split("\t",$_);
	$total=0;
	for my $i (1..$#a) {
		$total += $a[$i]*$zval{$headers[$i]};
	}
	print $a[0]."\t".$total."\n";
}
