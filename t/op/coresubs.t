#!./perl

# This file tests the results of calling subroutines in the CORE::
# namespace with ampersand syntax.  In other words, it tests the bodies of
# the subroutines themselves, not the ops that they might inline themselves
# as when called as barewords.

# coreinline.t tests the inlining of these subs as ops.  Since it was
# convenient, I also put the prototype and undefinedness checking in that
# file, even though those have nothing to do with inlining.  (coreinline.t
# reads the list in keywords.pl, which is why it’s convenient.)

BEGIN {
    chdir 't' if -d 't';
    @INC = qw(. ../lib);
    require "test.pl";
    $^P |= 0x100;
}
# Since tests inside evals can too easily fail silently, we cannot rely
# on done_testing. It’s much easier to count the tests as we go than to
# declare the plan up front, so this script ends with a test that makes
# sure the right number of tests have happened.

sub lis($$;$) {
  &is(map(@$_ ? "[@{[map $_//'~~u~~', @$_]}]" : 'nought', @_[0,1]), $_[2]);
}

my %op_desc = (
 readpipe => 'quoted execution (``, qx)',
 ref      => 'reference-type operator',
);
sub op_desc($) {
  return $op_desc{$_[0]} || $_[0];
}


# This tests that the &{} syntax respects the number of arguments implied
# by the prototype, plus some extra tests for the (_) prototype.
sub test_proto {
  my($o) = shift;

  # Create an alias, for the caller’s convenience.
  *{"my$o"} = \&{"CORE::$o"};

  my $p = prototype "CORE::$o";

  if ($p eq '') {
    $tests ++;

    eval " &CORE::$o(1) ";
    like $@, qr/^Too many arguments for $o at /, "&$o with too many args";

  }
  elsif ($p eq '_') {
    $tests ++;

    eval " &CORE::$o(1,2) ";
    my $desc = quotemeta op_desc($o);
    like $@, qr/^Too many arguments for $desc at /,
      "&$o with too many args";

    if (!@_) { return }

    $tests += 6;

    my($in,$out) = @_; # for testing implied $_

    # Since we have $in and $out values, we might as well test basic amper-
    # sand calls, too.

    is &{"CORE::$o"}($in), $out, "&$o";
    lis [&{"CORE::$o"}($in)], [$out], "&$o in list context";

    $_ = $in;
    is &{"CORE::$o"}(), $out, "&$o with no args";

    # Since there is special code to deal with lexical $_, make sure it
    # works in all cases.
    undef $_;
    {
      my $_ = $in;
      is &{"CORE::$o"}(), $out, "&$o with no args uses lexical \$_";
    }
    # Make sure we get the right pad under recursion
    my $r;
    $r = sub {
      if($_[0]) {
        my $_ = $in;
        is &{"CORE::$o"}(), $out,
           "&$o with no args uses the right lexical \$_ under recursion";
      }
      else {
        &$r(1)
      }
    };
    &$r(0);
    my $_ = $in;
    eval {
       is "CORE::$o"->(), $out, "&$o with the right lexical \$_ in an eval"
    };   
  }
  elsif ($p =~ '^;([$*]+)\z') { # ;$ ;* ;$$ etc.
    my $maxargs = length $1;
    $tests += 1;    
    eval " &CORE::$o((1)x($maxargs+1)) ";
    like $@, qr/^Too many arguments for $o at /, "&$o with too many args";
  }
  elsif ($p =~ '^([$*]+);?\z') { # Fixed-length $$$ or ***
    my $args = length $1;
    $tests += 2;    
    eval " &CORE::$o((1)x($args-1)) ";
    like $@, qr/^Not enough arguments for $o at /, "&$o with too few args";
    eval " &CORE::$o((1)x($args+1)) ";
    like $@, qr/^Too many arguments for $o at /, "&$o with too many args";
  }
  elsif ($p =~ '^([$*]+);([$*]+)\z') { # Variable-length $$$ or ***
    my $minargs = length $1;
    my $maxargs = $minargs + length $2;
    $tests += 2;    
    eval " &CORE::$o((1)x($minargs-1)) ";
    like $@, qr/^Not enough arguments for $o at /, "&$o with too few args";
    eval " &CORE::$o((1)x($maxargs+1)) ";
    like $@, qr/^Too many arguments for $o at /, "&$o with too many args";
  }

  else {
    die "Please add tests for the $p prototype";
  }
}

test_proto '__FILE__';
test_proto '__LINE__';
test_proto '__PACKAGE__';

