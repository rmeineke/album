#!/usr/bin/perl


$imageDir = '/home/robertm/Desktop';
opendir DIR, "$imageDir" or die "Can't open $imageDir $!";
    @images = grep { /\.(?:png|gif|jpg)$/i } readdir DIR;
closedir DIR;
                
$count = 1;
foreach (@images) {
    print "$count -- $_\n";
    $count = $count + 1;
}


