open (IN, $ARGV[0]); 
#### a two column table for the combined effect size of each microbial gene ##########
while (<IN>) {
	chop;
	@a=split("\t",$_);
	$zval{$a[0]}=$a[1];
}

open (IN, "EMM.txt");
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