is file(), 'frob'    , '__FILE__ does check its caller'   ; ++ $tests;
is line(),  5        , '__LINE__ does check its caller'   ; ++ $tests;
is pakg(), 'stribble', '__PACKAGE__ does check its caller'; ++ $tests;

test_proto 'abs', -5, 5;

test_proto 'accept';
$tests += 6; eval q{
  is &CORE::accept(qw{foo bar}), undef, "&accept";
  lis [&{"CORE::accept"}(qw{foo bar})], [undef], "&accept in list context";

  &myaccept(my $foo, my $bar);
  is ref $foo, 'GLOB', 'CORE::accept autovivifies its first argument';
  is $bar, undef, 'CORE::accept does not autovivify its second argument';
  use strict;
  undef $foo;
  eval { 'myaccept'->($foo, $bar) };
  like $@, qr/^Can't use an undefined value as a symbol reference at/,
      'CORE::accept will not accept undef 2nd arg under strict';
  is ref $foo, 'GLOB', 'CORE::accept autovivs its first arg under strict';
};

test_proto 'alarm';
test_proto 'atan2';

test_proto 'bind';
$tests += 3;
is &CORE::bind('foo', 'bear'), undef, "&bind";
lis [&CORE::bind('foo', 'bear')], [undef], "&bind in list context";
eval { &mybind(my $foo, "bear") };
like $@, qr/^Bad symbol for filehandle at/,
     'CORE::bind dies with undef first arg';

test_proto 'binmode';
$tests += 3;
is &CORE::binmode(qw[foo bar]), undef, "&binmode";
lis [&CORE::binmode(qw[foo bar])], [undef], "&binmode in list context";
is &mybinmode(foo), undef, '&binmode with one arg';

test_proto 'bless';
$tests += 3;
like &CORE::bless([],'parcel'), qr/^parcel=ARRAY/, "&bless";
like join(" ", &CORE::bless([],'parcel')),
     qr/^parcel=ARRAY(?!.* )/, "&bless in list context";
like &mybless([]), qr/^main=ARRAY/, '&bless with one arg';

test_proto 'break';
{ $tests ++;
  my $tmp;
  CORE::given(1) {
    CORE::when(1) {
      &mybreak;
      $tmp = 'bad';
    }
  }
  is $tmp, undef, '&break';
}

test_proto 'caller';
$tests += 4;
sub caller_test {
    is scalar &CORE::caller, 'hadhad', '&caller';
    is scalar &CORE::caller(1), 'main', '&caller(1)';
    lis [&CORE::caller], [caller], '&caller in list context';
    lis [&CORE::caller(1)], [caller(1)], '&caller(1) in list context';
}
sub {
   package hadhad;
   ::caller_test();
}->();

test_proto 'chr', 5, "\5";
test_proto 'chroot';

test_proto 'closedir';
$tests += 2;
is &CORE::closedir(foo), undef, '&CORE::closedir';
lis [&CORE::closedir(foo)], [undef], '&CORE::closedir in list context';

test_proto 'connect';
$tests += 2;
is &CORE::connect('foo','bar'), undef, '&connect';
lis [&myconnect('foo','bar')], [undef], '&connect in list context';

test_proto 'continue';
$tests ++;
CORE::given(1) {
  CORE::when(1) {
    &mycontinue();
  }
  pass "&continue";
}

test_proto 'cos';
test_proto 'crypt';

test_proto $_ for qw(
 endgrent endhostent endnetent endprotoent endpwent endservent
);

test_proto 'fork';
test_proto 'exp';
test_proto 'fcntl';

test_proto 'fileno';
$tests += 2;
is &CORE::fileno(\*STDIN), fileno STDIN, '&CORE::fileno';
lis [&CORE::fileno(\*STDIN)], [fileno STDIN], '&CORE::fileno in list cx';

test_proto 'flock';
test_proto 'fork';

test_proto "get$_" for qw '
  grent grgid grnam hostbyaddr hostbyname hostent login netbyaddr netbyname
  netent peername ppid priority protobyname protobynumber protoent
  pwent pwnam pwuid servbyname servbyport servent sockname sockopt
';

test_proto 'hex', ff=>255;
test_proto 'int', 1.5=>1;
test_proto 'ioctl';
test_proto 'lc', 'A', 'a';
test_proto 'lcfirst', 'AA', 'aA';
test_proto 'length', 'aaa', 3;
test_proto 'link';
test_proto 'listen';
test_proto 'log';
test_proto "msg$_" for qw( ctl get rcv snd );

