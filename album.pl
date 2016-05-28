#! /usr/bin/perl

#sudo apt-get install libcddb-get-perl
#sudo apt-get install libmp3-info-perl
#sudo apt-get install libmp3-tag-perl
#sudo apt-get install cdparanoia
#sudo apt-get install lame


use warnings;
use strict;
use RipRoutines
  qw{get_cd_info fix_all_cd_info set_artist_dir set_album_dir set_flac_dir rip_album check_artist};


print "Go get the album art and \n";
print "save it as 'cover.jpg' on \n";
print "your DESKTOP!\n\n";
print "Press enter to continue.\n";
my $resp = <STDIN>;


my $imageDir = '/home/robertm/Desktop';
opendir DIR, "$imageDir" or die "Can't open $imageDir $!";
    my @images = grep { /\.(?:png|PNG|gif|GIF|jpg|JPG|jpeg|JPEG)$/i } readdir DIR;
closedir DIR;
                
my $count = 1;
foreach (@images) {
    print "$count -- $_\n";
    $count = $count + 1;
}
print "\n\n\n";
print "Which image:\n";
my $img_choice = <STDIN>;
print "$images[$img_choice - 1]\n";

system ("mv /home/robertm/Desktop/$images[$img_choice - 1] /home/robertm/Desktop/cover.jpg");




my %cd = get_cd_info();


#my $album_artist = check_artist($cd{artist});

my $album_artist = $cd{artist};
$cd{artist} = check_artist($cd{artist});


fix_all_cd_info(\%cd);

print ".............................. $album_artist <<<<<<<<<<<<<<<<<<<< album artist\n";
print ".............................. $cd{artist} <<<<<<<<<<<<<<<<<<<< artist\n";


print $cd{title}, "\n";

#my $artist_dir = set_artist_dir($cd{artist});
my $artist_dir = '';


my $album_dir = set_album_dir( $cd{artist}, $cd{title} );


my $flac_dir = set_flac_dir( $cd{artist}, $cd{title} );

print "\nAlbum dir: $album_dir\n\n";
print "\nFlac dir: $flac_dir\n\n";


rip_album( \%cd, $artist_dir, $album_dir, $flac_dir, $album_artist);

my $logfile = '/home/robertm/Desktop/Music_Changes.txt';
open(OUTPUT, ">>$logfile") or die "$0: could not open the input file ($logfile): $!\n";
print OUTPUT "Artist:\t\t$cd{artist}\n";
print OUTPUT "Album:\t\t$cd{title}\n\n\n\n";
close(OUTPUT);
exit(0);
__END__

If These Walls Could Speak
This Must Be the Place (Na�ve Melody)
You're Gonna Make Me Lonesome When You Go
==> Cover Girl
==> Shawn Colvin
Auto
--------check_artist()
Does the artist   ||Shawn Colvin||   need altering? [y|n] y
--------_alter_artist()
Enter new artist name: Colvin, Shawn
--------fix_all_cd_info()
--------fix_the()
Shawn Colvin
Shawn Colvin
.............................. Colvin, Shawn <<<<<<<<<<<<<<<<<<<< album artist
.............................. Shawn Colvin <<<<<<<<<<<<<<<<<<<< artist
Cover Girl
--------set_album_dir()
album_dir == /home/robertm/Desktop/Cover Girl
--------set_flac_dir()
flac_dir == /home/robertm/Desktop/flac/Cover Girl
