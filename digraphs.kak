# Insert Unicode symbols based on their digraph or description.
# Author: Francois Tonneau

# This script assumes that the digraphs.dat datafile is installed in a
# 'digraphs' subdirectory of ${kak_config}.

# VARIABLES

declare-option -hidden str digraphs_path digraphs
declare-option -hidden str digraphs_file digraphs.dat

declare-option -hidden str digraphs_stretch_more nop

declare-option -hidden str digraphs_postfix <space>
declare-option -hidden str digraphs_symbol  ''

# PUBLIC COMMANDS

define-command \
-docstring \
'digraphs-enable-on <key1> <key2>: search with <key1>, convert with <key2>' \
-params 2 \
digraphs-enable-on %{
    try %{
        remove-hooks global digraphs
    }
    hook -group digraphs global InsertKey %arg(1) digraphs-search-symbol
    hook -group digraphs global InsertKey %arg(2) digraphs-check-typing
}

define-command \
-docstring \
'digraphs-use-postfix <key(s)>: insert <key(s)> after digraph insertion' \
-params 1 \
digraphs-use-postfix %{
    set-option global digraphs_postfix %arg(1)
}

define-command \
-docstring \
'digraphs-include-word <yes|no>: whether to replace the last typed word or only
the last two characters' \
-params 1 \
digraphs-include-word %{
    evaluate-commands %sh{
        case $1 in
            yes|Yes|true)
                printf %s\\n 'set-option global digraphs_stretch_more nop'
                ;;
            *)
                printf %s\\n 'set-option global digraphs_stretch_more nay'
                ;;
        esac
    }
}

define-command \
-docstring \
'Disable insertion of special symbols' \
digraphs-disable %{
    remove-hooks global digraphs
}

define-command \
-docstring \
'Sweep selection, converting digraphs to symbols' \
digraphs-sweep-selection %{
    try %{
        digraphs-test-if-single-selection
        execute-keys -draft <a-k> \S \S <ret>
        digraphs-convert-selection
    }
}

alias global dig digraphs-sweep-selection

# IMPLEMENTATION

define-command \
-hidden \
digraphs-search-symbol %{
    prompt 'search symbol:' %{
        evaluate-commands %sh{
            if [ ! "$kak_text" ]; then
                exit
            fi
            #
            table=$kak_config'/'$kak_opt_digraphs_path'/'$kak_opt_digraphs_file
            digraph_length=2
            digraph_col=4
            if [ ${#kak_text} -eq $digraph_length ]; then
                results=
                info=$(
                    cut -f $digraph_col "$table" | grep -F -n -- "$kak_text"
                )
                if [ "$info" ]; then
                    line=${info%%:*} results=$(sed -n ${line}p "$table")
                fi
            else
                up=$(printf %s "$kak_text" | tr 'a-z' 'A-Z')
                query=$(printf %s "$up" | sed -e 's/ /.*/g' -e 's/_/ /g')
                results=$(grep -E -- "$query" "$table")
            fi
            #
            if [ ! "$results" ]; then
                printf %s\\n 'echo no symbol found'
                exit
            fi
            #
            # Display first result before building menu. Awk fields: $1 = hex
            # value, $2 = symbol, $3 = description, $4 = digraph.
            printf %s\\n "$results" | head -n 1 | awk '
                BEGIN { FS = "\t" } { printf "echo -- %{U+%s %s}\n", $1, $4 }
            '
            printf %s\\n "$results" | awk '
                BEGIN {
                    FS = "\t"
                    printf "menu -select-cmds -- "
                }
                {
                    printf "%{%s %s} ", $2, $3
                    printf "%{digraphs-accept-symbol %{%s}} ", $2
                    printf "%{echo -- %{U+%s %s}} ", $1, $4
                }
            '
        }
    }
}

define-command \
-hidden \
-params 1 \
digraphs-accept-symbol %{
    evaluate-commands %sh{
        symbol=$1
        #
        # The symbol datafile uses '(!' and ')!' as brace surrogates to avoid
        # breaking balanced strings.
        case $symbol in
            '(!') symbol='{' ;;
            '!)') symbol='}' ;;
        esac
        printf %s\\n "set-option buffer digraphs_symbol $symbol"
        #
        # -with-hooks: permit line wrapping and other hooks.
        printf %s    "execute-keys -with-hooks $symbol"
        printf %s\\n "$kak_opt_digraphs_postfix"
    }
}

