#!/usr/bin/perl

if (not defined $ARGV[0]) {die "No parameter given!\n"};

my $path = "/etc/vdr/plugins/graphtftng/themes/opacityXL/scripts";
my $inpath0 = "/etc/vdr/plugins/skinnopacity/logos-git";
my $linkpath = "/etc/vdr/plugins/graphtftng/themes/opacityXL/logos";

%png0 = %png1 = ();

# png folder einlesen
opendir DIR, "$inpath0" or die $!;
while(my $file = readdir DIR) {
    if( $file =~ /\.png$/) {
	$value = $file;
	$file =~ /(.*).png/;
	$key = $1;
	$key =~ s/\W//g;
	$png0{$key} = $value;
    }
}
closedir DIR;


open LOG, ">>$path/translate.log" or die "Can't open log file!\n";

# channels.conf einlesen
open (FILE, "< $ARGV[0]") or die "Can't open file\n";
while (<FILE>) {
    $channame = $shortname = '';
    $line = $_;
    $line =~ s/\r\n//;
    if ($line =~ /^:/ or $line =~ /^@/ ) { next; }

    @line = split(/:/, $line);
    $line[0] =~ s/\'//;
    $line[0] =~ s/\///;
    if ($line[0] =~ m/;/) { $line[0] =~ /(.*);.*/; $line[0] = $1 }

    if ($line[0] =~ m/,/) { 
	@names = split(/,/, $line[0]);
	$channame = $names[0]; $shortname = $names[1];
    }
    else { $channame = $line[0]; $shortname = ''; }

    if ($channame eq '' or $channame eq '.') { next; }
    
    $searchname = $channame;
    $searchname =~ s/\W//g;
    $searchname =~ tr/[A-Z]/[a-z]/;
    
    if ($png0{$searchname}) {
	$cnt++;
	$status = symlink("/etc/vdr/plugins/skinnopacity/logos/$png0{$searchname}","$linkpath/$channame.png");
	if ($status == 1)  { print LOG "$channame => /etc/vdr/plugins/skinnopacity/logos/$png0{$searchname}"; }
	else { print LOG "$channame => failed"; } 
	if ($shortname and $shortname ne '') {
	    $status = symlink("/etc/vdr/plugins/skinnopacity/logos/$png0{$searchname}","$linkpath/$shortname.png");
	    if ($status == 1)  { print LOG "\t$shortname"; }
	    else { print LOG "\t$shortname => failed"; } 
	}
	print LOG "\n"; next;
    }
    elsif ($shortname and $shortname ne '') {
	
	$searchname = $shortname;
	$searchname =~ s/\W//g;
	$searchname =~ tr/[A-Z]/[a-z]/;
    
	if ($png0{$searchname}) {
	    $cnt++;
	    $status = symlink("/etc/vdr/plugins/skinnopacity/logos/$png0{$searchname}","$linkpath/$shortname.png");
	    if ($status == 1)  { print LOG "$channame => /etc/vdr/plugins/skinnopacity/logos/$png0{$searchname}"; }
	    else { print LOG "$shortname => failed"; } 
	    if ($channame and $channame ne '') {
		$status = symlink("/etc/vdr/plugins/skinnopacity/logos/$png0{$searchname}","$linkpath/$shortname.png");
		if ($status == 1)  { print LOG "\t$channame"; }
	    else { print LOG "\t$channame => failed"; }
	    }
	    print LOG "\n"; next;
	}
    }

    $searchname = $channame;
    $searchname =~ s/\W//g;
    $searchname =~ tr/[A-Z]/[a-z]/;
    
}
close(FILE) or die "Can't close file\n";
close(LOG) or die "Can't close file\n";

print $cnt, "\n";