test_proto 'not';
$tests += 2;
is &mynot(1), !1, '&not';
lis [&mynot(0)], [!0], '&not in list context';

test_proto 'oct', '666', 438;
test_proto 'opendir';
test_proto 'ord', chr(64), 64;
test_proto 'pipe';
test_proto 'quotemeta', '$', '\$';
test_proto 'readdir';
test_proto 'readlink';
test_proto 'readpipe';

use if !is_miniperl, File::Spec::Functions, qw "catfile";
use if !is_miniperl, File::Temp, 'tempdir';

test_proto 'rename';
{
    last if is_miniperl;
    $tests ++;
    my $dir = tempdir(uc cleanup => 1);
    my $tmpfilenam = catfile $dir, 'aaa';
    open my $fh, ">", $tmpfilenam or die "cannot open $tmpfilenam: $!";
    close $fh or die "cannot close $tmpfilenam: $!";
    &myrename("$tmpfilenam", $tmpfilenam = catfile $dir,'bbb');
    ok open(my $fh, '>', $tmpfilenam), '&rename';
}

test_proto 'ref', [], 'ARRAY';
test_proto 'rewinddir';
test_proto 'rmdir';

test_proto 'seek';
{
    last if is_miniperl;
    $tests += 1;
    open my $fh, "<", \"misled" or die $!;
    &myseek($fh, 2, 0);
    is <$fh>, 'sled', '&seek in action';
}

test_proto 'seekdir';
test_proto "sem$_" for qw "ctl get op";

test_proto "set$_" for qw '
  grent hostent netent priority protoent pwent servent sockopt
';

test_proto "shm$_" for qw "ctl get read write";
test_proto 'shutdown';
test_proto 'sin';
test_proto "socket$_" for "", "pair";
test_proto 'sqrt', 4, 2;
test_proto 'symlink';
test_proto 'sysseek';
test_proto 'telldir';

test_proto 'time';
$tests += 2;
like &mytime, '^\d+\z', '&time in scalar context';
like join('-', &mytime), '^\d+\z', '&time in list context';

test_proto 'times';
$tests += 2;
like &mytimes, '^[\d.]+\z', '&times in scalar context';
like join('-',&mytimes), '^[\d.]+-[\d.]+-[\d.]+-[\d.]+\z',
   '&times in list context';

test_proto 'uc', 'aa', 'AA';
test_proto 'ucfirst', 'aa', "Aa";

test_proto 'vec';
$tests += 3;
is &myvec("foo", 0, 4), 6, '&vec';
lis [&myvec("foo", 0, 4)], [6], '&vec in list context';
$tmp = "foo";
++&myvec($tmp,0,4);
is $tmp, "goo", 'lvalue &vec';

test_proto 'wait';
test_proto 'waitpid';

test_proto 'wantarray';
$tests += 4;
my $context;
my $cx_sub = sub {
  $context = qw[void scalar list][&mywantarray + defined mywantarray()]
};
() = &$cx_sub;
is $context, 'list', '&wantarray with caller in list context';
scalar &$cx_sub;
is($context, 'scalar', '&wantarray with caller in scalar context');
&$cx_sub;
is($context, 'void', '&wantarray with caller in void context');
lis [&mywantarray],[wantarray], '&wantarray itself in list context';

# This is just a check to make sure we have tested everything.  If we
# haven’t, then either the sub needs to be tested or the list in
# gv.c is wrong.
{
  last if is_miniperl;
  require File::Spec::Functions;
  my $keywords_file =
   File::Spec::Functions::catfile(
      File::Spec::Functions::updir,'regen','keywords.pl'
   );
  open my $kh, $keywords_file
    or die "$0 cannot open $keywords_file: $!";
  while(<$kh>) {
    if (m?__END__?..${\0} and /^[-](.*)/) {
      my $word = $1;
      next if
       $word =~ /^(?:CORE|and|cmp|dump|eq|ge|gt|le|lt|ne|or|x|xor)\z/;
      $tests ++;
      ok   exists &{"my$word"}
        || (eval{&{"CORE::$word"}}, $@ =~ /cannot be called directly/),
     "$word either has been tested or is not ampable";
    }
  }
}

# Add new tests above this line.

# ------------ END TESTING ----------- #

is curr_test, $tests+1, 'right number of tests';
done_testing;

#line 3 frob

sub file { &CORE::__FILE__ }
sub line { &CORE::__LINE__ } # 5
package stribble;
sub main::pakg { &CORE::__PACKAGE__ }

# Please do not add new tests here.