define-command \
-hidden \
digraphs-check-typing %{
    try %{
        #
        # Convert characters only if cursor could be on the right of a digraph.
        evaluate-commands %sh{
            digraph_space=2
            if [ $kak_cursor_char_column -le $digraph_space ]; then
                printf %s\\n fail
            fi
        }
        execute-keys -draft h H <a-k> \S \S <ret>
        digraphs-convert-typed-characters
    } \
    catch %{
        digraphs-insert-previous-symbol
    }
}

define-command \
-hidden \
digraphs-convert-typed-characters %{
    evaluate-commands -draft %{
        #
        # Select up to a word or up to a character pair, as determined by the
        # option. Then take action depending on actual content width (> 2 ?).
        try %{
            eval %opt(digraphs_stretch_more)
            execute-keys h <a-b>
        } \
        catch %{
            execute-keys h H
        }
        try %{
            execute-keys <a-k> \A . .{2,} \z <ret>
            digraphs-convert-selection
            execute-keys i %opt(digraphs_postfix) <esc>
        } \
        catch %{
            digraphs-fetch-symbol
        }
    }
}

define-command \
-hidden \
digraphs-convert-selection %{
    #
    # Clean extra line feeds and convert tabs to spaces for better results.
    execute-keys 1 s \A \n* (.*?) \n* \z <ret> @
    evaluate-commands %sh{
        sel=$kak_selection
        table=$kak_config'/'$kak_opt_digraphs_path'/'$kak_opt_digraphs_file
        ending=$(< "$table" wc -l)
        #
        # The symbol table is sent to awk as a prologue to the real work.
        replacement=$(
            { cat "$table"; printf %s "$sel"; } | awk -v table_end=$ending '
                BEGIN {
                    FS = "\t"
                }
                #
                # Read the table to build a digraph -> symbol array.
                (NR <= table_end && $0 !~ /^$/) {
                    digraph[$4] = $2
                }
                #
                # Scan selection lines left to right, replacing each meaningful
                # character pair by the corresponding symbol.
                NR > table_end {
                    scan = ""
                    pos = 1
                    while (pos < length($0)) {
                        char = substr($0, pos, 1)
                        pair = substr($0, pos, 2)
                        symbol = digraph[pair]
                        if (symbol != "") {
                            if (symbol == "(!") symbol = "{"
                            if (symbol == "!)") symbol = "}"
                            scan = scan symbol
                            pos += 2
                        } \
                        else {
                            scan = scan char
                            pos += 1
                        }
                    }
                    #
                    # Finish the last character if not consumed already.
                    if (pos == length($0)) {
                        char = substr($0, pos, 1)
                        scan = scan char
                    }
                    print scan
                }
            '
        )
        #
        # Adapt the string (which may contain user text) to Kakoune.
        replacement=$(printf %s "$replacement" \
            | sed -e "s,','',g" -e '$!s,$,<ret>,' | tr -d '\n'
        )
        printf %s\\n "execute-keys c '$replacement' <esc>"
    }
}

define-command \
-hidden \
digraphs-fetch-symbol %{
    evaluate-commands %sh{
        table=$kak_config'/'$kak_opt_digraphs_path'/'$kak_opt_digraphs_file
        symbol_col=2
        digraph_col=4
        info=$(cut -f $digraph_col "$table" | grep -F -n -- "$kak_selection")
        if [ "$info" ]; then
            line=${info%%:*}
            symbol=$(sed -n ${line}p "$table" | cut -f $symbol_col)
        else
            exit
        fi
        case $symbol in
            '(!') symbol='{' ;;
            '!)') symbol='}' ;;
        esac
        postfix=$kak_opt_digraphs_postfix
        printf %s\\n "set-option buffer digraphs_symbol $symbol"
        printf %s\\n "execute-keys c $symbol $postfix <esc>"
    }
}

define-command \
-hidden \
digraphs-insert-previous-symbol %{
    evaluate-commands %sh{
        symbol=$kak_opt_digraphs_symbol
        if [ "$symbol" ]; then
            printf %s    "execute-keys -with-hooks $symbol"
            printf %s\\n "$kak_opt_digraphs_postfix"
        fi
    }
}

define-command \
-hidden \
digraphs-test-if-single-selection %{
    evaluate-commands %sh{
        if expr "$kak_selections_length" : '.* .*' >/dev/null; then
            printf %s\\n 'echo -markup {Error}multiple selections not allowed'
            printf %s\\n fail
        fi
    }
}

