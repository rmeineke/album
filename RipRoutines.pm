package RipRoutines;

use strict;
use warnings;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

BEGIN { $CDDB_get::debug = 1 }

use CDDB_get qw( get_cddb );
use MP3::Info;
use MP3::Tag;
use File::Copy;
use File::Copy qw(move);



$VERSION     = 1.00;
@ISA         = qw(Exporter);
@EXPORT      = qw();
@EXPORT_OK   = qw(
                  fix_the 
                  strip_the 
                  get_cd_info 
                  fix_all_cd_info
                  set_artist_dir
                  set_album_dir
                  set_flac_dir
                  rip_album
                  get_manual_cd_info
                  check_artist
                 );

my $DEBUG = 1;



#strip extraneous characters that might
#cause filename difficulties
sub fix_file_name {
    print "--------fix_file_name()\n" if $DEBUG;
    my $track = shift;
    
    #added parens
    $track =~ s/[^ a-zA-Z0-9_.'()]//g;
    $track =~ s/\s+$//;
    return $track;
}

sub check_artist {
	print "--------check_artist()\n" if $DEBUG;
	my $artist = shift;
	
	print 'Does the artist   ||', $artist, '||   need altering? [y|n] ';
	my $resp = <STDIN>;
	if ($resp =~ m/\A[Yy]/) {
		return _alter_artist($artist);
	} else {
		return $artist;
	}

}

sub _alter_artist {
    print "--------_alter_artist()\n" if $DEBUG;
    my $artist = shift;


    print 'Enter new artist name: ';
    my $new_artist = <STDIN>;
    chomp $new_artist;
    
    #rsm 2015.08.15
    if ($new_artist eq '') {
        print "Switch the first and last names here.....\n";
        $new_artist = _swap_first_and_last($artist);
    }   
    
    return $new_artist;
}

sub _swap_first_and_last {
    print "::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n";
    my $artist = shift;
    chomp $artist;
    
    print "\n\n_swap_first_and_last ==== $artist\n\n";
    $artist =~ m/\A(.*)\s(.*)\z/xms;
    my $fn = $1;
    my $ln = $2;
    print "$fn\n";
    print "$ln\n";
    $artist = $ln . ', ' . $fn;
    return $artist;
    print "::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n";
}



#:::::::::::::::::::::::::::::::::::
#::::::::::::::::::::::::::::::::::
#::: _commify()
#:::::::::::::::::::::::::::::::::::
#:::::::::::::::::::::::::::::::::::
sub _commify {
    print "--------_commify()\n" if $DEBUG;
    my $artist = shift;
    $artist =~ m/\A(\S+)\s(.*)\z/xms;
    my $str = "$2, $1";
    return $str;
}

#:::::::::::::::::::::::::::::::::::
#:::::::::::::::::::::::::::::::::::
#::: rip_album()
#:::::::::::::::::::::::::::::::::::
#:::::::::::::::::::::::::::::::::::
sub rip_album {
    print "--------rip_album()\n" if $DEBUG;
    my $cd         = shift;
    my $flac_dir   = shift;
    my $album_artist = shift;
    
    
    my $year = $$cd{year};
    #2015.07.28 ... fixed minor glitch 
    if (!defined $year) {
        $year = '';
    };
    
    my $num        = $$cd{tno};
    my $cmd;

    #batch rip
    $cmd = qq{cdparanoia -B};
    system $cmd;

    for ( my $i = 0; $i < $num; $i++ ) {
        my $current_track_num = $i + 1;
        my $current_wav       = sprintf "track%02d.cdda.wav", $current_track_num;
        my $track_name        = $$cd{track}[$i];
        print "Track name: $track_name\n" if $DEBUG;
        $track_name = fix_file_name($track_name);
        #my $current_track_name = sprintf "%02d - %s.mp3", $current_track_num, $track_name;
        my $current_flac_name =  sprintf "%02d - %s.flac", $current_track_num, $track_name;
        
       
        $cmd = "flac -f --best --keep-foreign-metadata --output-name=\"$flac_dir/$current_flac_name\" $current_wav";
        print $cmd, "\n";
        system $cmd;
        
        my $artfile;
        if (-e '/home/robertm/Desktop/cover.jpg') {
            $artfile = '/home/robertm/Desktop/cover.jpg';
        } else {
            #tweaked this path 
            $artfile = '/home/robertm/scripts/album/album.jpg';
        }
        #$cmd = "metaflac --remove-all-tags --set-tag=\"ALBUM=$$cd{title}\" --set-tag=\"TITLE=$$cd{track}[$i]\" --set-tag=\"ARTIST=$$cd{artist}\" --set-tag=\"TRACKNUMBER=$current_track_num\" --set-tag=\"TRACKTOTAL=$num\" --set-tag=\"ALBUMARTIST=albumartist\" --import-picture-from=\"$artfile\" \"$flac_dir/$current_flac_name\"";
        $cmd = "metaflac --remove-all-tags  --set-tag=\"DATE=$year\"  --set-tag=\"ALBUM=$$cd{title}\" --set-tag=\"TITLE=$$cd{track}[$i]\" --set-tag=\"ARTIST=$$cd{artist}\" --set-tag=\"TRACKNUMBER=$current_track_num\" --set-tag=\"TRACKTOTAL=$num\" --set-tag=\"ALBUMARTIST=$album_artist\" --import-picture-from=\"$artfile\"  \"$flac_dir/$current_flac_name\"";
        system $cmd;
        
        print "\n\n\n\n$cmd\n\n\n\n";
        
        unlink "$current_wav";
    }#for
    $cmd = 'eject -v /dev/sr0';
    system $cmd;
    
    
    #move('/home/robertm/Desktop/cover.jpg', '/home/robertm/Desktop/last_used_cover.jpg');
    #unlink '/home/robertm/Desktop/cover.jpg';
    unlink 'track00.cdda.wav';
}#rip_album

#:::::::::::::::::::::::::::::::::::
#:::::::::::::::::::::::::::::::::::
#::: set_artist_dir()
#:::::::::::::::::::::::::::::::::::
#:::::::::::::::::::::::::::::::::::
sub set_artist_dir {

    #print "--------set_artist_dir()\n" if $DEBUG;
    #my $artist     = shift;
    #my $artist_dir = "$artist";
    #print "artist_dir == $artist_dir\n" if $DEBUG;
    #if ( !-e $artist_dir ) {
        #mkdir $artist_dir;
    #}
    #return $artist_dir;
}

sub _get_random_str {
	my $str;
	
	my @letters = qw(a b c d e f g h i j k l m n o p q r s t u v w x y z);
	my $range = 25;
	my $random_number;
	
	for (my $i = 0; $i < 4; $i++) {
		$random_number = int(rand($range));
		$str = $str . $letters[$random_number];		
	}
	return $str;
}
#:::::::::::::::::::::::::::::::::::
#:::::::::::::::::::::::::::::::::::
#::: set_album_dir()
#:::::::::::::::::::::::::::::::::::
#:::::::::::::::::::::::::::::::::::
sub set_album_dir {
    print "--------set_album_dir()\n" if $DEBUG;
    my $artist = shift;
    my $album = shift;
    $album =~ s/[^ a-zA-Z0-9_.']//g;
    $album =~ s/\s+$//;
    #my $album_dir = "$artist/$artist -- $album";
    
    #2011.01.23
    my $album_dir = "/home/robertm/Desktop/$album";
    print "album_dir == $album_dir\n" if $DEBUG;
    
    ## this checks to see if the album directory
    ## exists....
    ## 
    ## if it does grab a random string, add it to 
    ## the directory name and create
    ## that new directory.
    ## 
    ## this will keep us from clobbering any existing
    ## directories
    while (1) {
	    if (! -e $album_dir) {
	        mkdir $album_dir;
	        last;
	    } else {
			my $random_str = _get_random_str();
			$album_dir = $album_dir . '--' . $random_str;
		}	    
	}
    return $album_dir;        
}

sub set_flac_dir {
    print "--------set_flac_dir()\n" if $DEBUG;
    my $artist = shift;
    my $album = shift;
    $album =~ s/[^ a-zA-Z0-9_.']//g;
    $album =~ s/\s+$//;
    
    my $flac_dir = "/home/robertm/Desktop/" . $artist . ' - ' . $album;
    print "flac_dir == $flac_dir\n" if $DEBUG;
        
    while (1) {
	    if (! -e $flac_dir) {
	        mkdir $flac_dir;
	        last;
	    } else {
			my $random_str = _get_random_str();
			$flac_dir = $flac_dir . '--' . $random_str;
		}
	}
    print('--- set_flac_dir about to return: ' . $flac_dir);
    return $flac_dir;        
}


#:::::::::::::::::::::::::::::::::::
#:::::::::::::::::::::::::::::::::::
#::: fix_all_cd_info()
#:::::::::::::::::::::::::::::::::::
#:::::::::::::::::::::::::::::::::::
sub fix_all_cd_info {
    my $cd = shift;
    print "--------fix_all_cd_info()\n" if $DEBUG;

    $$cd{artist} = fix_the($$cd{artist});
    
    #added back in ..... 2016.05.29
    $$cd{title} = fix_the($$cd{title});
    
    my $num = $$cd{tno};

}


#:::::::::::::::::::::::::::::::::::
#:::::::::::::::::::::::::::::::::::
#::: get_cd_info()
#:::::::::::::::::::::::::::::::::::
#:::::::::::::::::::::::::::::::::::
sub get_cd_info {
    print "--------get_cd_info()\n" if $DEBUG;
    my %config;
    # get cd info
    # following variables just need to be declared if different from defaults
    $config{CDDB_HOST}='freedb.freedb.org';        # set cddb host
    $config{CDDB_PORT}=8880;                       # set cddb port
    $config{CDDB_MODE}='http';                     # set cddb mode: cddb or http
    
    $config{CD_DEVICE}='/dev/sr0';             # set cd device

    # user interaction welcome?
    $config{input}=1;   # 1: ask user if more than one possibility
                        # 0: no user interaction
                        
                        
    # get it on
    my %cd;
    %cd=get_cddb(\%config);
    print "done get_cddb\n";
    
        
    if ($DEBUG) {
        ####2015.05.13
        print "//////////////////////////////////\n";
        print "//////////////////////////////////\n";
        print "//////////////////////////////////\n";
        print "//////////////////////////////////\n";
    
        foreach my $key (sort(keys %cd)) {
            print $key, ' = ', $cd{$key}, "\n";
        }
        print "//////////////////////////////////\n";
        print "//////////////////////////////////\n";
        print "//////////////////////////////////\n";
        
        
        print "//////////////////////////// data\n";
        foreach my $datum (@{$cd{data}}) {
            print $datum, "\n";
        }
        print "//////////////////////////// frame\n";
        foreach my $frame (@{$cd{frame}}) {
            print $frame, "\n";
        }
        print "//////////////////////////// raw\n";
        foreach my $r (@{$cd{raw}}) {
            print $r, "\n";
        }
        print "//////////////////////////// track\n";
        foreach my $t (@{$cd{track}}) {
            print $t, "\n";
        }
    }
    
    print "==> ", $cd{title}, "\n";
    print "==> ", $cd{artist}, "\n";

    if (defined $cd{title}) {
        print "Auto\n";
    } else {
        print "Manual\n";
        %cd = _prompt_for_cd_info();
    }
    return %cd;
}

#:::::::::::::::::::::::::::::::::::
#:::::::::::::::::::::::::::::::::::
#::: fix_the()
#:::::::::::::::::::::::::::::::::::
#:::::::::::::::::::::::::::::::::::
sub fix_the {
    print "--------fix_the()\n" if $DEBUG;
    my $str = shift;
    print $str, "\n";
    if ($str =~ m/\AThe\s(.*)\s(\(.*\))/ixms) {
        print "--------fix_the() ..... first regex .... \n" if $DEBUG;
        $str = $1 . ', The ' . $2    
    } elsif ($str =~ m/\AThe\s(.*)/ixms) {
        print "--------fix_the() ..... second regex .... \n" if $DEBUG;
        $str = $1 . ', The';
    }
    print $str, "\n";
    return $str;
}

#:::::::::::::::::::::::::::::::::::
#:::::::::::::::::::::::::::::::::::
#::: strip_the()
#:::::::::::::::::::::::::::::::::::
#:::::::::::::::::::::::::::::::::::
sub strip_the {
    print "--------strip_the()\n" if $DEBUG;
    my $str = shift;
    if ($str =~ m/\AThe\s(.*)/ixms) {
        $str = $1;
    }
    return $str;
}


#:::::::::::::::::::::::::::::::::::
#:::::::::::::::::::::::::::::::::::
#::: _prompt_for_cd_info()
#:::::::::::::::::::::::::::::::::::
#:::::::::::::::::::::::::::::::::::
sub _prompt_for_cd_info {
    print "--------_prompt_for_cd_info()\n" if $DEBUG;
    my %cd;
    
    print "Artist: ";
    my $artist = <STDIN>;
    chomp $artist;
    $cd{artist} = $artist;
        
    print "Album: ";
    my $album = <STDIN>;
    chomp $album;
    $cd{title} = $album;
        
    print "Number of tracks: ";
    my $num_tracks = <STDIN>;
    chomp $num_tracks;
    $cd{tno} = $num_tracks;
    
    print "Use default track names? [y|n] ";
    my $resp = <STDIN>;
    chomp $resp;
    if ($resp =~ m/\A[Yy]/ixms) {
        print "Default track names\n";
        for (my $i = 0; $i < $num_tracks; $i++) {
            my $name = sprintf "Track_%02d", ($i + 1);
            $cd{track}[$i] = $name;        
            print ":::::::: $name\n" if $DEBUG;
       }
    } else {
        print "Prompt for track names\n";
        _get_track_names($num_tracks, \%cd);
    }

    return %cd;
}
#:::::::::::::::::::::::::::::::::::
#:::::::::::::::::::::::::::::::::::
#::: _get_track_names()
#:::::::::::::::::::::::::::::::::::
#:::::::::::::::::::::::::::::::::::
sub _get_track_names {
    print "--------_get_track_names\n" if $DEBUG;

    my $num = shift;
    my $cd_ref = shift;
    print $cd_ref;

    for (my $i = 0; $i < $num; $i++) {
        my $prompt = sprintf "Track %02d title: ", ($i + 1);
        print $prompt;
        my $title = <>;
        chomp $title;
        $$cd_ref{track}[$i] = $title;
    }

}

#=======================
1;#=====================
#=======================
