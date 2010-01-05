**SmartTrim** is a plugin for Movable Type 4 that aims to provide a smarter trimming global modifier than _words_ or *trim_to*.

The stock MT global modifier _words_ cuts at a certain number of words without any control on the resulting length, it will also remove all HTML tags. *trim_to* cuts to a specific length but can cut a string in the middle of a word and can also output invalid HTML in the form of unclosed tags.

SmartTrim:

* trims a string to a target character length without cutting words
* will close any unclosed tags if the source contains HTML
* can append an optional ending string like an ellipsis to the result

# Syntax

Once SmartTrim is installed in the MT plugins directory, the global modifier `smarttrim` can be used with two parameters: a _length_ value (required) and an optional _suffix_ as an ending string. E.g.:

	<$mt:EntryBody smarttrim="[-|+]length"[,"suffix"]$>

_length_ is an integer defining the target length. _length_ can be prefixed with a + or - sign to influence the behavior of SmartTrim as follows:


* "-_length_" will trim the string at the word ending immediately before or at the specified length, ensuring that the result has a length that is inferior or equal to length.
* "+_length_" will include the word that would otherwise be cut at the specified length, if any.
* If _length_ is not prefixed by either - or + then the string is trimmed as closely as possible to _length_.


If a _suffix_ string is provided _and_ trimming occurs then it is appended to the result.

You can use a single character such as the ellipsis (…) or a string such as " (…)" (note the leading space), provided it does not start with a digit. Note that the ending is appended as is, so start with a space if you want a space between the resulting string and the ending. Also note that the ending length is _not_ factored in the target length calculations.

## Examples

* `<$mt:EntryBody smarttrim="40"$>` will result in a string that has a length closest to 40 characters
* `<$mt:EntryBody smarttrim="-40"$>` will result in a string that has a maximum length of 40 characters
* `<$mt:EntryBody smarttrim="+40"$>` will result in a string that has a length of more or less 40 characters whether a word may be cut at 40, in which case it is included in the result
* `<$mt:EntryBody smarttrim="-40","…"$>` will trim the source at a maximum length of 40 characters, and add an ellipsis if a cut is performed

# Caveats

If _SmartTrim_ closes an unclosed HTML tag, the closing tag will be prefixed with the following comment: `<!-- close mismatch -->` (this is a feature of HTML::Defang).  
HTML tags will be closed only if they belong to this hard-coded list: `a img table tbody thead tr td th font div span pre center p em strong i b q cite blockquote dl dd ul ol li h1 h2 h3 h4 h5 h6 fieldset tt`.

If the source contains HTML, the length of the HTML code counts against the target length. This means that the _"visible"_ result may appear shorter than the target length. However, the actual length of the resulting string may be bigger than the expect length if unclosed tags are closed.

If the source string contains HTML and you need to get rid of it, use the `remove_html` attribute _before_ `smarttrim`, like so:

	<$mt:EntryBody remove_html="1" smarttrim="40"$>

If you place the `remove_html` modifier after `smarttrim`, any HTML code in the source string will count against the length calculations.

# Installation

* Download <a href="http://github.com/padawan/smarttrim" onClick="javascript: pageTracker._trackPageview('/software/smarttrim.github');">SmartTrim</a>
* Uncompress and copy the SmartTrim folder into your MT plugins directory.

# Release history

* Version 1.1.2 - 2010/01/05 - Relaxing the sanitization done by HTML::Defang.
* Version 1.1.1 - 2009/11/02 - Added L10N files and French translation.
* Version 1.1 - 2009/10/22 - Modified the arguments syntax. Added HTML::Defang to close HTML tags. Added POD.
* Version 1.0 - 2009/10/19 - First public version.

# TODO

Make the tag closing list a modifiable preference of the plugin.

# Tribute

This plugin has been inspired by the <a href="http://plugins.movabletype.org/trimwordsbylen/">TrimWordsbyLen</a> plugin from Crys Clouse.  
Thanks to Su, Brice, Steeve, Michael and Byrne for the feedback and suggested improvements.

# Copyright & License

Copyright (C) 2009 François Nonnenmacher, Ubiquitic.

This free software is provided as-is WITHOUT ANY KIND OF GUARANTEE; you can redistribute it and/or modify it under the same terms as Perl itself.