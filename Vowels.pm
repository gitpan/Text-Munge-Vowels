package Text::Munge::Vowels;
require 5.000;
require Exporter;

=head1 NAME

Text::Munge::Vowels - removes vowels from words phrases

=head1 SYNOPSIS

    use Text::Munge::Vowels;

    $obj = new Text::Munge::Vowels();
    $obj->add_stopwords LIST

    $string = $obj->munge LIST

=head1 DESCRIPTION

Text::Munge::Vowels strips vowels spaces from words and phrases to shorten
the length of simple text messages, as might be used for to send weather
forecasts or short news items to alphanumeric pagers with limited message
or screen sizes.

Note that there's another module on CPAN called I<Lingua-EN-Squeeze>
intended for the same purpose.

=head1 EXAMPLE

    use Text::Munge::Vowels();

    $munger = new Text::Munge::Vowels();

    $text = "This sentence will have some of it\'s vowels removed.";

    print $munger->munge($text), "\n";

=head1 CAVEATS

Overuse can make messages unreadable. "Decoding" the output of this module
requires a human (?) brain familiar with the language and the context of
the messages.

Some would argue the use of this module is suspect.

=head1 FUTURE ENHANCEMENTS

Improve the regular expression in I<$DefaultMungeRule> to ignore double
or triple vowels in short words.

Actually, I am working on a separate module which will load specialized
vocabularies from XML files. If this module evolves at all, it will be
as a wrapper to that module.

=head1 AUTHOR

Robert Rothenberg <wlkngowl@unix.asb.com>

=cut

use vars qw($VERSION $LANGUAGE $MinLength $MungeRule @StopWords);
$VERSION = "0.5.1";
$LANGUAGE = "en-US";		# language code (for rules and stop words)

@ISA = qw(Exporter);
@EXPORT = qw();

use Carp;

my $DefaultMinLength = 4;

my $DefaultMungeRule = '\B[aeiouy]\B';   # only strip inner vowels

  # Notice the wholey incomplete list of default "stop words" is weather-
  # releated. In part because the idea for this module came from a hack
  # that fetched the current weather and E-mailed it to my pager every
  # morning...

my @DefaultStopWords = qw(
    clad clod cloud color cool cooler
    early east
    fair fear fire four flier floor flour
    hail heat
    live leave leaves
    more
    NASA nearer NOAA
    rain
    skies
    tree trees
);

sub initialize {
    my $self = shift;
    $self{VERSION} = $VERSION;
    $self{LANGUAGE} = $LANGUAGE;
    $self{MinLength} = $DefaultMinLength;
    $self{MungeRule} = $DefaultMungeRule;
    $self{StopWords} = \@DefaultStopWords;
}

sub new {
    my $this = shift;
    my $class = ref($this) || $this;
    my $self = {};
    bless $self, $class;
    $self->initialize();
    return $self;
}

sub import {
    my $self = shift;
    export $self;

    my @imports = @_;
    if (@imports) {
        carp "import() ignored in ".__PACKAGE__." v$VERSION";
    }
}

sub add_stopwords {
    my $self = shift;

  # yes this adds duplicate words, but for this version it does not matter
    my @words= @_;
    foreach (@words) {
        push @{$self{StopWords}}, $_;
    }
}

sub munge {
    my $self = shift;

    my $phrase = shift;
    my $word, $buffer='';

    foreach $word (split /\b/, $phrase) {
        unless ((length($word)<$self{MinLength}) or (grep (/\b$word\b/i, @{$self{StopWords}} ))) {
            $word =~ s/$self{MungeRule}//ig;
        }        
        $buffer .= $word;
    }

    return $buffer;
}

1;

__END__
