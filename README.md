**SmartTrim** is a plugin for Movable Type that aims to provide a smarter trimming global modifier than `words` or `trim_to`.

The stock MT global modifier `words` cuts at a certain number of words without any control on the resulting length, it will also remove all HTML tags. `trim_to` cuts to a specific length but can cut a string in the middle of a word and can also output invalid HTML in the form of unclosed tags.

SmartTrim:

* trims a string to a target character length without cutting words
* will close any unclosed tags if the source contains HTML _and_ HTML::Tidy is present (otherwise any HTML will be removed before trimming occurs)
* can append an optional ending string like an ellipsis to the result

# Syntax

Once SmartTrim is installed in the MT plugins directory, the global modifier `smarttrim` can be used with four parameters: a _length_ value (required), a _suffix_ as an ending string, a _type_ and a list of _options_ (those last three arguments are optional). E.g.:

	<$mt:EntryBody smarttrim="[-|+]length"[,"suffix"[,"type"[,"options"]]]$>

_length_ is an integer defining the target length. _length_ can be prefixed with a + or - sign to influence the behavior of SmartTrim as follows:

* "-_length_" will trim the string at the word ending immediately before or at the specified length, ensuring that the result has a length that is inferior or equal to length.
* "+_length_" will include the word that would otherwise be cut at the specified length, if any.
* If _length_ is not prefixed by either - or + then the string is trimmed as closely as possible to _length_.


If a _suffix_ string is provided _and_ trimming occurs then it is appended to the result.

You can use a single character such as the ellipsis (…) or a string such as " (…)" (note the leading space), provided it does not start with a digit. Note that the ending is appended as is, so start with a space if you want a space between the resulting string and the ending. Also note that the ending length is _not_ factored in the target length calculations.


_type_ defines the type of output and can take two values: "html" or "xml" (lowercase). If _type_ is omitted or different from those values, then it defaults to "xhtml".


_options_ is a list of any number of HTML::Tidy arguments strung together as `key:value` pairs and separated by semicolons. Run `tidyp -help-config` for the complete list.

## Examples

* `<$mt:EntryBody smarttrim="40"$>` will result in a string that has a length closest to 40 characters
* `<$mt:EntryBody smarttrim="-40"$>` will result in a string that has a maximum length of 40 characters
* `<$mt:EntryBody smarttrim="+40"$>` will result in a string that has a length of more or less 40 characters whether a word may be cut at 40, in which case it is included in the result
* `<$mt:EntryBody smarttrim="-40","…"$>` will trim the source at a maximum length of 40 characters, and add an ellipsis if a cut is performed
* `<$mt:EntryBody smarttrim="40","…", "html", "numeric_entities:1;drop-empty-paras:1"$>` will result in a string that has a length closest to 40 characters, any HTML will be tidied up with special chars replaced with numeric entities and empty paragraphs dropped

# Caveats

If HTML::Tidy is not installed, any HTML in the source string will be removed _before_ trimming occurs (this is a safeguard to prevent the output of malformed HTML). In effect, this is equivalent to `<$mt:EntryBody remove_html="1" smarttrim="…"$>`, which you can use to force removal of HTML.

If HTML::Tidy is present and the source contains HTML, the HTML code counts against the target length. This means that the _rendered_ result may appear shorter than the target length. However, the actual length of the resulting string may be bigger than the expected length if unclosed tags are closed.

If _SmartTrim_ cuts within the start of an HTML block before its enclosing content, it may output an empty block, such as `<a href="…"></a>`.

# Installation

* Install <a href="https://github.com/petdance/tidyp">tidyp</a>
* Install <a href="https://github.com/petdance/html-tidy">html-tidy</a> (or <a href="http://search.cpan.org/~petdance/HTML-Tidy/">HTML::Tidy</a> from CPAN)
* Download <a href="http://github.com/padawan/smarttrim" onClick="javascript: pageTracker._trackPageview('/software/smarttrim.github');">SmartTrim</a>
* Uncompress and copy the SmartTrim folder into your MT plugins directory.

# Release history

* Version 2.0 - 2010/11/09 - Switch to HTML::Tidy in replacement of HTML::Defang.
* Version 1.1.2 - 2010/01/05 - Relaxing the sanitization done by HTML::Defang.
* Version 1.1.1 - 2009/11/02 - Added L10N files and French translation.
* Version 1.1 - 2009/10/22 - Modified the arguments syntax. Added HTML::Defang to close HTML tags. Added POD.
* Version 1.0 - 2009/10/19 - First public version.

# NOTE

Once you have installed HTML::Tidy, you might also be interested by the <a href="https://github.com/movabletype/mt-plugin-tidings/">Tidings plugin</a> for MT.

# Tribute

This plugin has been inspired by the <a href="http://plugins.movabletype.org/trimwordsbylen/">TrimWordsbyLen</a> plugin from Crys Clouse.  
Thanks to Su, Brice, Steeve, Michael and Byrne for the feedback and suggested improvements.
Thanks to Andy Lester for HTML::Tidy and tidyp.

# Copyright & License

Copyright (C) 2009-2010 François Nonnenmacher, Ubiquitic.

This free software is provided as-is WITHOUT ANY KIND OF GUARANTEE; you can redistribute it and/or modify it under the same terms as Perl itself.