# digraphs.kak

This plugin for the Kakoune editor allows prose writers to insert Vim-style digraphs (i.e., Unicode
symbols with an associated two-character code) in the text they are working on.

## Symbol Set

The set of available symbols was adapted from Vim's. Whereas 33 control codes and modifiers (from
U+02C7 to U+02DD) were removed, 81 printable symbols were added.

In the currency ([CURR]) category:

| Code point | Description         |
|:-----------|:--------------------|
| U+20A0     | EURO-CURRENCY SIGN  |
| U+20A1     | COLON SIGN          |
| U+20A2     | CRUZEIRO SIGN       |
| U+20A3     | FRENCH FRANC SIGN   |
| U+20A4     | LIRA SIGN           |
| U+20A5     | MILL SIGN           |
| U+20A6     | NAIRA SIGN          |
| U+20A7     | PESETA SIGN         |
| U+20A8     | RUPEE SIGN          |
| U+20A9     | WON SIGN            |
| U+20AA     | NEW SHEQEL SIGN     |
| U+20AB     | DONG SIGN           |
| U+20AC     | EURO SIGN           |
| U+20AD     | KIP SIGN            |
| U+20AE     | TUGRIK SIGN         |
| U+20AF     | DRACHMA SIGN        |
| U+20B0     | GERMAN PENNY SYMBOL |
| U+20B1     | PESO SIGN           |
| U+20B2     | GUARANI SIGN        |
| U+20B3     | AUSTRAL SIGN        |
| U+20B4     | HRYVNIA SIGN        |
| U+20B5     | CEDI SIGN           |
| U+20B6     | LIVRE TOURNOIS SIGN |
| U+20B7     | SPESMILO SIGN       |
| U+20B8     | TENGE SIGN          |


In the punctuation ([PUNCT]) category:

| Code point | Description                      |
|:-----------|:---------------------------------|
| U+2026     | HORIZONTAL ELLIPSIS              |
| U+2027     | HYPHENATION POINT                |
| U+2042     | ASTERISM                         |
| U+204A     | TIRONIAN SIGN ET                 |
| U+204B     | REVERSED PILCROW SIGN            |
| U+204C     | BLACK LEFTWARDS BULLET           |
| U+204D     | BLACK RIGHTWARDS BULLET          |
| U+2051     | TWO ASTERISKS ALIGNED VERTICALLY |
| U+2058     | FOUR DOT PUNCTUATION             |
| U+2059     | FIVE DOT PUNCTUATION             |
| U+205A     | TWO DOT PUNCTUATION              |
| U+205B     | FOUR DOT MARK                    |
| U+205D     | TRICOLON                         |
| U+205E     | VERTICAL FOUR DOTS               |

In the category of letter-like symbols ([CHAR]):

| Code point | Description                    |
|:-----------|:-------------------------------|
| U+2107     | EULER CONSTANT                 |
| U+2108     | SCRUPLE                        |
| U+210A     | SCRIPT SMALL G                 |
| U+210B     | SCRIPT CAPITAL H               |
| U+210C     | BLACK-LETTER CAPITAL H         |
| U+210D     | DOUBLE-STRUCK CAPITAL H        |
| U+210E     | PLANCK CONSTANT                |
| U+210F     | PLANCK CONSTANT OVER TWO PI    |
| U+2110     | SCRIPT CAPITAL I               |
| U+2111     | BLACK-LETTER CAPITAL I         |
| U+2112     | SCRIPT CAPITAL L               |
| U+2113     | SCRIPT SMALL L                 |
| U+2114     | L B BAR SYMBOL                 |
| U+2115     | DOUBLE-STRUCK CAPITAL N        |
| U+2118     | SCRIPT CAPITAL P               |
| U+2119     | DOUBLE-STRUCK CAPITAL P        |
| U+211A     | DOUBLE-STRUCK CAPITAL Q        |
| U+211B     | SCRIPT CAPITAL R               |
| U+211C     | BLACK-LETTER CAPITAL R         |
| U+211D     | DOUBLE-STRUCK CAPITAL R        |
| U+2127     | INVERTED OHM SIGN              |
| U+2128     | BLACK-LETTER CAPITAL Z         |
| U+212A     | KELVIN SIGN                    |
| U+212C     | SCRIPT CAPITAL B               |
| U+212D     | BLACK-LETTER CAPITAL C         |
| U+2130     | SCRIPT CAPITAL E               |
| U+2131     | SCRIPT CAPITAL F               |
| U+2133     | SCRIPT CAPITAL M               |
| U+213C     | DOUBLE-STRUCK SMALL PI         |
| U+213D     | DOUBLE-STRUCK SMALL GAMMA      |
| U+213E     | DOUBLE-STRUCK CAPITAL GAMMA    |
| U+213F     | DOUBLE-STRUCK CAPITAL PI       |
| U+2140     | DOUBLE-STRUCK N-ARY SUMMATION  |
| U+2145     | DOUBLE-STRUCK ITALIC CAPITAL D |
| U+2146     | DOUBLE-STRUCK ITALIC SMALL D   |
| U+2147     | DOUBLE-STRUCK ITALIC SMALL E   |
| U+2148     | DOUBLE-STRUCK ITALIC SMALL I   |
| U+2149     | DOUBLE-STRUCK ITALIC SMALL J   |

In the misc-technical ([TECH]) category:

| Code point | Description               |
|:-----------|:--------------------------|
| U+2300     | DIAMETER SIGN             |
| U+2301     | ELECTRICAL ARROW          |
| U+2318     | PLACE OF INTEREST SIGN    |
| U+23E3     | BENZENE RING WITH CIRCLE  |

As a result, **1305 Unicode symbols are available**. They are stored in a **plain-text datafile**,
`digraphs.dat`, which accompanies the plugin. For the plugin to work, this datafile should be
installed in a `digraphs` subdirectory of `${kak_config}`.

