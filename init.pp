# ===Class: sccm
#
# This module installs and configures the MS SCCM agent (scrubbed version)
#
# ===Actions:
#    
# 1 - discributes proper tar file for OS and install script
#	2 - runs install script
#	3 - sends email (during test phase, will probably be removed)
#	4 - (future) set $prior and uncomment to delete prior tar file (untested)
#
# ===Requires:
#
# ===Sample Usage:
# 
class sccm {

$subj = "SCCM agent installed on $fqdn"
$addrs = "thing1@umsystem.edu thing2@missouri.edu"

$arc = $architecture ? {
	"x86_64" => "x64",
	default => "x86"
} 

$srcdir = "/usr/local/scrubbed/sccm"
$vers = "1.0.0.4014"
#$prior = "1.0.0.4014"
$ccmfile = "ccm-RHEL$lsbmajdistrelease$arc.$vers.tar"
#$priorccmfile = "ccm-RHEL$lsbmajdistrelease$arc.$prior.tar"


schedule { sccm-prime:
	range => "8 - 17",
	period => hourly,
	repeat => 1
}

file { "$srcdir":
    ensure => directory,
    owner => "root",
    group => "root",
    mode => 750,
}

file { "$srcdir/install":
	notify => Exec["sccm-install"],
	require => File["$srcdir/$ccmfile"],
	source => "puppet:///modules/sccm/install",
	owner => "root",
	group => "root",
	mode => 740,
}

file { "$srcdir/$ccmfile":
	source => "puppet:///modules/sccm/$ccmfile",
	owner => "root",
	group => "root",
	mode => 640,	
}

#file { "$srcdir/$priorccmfile":
#        ensure => absent,
#}

exec { "sccm-install":
	command     => "$srcdir/install -mp scrubbed.fqdn.edu -logdir /var/log/ -keepdb -sitecode xxx $srcdir/$ccmfile",
	refreshonly => true,
	schedule => prime,
        notify => Exec["sccm-mail"],
	}

exec { "sccm-mail":
        command => "echo 'SCCM Linux Agent Install testing' | mail -s '$subj' $addrs",
        refreshonly => true
        }

}


