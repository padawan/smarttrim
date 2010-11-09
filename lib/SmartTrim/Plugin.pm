# ----------------------------------------------------------------------------
# SmartTrim
# A Movable Type text filter to trim strings by length without cutting words.
# http://ubiquitic.com/software/smarttrim-movable-type-plugin.html
#
# Release 2.0 — 2010/11/09 - Switch to HTML::Tidy + mt-tidings
#
# Copyright (C) François Nonnenmacher, Ubiquitic. http://ubiquitic.com/
# ----------------------------------------------------------------------------
# This program is free software: you can redistribute it and/or modify it 
# under the terms of version 2 of the GNU General Public License as published
# by the Free Software Foundation, or (at your option) any later version.  
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License 
# version 2 for more details.  You should have received a copy of the GNU 
# General Public License version 2 along with this program. If not, see 
# <http://www.gnu.org/licenses/>.
# If you distribute it, please keep this notice intact.
# ----------------------------------------------------------------------------

package SmartTrim::Plugin;

use strict;
use MT 4.0;
use MT::Util qw( remove_html );

sub smarttrim {
    my ($s, $attr)  = @_;
    my ($offset, $len, $end, $result, $type, $tidyp_options) = '';

    if (ref($attr) eq 'ARRAY') {
        ($offset, $len) = $attr->[0] =~ m/^(\D?)(\d+)/;
        $end = $attr->[1]; # String to append, if trimming occurs
        $type = $attr->[2]; # Type of HTML, if needs handling
        $tidyp_options = $attr->[3]; # Options for tidying the HTML.
    } else { # Supporting the old 1.0 format
        ($offset, $len, $end) = $attr =~ m/^(\D?)(\d+)(.*?)$/;
    }
    return $s unless ($len > 0);

    my $htmlsource = ($result ne remove_html($result)) ? 1:0; # Source contains HTML
    my $tidy = eval { require HTML::Tidy; HTML::Tidy->new or die; }; # I can handle HTML

    if ($htmlsource && !$tidy) { # Lets get rid of the HTML since I cannot handle unclosed tags
        $s = remove_html($s);
    }

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

    if ($htmlsource && $tidy) { # Source contains HTML, let's make sure tags are closed
        require HTML::Tidy;
        my $params;
        $params->{show_warnings} = 0;
        $params->{show_body_only} = 1;
        if ( $tidyp_options ) {
            my @options = split(/;/, $tidyp_options);
            foreach my $option ( @options ) {
                my @results = split(/:/, $option);
                next unless ( scalar @results == 2 );
                my $key = $results[0];
                my $val = $results[1];
                $key =~ s|\s*(.*)\s*|$1|;
                $val =~ s|\s*(.*)\s*|$1|;
                $params->{$key} = $val;
            }
        }
        if ( $type eq 'html' ) {
            $params->{output_html} = 1;
        }
        elsif ( $type eq 'xml' ) {
            $params->{output_xml} = 1;
        }
        else {
            $params->{output_xhtml} = 1;
        }
        my $tidy = HTML::Tidy->new($params);
        $result = $tidy->clean($result);
    }

    return $result;
}

sub cut_before {
    my $len = shift;
    my $s = shift;
    if (length($s) > $len) {
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

=head1 NAME

SmartTrim::Plugin - A Movable Type global modifier to trim a string to a target length without cutting in the middle of words.

Plugin page: L<http://ubiquitic.com/software/smarttrim-movable-type-plugin.html>

=head1 SYNOPSIS

    <$mt:EntryBody smarttrim="40","…"$>

    <$mt:EntryBody remove_html="1" smarttrim="-40"$>

    <$mt:EntryBody smarttrim="40","…", "html", "numeric_entities:1;drop-empty-paras:1"$>

=head1 DESCRIPTION

I<SmartTrim> trims a string to a target character length without cutting words, and can append an optional ending string to the result.
If the source string contains HTML, I<SmartTrim> will close any unclosed tag.

=head1 PARAMETERS

I<SmartTrim> accepts four parameters: a length value (required), an optional suffix as an ending string, an optional type and an optional list of options.

    smarttrim="[-|+]I<length>"[,"I<suffix>"][,"I<type>"][,"I<options>"]

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

=head2 I<type>

I<type> defines the type of output and can take two values: I<html> or I<xml> (lowercase). If I<type> is omitted or different from those values, then it defaults to XHTML.

=head2 I<options>

I<options> is a list of options passed to tidyp, in the form "key: value; key: value". See C<tidyp -help-config> for the complete list.

=head1 CAVEATS

If the source contains HTML, the length of the HTML code counts against the target length. This means that the I<visible> result may appear shorter than the target length. However, the actual length of the resulting string may be bigger than the expected length if unclosed tags are closed.

If I<SmartTrim> cuts within the start of an HTML block before its enclosing content, it may output an empty block, such as <a href="…"></a>.

=head1 DEPENDENCIES

I<SmartTrim> requires Tidyp and I<HTML::Tidy> by Andy Lester.

=head1 TRIBUTE

Inspired by the original trim_words_by_len filter by Crys Clouse.

=head1 COPYRIGHT & LICENSE

Copyright (C) 2009 François Nonnenmacher, Ubiquitic
L<http://ubiquitic.com/>

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;