**Note**: because of a new symbol, U+212C (SCRIPT CAPITAL B), the digraph for U+25AA ([SHAPE] BLACK
SMALL SQUARE) has been changed from Vim's `sB` to `sq`. All of the other digraphs are compatible
with Vim's.

## Writing symbols

The plugin makes available two methods to write symbols in Insert mode: **symbol search** and
**digraph conversion**. Each method has different purposes and is called by pressing a different
shortcut key.

The shortcut keys for symbol search and digraph conversion are configured through the
`digraphs-enable-on <key1> <key2>` command, which you can add to your `kakrc`with the key values of
your choice (e.g., `<a-d>` and `<a-k>`).

A third method, **selection sweep**, is available in Normal mode.

### Symbol search

**Symbol search** is best when you do not know the digraph of the symbol you are looking for, or
when you are not sure. On pressing `<key1>` in Insert mode, a prompt will ask you to type a search
string. If the search string is two-character long (e.g., `=>`), it will be interpreted as a digraph
and a menu will show you the corresponding symbol.

If your search string is not two-character long, it will be interpreted as a search term matching
Unicode descriptions. For example, searching for `arrow` will open a menu with ten different types
of arrows. As you explore the menu, Unicode values and digraphs will be displayed on the prompt
line, giving you an opportunity to remember them.

Your search term can include spaces, which will be replaced by the wildcard, `.*`, allowing for
flexible searches (e.g., `left arrow`). If you want to include literal spaces, replace them with
underscores (e.g., `letter_a`). You can also search for hexadecimal code values (e.g., `23E3`).

Accepting a menu item causes the symbol to be inserted at the place of the cursor. **Multiple
cursors are allowed**.

### Digraph conversion

If you know the digraph code of the symbol you want to insert, then you can use **digraph
conversion** instead of symbol search: just type your digraph, then `<key2>` in Insert mode.

Provided it is preceded by a space, the beginning of a line, or a single character after the
beginning of a line, the digraph you typed will be converted into the corresponding symbol.

Two commands allow you to configure digraph conversion.

The `digraphs-use-postfix <key(s)>` command allows you to **insert a postfix** after the converted
symbol. `<key(s)>` consists of `<space>` by default, but you can replace it by any other postfix, or
remove it altogether with `digraphs-use-postfix ""`.

The `digraphs-include-word <yes|no>`command allows you to extend conversion to the **last word you
typed** or to always limit conversion to the last two characters. This option equals _yes_ by
default, which makes it easy to convert groups of digraphs. For example, typing:

    s*o*f*o'*s<key2>

as a word will produce:

    σοφóς

in one pass.

Finally, pressing `<key2>` after a space, at the beginning of a line, or one character after the
beginning of a line, **will reinsert the last inserted symbol**.

**Note**: With the insertion postfix set to `<space>` (the default), pressing `<key2>` repeatedly
will fill the line with copies of the last inserted symbol. When applied to multiple cursors, **a
tile of identical symbols** will be produced. For example, with digraph `ps`:

    ⌘ ⌘ ⌘ ⌘ ⌘ ⌘ ⌘
    ⌘ ⌘ ⌘ ⌘ ⌘ ⌘ ⌘
    ⌘ ⌘ ⌘ ⌘ ⌘ ⌘ ⌘
    ⌘ ⌘ ⌘ ⌘ ⌘ ⌘ ⌘
    ⌘ ⌘ ⌘ ⌘ ⌘ ⌘ ⌘
    ⌘ ⌘ ⌘ ⌘ ⌘ ⌘ ⌘
    ⌘ ⌘ ⌘ ⌘ ⌘ ⌘ ⌘

### Selection sweep (dig)

In Normal mode, calling the `digraphs-sweep-selection` command (alias: `dig`) will convert **each
valid digraph in your selection** to the corresponding symbol. Although using **dig** over large
sweeps of text is not generally recommended (because it is easy to have regular letter pairs
converted unwittingly), the command comes in handy when drawing line diagrams or trees.

For example, typing:

    a*
    vrhhhhhh b*+
    vrhhhhhh g*+
    urhhhhhh d*+

and calling **dig** after selecting the three lines will produce:

    α
    ├─── β+
    ├─── γ+
    └─── δ+

in one sweep.

If you use **dig** on a regular basis, then you may want to map a normal- or user-mode key
to `': dig <ret>'` and add this mapping to your `kakrc`.

## Installation

Installation is manual.

First, create a `digraphs` directory in `$HOME/.config/kak/`, and put the `digraphs.dat` datafile in

`$HOME/.config/kak/digraphs`.

Second, put the `digraphs.kak` plugin file somewhere in your autoload directory tree:

`$HOME/.config/kak/autoload/...`

You may also want to add the following line to your `kakrc`:

`digraphs-enable-on <key1> <key2>`

to have symbol search and digraph conversion enabled by default. (Of course, `<key1>` and `<key2>`
should be replaced by the actual keys you want to use as shortcuts.)

## Adding custom digraphs

Because the `digraphs.dat` datafile is plain text, you can easily add custom digraphs to it.

Each non-empty line of the datafile has four fields. The first field is the Unicode hex value. The
second field is the symbol. The third field is the symbol description (including an optional
category in brackets). The fourth field is the digraph. For example:

23E3	⏣	[TECH] BENZENE RING WITH CIRCLE	b@

Regular spaces are allowed in symbol description, but the fields **are tab-separated**.

## Related work

[digraph](https://github.com/vxid/digraph)

[easydigraph.vim](https://github.com/gu-fan/easydigraph.vim)

[unicode.vim](https://github.com/chrisbra/unicode.vim)

## License

MIT

