# ----------------------------------------------------------------------------
# SmartTrim
# A Movable Type text filter to trim strings by length without cutting words.
# http://ubiquitic.com/software/smarttrim-movable-type-plugin.html
#
# Release 1.1.2 — 2010/01/05 - Relax Defang behavior
# ----------------------------------------------------------------------------
# This free software is provided as-is WITHOUT ANY KIND OF GUARANTEE.
# You may use it for commercial or personal use.
# If you distribute it, please keep this notice intact.
#
# Copyright (C) François Nonnenmacher, Ubiquitic. http://ubiquitic.com/
# ----------------------------------------------------------------------------

package SmartTrim::Plugin;

#use strict;
use MT 4.0;
use HTML::Defang;
use MT::Util qw( remove_html );

sub smarttrim {
	my ($s, $attr)  = @_;
	my ($offset, $len, $end, $result) = '';

	if (ref($attr) eq 'ARRAY') {
		($offset, $len) = $attr->[0] =~ m/^(\D?)(\d+)/;
		$end = $attr->[1];
	} else { # Supporting the old 1.0 format
		($offset, $len, $end) = $attr =~ m/^(\D?)(\d+)(.*?)$/;
	}
	return $s unless ($len > 0);

	if ($offset eq '+') { $result = cut_after($len, $s); }
	elsif ($offset eq '-') { $result = cut_before($len, $s); }
	else {
		my $before = cut_before($len,$s);
		my $after = cut_after($len,$s);
		my $afterdelta = length($after) - $len;
		my $beforedelta = $len - length($before);	
		$result = ($afterdelta < $beforedelta) ? $after : $before ;
	}

	if (($end ne '') && ($result ne $s)) { $result .= $end; }

	if ($result ne remove_html($result)) { # source contains HTML, let's make sure tags are closed
		my @mismatched_tags = qw(a img table tbody thead tr td th font div span pre center p em strong i b q cite blockquote dl dd ul ol li h1 h2 h3 h4 h5 h6 fieldset tt iframe);
		my $Defang = HTML::Defang->new(context => $Self, fix_mismatched_tags => 1, mismatched_tags_to_fix => \@mismatched_tags, url_callback => \&DefangUrlCallback, attribs_callback => \&DefangAttribsCallback );
		$result = $Defang->defang($result);
	}

	return $result;
  }

sub cut_before {
    my $len = shift;
    my $s = shift;
    if (length($s) > $len)
      {
        $s = substr($s, 0, $len+1);
        $s =~ s/(.*)\s.*/$1/; 
      }
    return $s;
}

sub cut_after {
    my $len = shift;
    my $s = shift;
    $s =~ s/^(.{$len}\S*)\s.*$/$1/s;
    return $s;
}

# Callback for custom handling URLs in HTML attributes as well as style tag/attribute declarations
sub DefangUrlCallback {
    my ($Self, $Defang, $lcTag, $lcAttrKey, $AttrValR, $AttributeHash, $HtmlR) = @_;
    return 0; # Explicitly allow all URLs in tag attributes
}

# Callback for custom handling HTML tag attributes
sub DefangAttribsCallback {
    my ($Self, $Defang, $lcTag, $lcAttrKey, $AttrValR, $HtmlR) = @_;
    return 0; # Don't Defang attributes
  }

=head1 NAME

SmartTrim::Plugin - Movable Type global modifier to trim a string to a target length without cutting in middle of words.

Plugin page: L<http://ubiquitic.com/software/smarttrim-movable-type-plugin.html>

=head1 SYNOPSIS

    <$mt:EntryBody smarttrim="40","…"$>

    <$mt:EntryBody remove_html="1" smarttrim="-40"$>

=head1 DESCRIPTION

I<SmartTrim> trims a string to a target character length without cutting words, and can append an optional ending string to the result.
If the source string contains HTML, I<SmartTrim> will close any unclosed tag.

=head1 PARAMETERS

I<SmartTrim> accepts two parameters: a length value (required) and an optional suffix as an ending string.

    smarttrim="[-|+]I<length>"[,"I<suffix>"]

=head2 I<length>

I<length> is an integer defining the target length. I<length> can be prefixed with a + or - sign to influence the behavior of I<SmartTrim> as follows:

=over 4

=item *

"-I<length>" will trim the string at the word ending immediately before or at the specified length, ensuring that the result has a length that is inferior or equal to length.

=item *

"+I<length>" will include the word that would otherwise be cut at the specified length, if any.

=item *

If I<length> is not prefixed by either - or + then the string is trimmed as closely as possible to I<length>.

=back

=head2 I<suffix>

If a I<suffix> string is provided and trimming occurs then it is appended to the result.

=head1 CAVEATS

If I<SmartTrim> closes an unclosed HTML tag, the closing tag will be prefixed with the following comment: <!-- close mismatch --> (this is a feature of Defang).
HTML tags will be closed only if they belong to this hard-coded list: table tbody thead tr td th font div span pre center p em strong i b q cite blockquote dl dd ul ol li h1 h2 h3 h4 h5 h6 fieldset tt

If the source contains HTML, the length of the HTML code counts against the target length. This means that the I<visible> result may appear shorter than the target length. However, the actual length of the resulting string may be bigger than the expect length if unclosed tags are closed.

=head1 DEPENDANCIES

I<SmartTrim> depends on I<HTML::Defang> (included).

=head1 TRIBUTE

Inspired by the original trim_words_by_len filter by Crys Clouse.

=head1 COPYRIGHT & LICENSE

Copyright (C) 2009 François Nonnenmacher, Ubiquitic
L<http://ubiquitic.com/>

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;