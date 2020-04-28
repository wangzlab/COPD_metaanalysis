#!bin/perl
### This script is used to perform LOGO analysis to generate the inferred metagenome profile in which each contributing genus was left out one at a time ###
### The script is made using two public datasets (SRP066375 and SRP136124) as examples but can be modified as needed to analyze user-provided data ###
### Inputs:  1) List of genera of interest (genus_list); 2) List of EC genes of interest (ec_list); 3) taxonomy files provided by QIIME2; 4) stratified ASV-EC contribution file provided by PICRUSt2  ###
### Outputs are list of metagenome profiles for each dataset with each of genus of interest excluded (studyXXX_genusXXX.txt) ####

open (IN, "genus_list"); ### list of genera of interest ###
while (<IN>) {
	chop;
	push @genus, $_;
}
open (IN, "ec_list"); ### list of EC genes of interest ###
while (<IN>) {
	chop;
	$commonec{$_}=1;
}
open (IN, "SRP066375.taxonomy.tsv"); ### tab-delimited taxonomy file provided by QIIME2 (asv, taxonomy) ###
while (<IN>) {
	chop;
	@a=split("\t",$_);
	$taxonomy{$a[0]}=$a[1];
}
open (IN, "SRP136124.taxonomy.tsv"); ### tab-delimited taxonomy file provided by QIIME2 (asv, taxonomy) ###
while (<IN>) {
	chop;
	@a=split("\t",$_);
	$taxonomy{$a[0]}=$a[1];
}

open (IN, "SRP066375.tsv"); ### stratified ASV contribution table to EC genes provided by PICRUSt2 (the first two columns being EC and ASV and remaining being samples) ###
$header=<IN>;
chop $header;
@headers=split("\t",$header);
while (<IN>) {
	chop;
	@a=split("\t",$_);
	$tmp=$a[0]."_".$a[1];
	for my $i (2..$#a) {
		$hash{$headers[$i]}{$tmp}=$a[$i];
		$transhash{$tmp}{$headers[$i]}=$a[$i];
	}
}
open (IN, "SRP136124.tsv"); ### stratified ASV contribution table to EC genes provided by PICRUSt2 (the first two columns being EC and ASV and remaining being samples) ###
$header=<IN>;
chop $header;
@headers=split("\t",$header);
while (<IN>) {
	chop;
	@a=split("\t",$_);
	$tmp=$a[0]."_".$a[1];
	for my $i (2..$#a) {
		$hash2{$headers[$i]}{$tmp}=$a[$i];
		$transhash2{$tmp}{$headers[$i]}=$a[$i];
	}
}
print STDERR "Done importing all files\n";

for my $val (@genus) {
	print STDERR "LOGO for $val\n";
	open (OUT, "SRP066375_$val.txt");
	open (OUT2, "SRP136124_$val.txt");
	print OUT "SampleID";
	for my $key (sort keys %hash) {
		print OUT "\t$key";
	}
	print OUT "\n";
	print OUT2 "SampleID";
	for my $key (sort keys %hash2) {
		print OUT2 "\t$key";
	}
	print OUT2 "\n";

	my %total=();
	my %total2=();
	for my $key (sort keys %transhash) {
		($ec,$asv)=($key=~ /(\S+)_(\S+)/);
		next unless (exists $commonec{$ec});
		#print $taxonomy{$asv}."\n";
		next if ($taxonomy{$asv}=~ /g__$val/);
		for my $key2 (sort keys %{$transhash{$key}}) {
			$total{$ec}{$key2}+=$transhash{$key}{$key2};
		}
	}
	for my $key (sort keys %total) {
		print OUT $key;
		for my $key2 (sort keys %hash) {
			print OUT "\t$total{$key}{$key2}";
		}
		print OUT "\n";
	}
	for my $key (sort keys %transhash2) {
		($ec,$asv)=($key=~ /(\S+)_(\S+)/);
		next unless (exists $commonec{$ec});
		next if ($taxonomy{$asv}=~ /g__$val/);
		for my $key2 (sort keys %{$transhash2{$key}}) {
			$total2{$ec}{$key2}+=$transhash2{$key}{$key2};
		}
	}
	for my $key (sort keys %total2) {
		print OUT2 $key;
		for my $key2 (sort keys %hash2) {
			print OUT2 "\t$total2{$key}{$key2}";
		}
		print OUT2 "\n";
	}
}
