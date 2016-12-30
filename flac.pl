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
use File::Copy "cp";

use Cwd;

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

my $album_artist = $cd{artist};
$cd{artist} = check_artist($cd{artist});


fix_all_cd_info(\%cd);

print ".............................. $album_artist <<<<<<<<<<<<<<<<<<<< album artist\n";
print ".............................. $cd{artist} <<<<<<<<<<<<<<<<<<<< artist\n";


print $cd{title}, "\n";
my $artist_dir = '';

my $flac_dir = set_flac_dir( $cd{artist}, $cd{title} );

print "\nFlac dir: $flac_dir\n\n";


rip_album( \%cd, $flac_dir, $album_artist);
exit(0);
