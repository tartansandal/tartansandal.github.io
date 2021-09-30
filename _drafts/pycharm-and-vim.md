---
title: PyCharm for VIM users
---

Docs at <https://www.jetbrains.com/help/pycharm/quick-start-guide.html>

May need to fix the webbrowser: Settings -> Tools -> Webbrowsers

Have to change my `firefox` command to `firefox-wayland`

Increase font size `Settings -> Apperance` and `Settings -> Editor -> Fonts`

Importing a new theme?

Distraction Free Mode

## Vim integration

First add [IdeaVim](https://github.com/JetBrains/ideavim) plugin

A lot of your favorite key mappings are already supported.
<https://github.com/JetBrains/ideavim/blob/master/src/com/maddyhome/idea/vim/package-info.java>

If you are new to PyCharm, you will want to internalise some fundamental key
mappings:

## Navigation

`Esc`             Goto Editor

`Shift-Shift`     Search Everywhere

`Ctrl-Alt-S`      Goto Settings
`Ctrl-Shift-A`    Find any action

`Ctrl-Tab`        Switcher
                  navigate windows/files/tools (default most recent)
                  repeatable

## Completion

PyCharm offers "as you type" completion suggestions, much like CoC, Deoplete and
YouCompleteMe vim plugins.

While in insert mode suggestions are displayed in a pop-up near your cursor.
Pycharms "best guess" is always selected at the top of the list.  Use `Ctrl-P`
and `Ctrl-N` keys (or `Up` and `Down` arrows) to navigate to your choice, and
`Tab` or `Enter` to select. `Tab` is particularly useful for selecting the first
choice.

If your are not editing but want to force a completion popup

`Ctrl-Space`        basic completion

The following is kinda handy

`Ctrl-Shift-Enter`  complete statement insert : ) newline as appropriate

usefull for appending a `:` at the end of a line and staring new indented block.

## Vim Key Bindings

All the usual code navigation keys work (`[[`, `]]`, `[]`, `][`, `{`, `}`), but
some have been enhanced.
Window scrolling and text motions.

Note Vim Keys are compositional actions that can be applied to objects and
motions.

  | Vim Key | IDE Key    | IDE Command                        |
  | ------- | -------    | -----------                        |
  | K       | Ctrl-Q     | Quick Documentation                |
  | gq      | Ctrl-Alt-L | Reformat Code                      |
  | =       | Ctrl-Alt-I | Automatic Indentation              |
  | Ctrl-]  | Ctrl-B     | Goto declaration / Show References |
  | Ctrl-J  | Ctrl-J     | Live Template                      |

Note `Ctrl-J` is the default mapping for template lookup in the Vim Ultisnips
plugin.

## Unmapped but Useful

Two of the most commonly used commands:

| `Ctrl-Alt-Shift-N` | Search for (selected) symbols                           |
| `Ctrl-Alt-Shift-T` | Refactor This                                           |
|                    |                                                         |
| `Alt-Enter`        | Show context/intention actions (light bulb)             |
| `Alt-Insert`       | Generate Code (like Copyright blocks)                   |
| `Alt-Q`            | Context Info (show current method or class declaration) |
| `Ctrl-Alt-O`       | Optimize Imports                                        |

## Resolving Key Conflicts

Many IDE key mappings conflict with those from IdeaVim. We can review and
resolve these conflicts under `Under Settings -> Editor -> Vim Emulation`

Here is a table decribing these conflicts and potential resolution:
The middle column has the conflicting "IDE Key". To the left of that we have the
"IDE Command" normally mapped to this key, and to the right we have the "Vim
Command" normally mapped to this key. The far left column has the "Vim Key" that
is performs a function equivalent to the "IDE Command"

  | Vim Key | IDE Command          | IDE Key | IdeaVim Command       | Handler
  | ------- | -----------          | ------- | ---------------       | -------
  | :%      | Select All           | Ctrl-A  | Increment number      | Vim
  | Ctrl-]  | Source Editor        | Ctrl-B  | Scroll pages back     | Vim
  | y       | Copy                 | Ctrl-C  | Interupt/Exit insert  | Vim
  | :diff   | Compare Files        | Ctrl-D  | Scrolling/Shifting    | Vim
  |         | Toggle Changed       | Ctrl-E  | Scrolling/Inserting   | Vim
  | /       | Find                 | Ctrl-F  | Scrolling             | Vim
  | G and | | Line/Column          | Ctrl-G  | File info display     | Vim
  |         | Base on This Class   | Ctrl-H  | Left/Backspace        | Vim
  |         | Implement members    | Ctrl-I  | Jump to next pos.     | Vim
  |         | Insert Live Template | Ctrl-J  |                       | IDE
  |         | Commit               | Ctrl-K  | Enter digraph         | Vim
  | n       | Find Next            | Ctrl-L  |                       | IDE
  |         | Commit Message Hist. | Ctrl-M  | Motion down/Insert    | Vim
  | :!mkdir | New Folder           | Ctrl-N  | Next match            | Vim
  |         | Override Methods     | Ctrl-O  | Jump to prev pos.     | Vim
  |         | Parameter Info       | Ctrl-P  | Previous match        | Vim
  | K       | Quick Documentation  | Ctrl-Q  |                       | IDE
  | :s      | Replace              | Ctrl-R  | Redo                  | Vim
  | :wa     | Save All             | Ctrl-S  |                       | IDE
  |         | Update Project       | Ctrl-T  | Jump to older tag     | Vim
  |         | Super Method         | Ctrl-U  | Scroll window up      | Vim
  | p       | Paste                | Ctrl-V  | Visual Block Mode     | Vim
  |         | Extend Selection     | Ctrl-W  | Window command prefix | Vim
  | x       | Cut                  | Ctrl-X  | Decrement number      | Vim
  | d       | Delete Selected Rows | Ctrl-Y  | Scroll window up      | Vim
  | [[      | Move to Block Start  | Ctrl-[  | Exit Insert Mode      | Vim
  | ]]      | Move to Block End    | Ctrl-]  | Goto Declaration      | Vim

For most of these conflicts, the resolution is clear:

* There is an existing Vim mapping that performs an command equivalent command.
* The Vim mapping is for the key is useful/important.

So we use the "Vim" handler

IdeaVim has no equivalent to the "Insert Live Template" command that is bound to
`Ctrl-J` but this has no binding in IdeaVim (although Vim would normally bind
this) It seems reasonable to let the IDE handle this important function.

We have some keys that are mapped to useful IDE commands, but which have also
have important IdeaVim mappings. We need to find different IDE Keys for these
commands.

  | Vim Key | IDE Command          | IDE Key | IdeaVim Command       | Handler
  | ------- | -----------          | ------- | -----------           | -------
  |         | Implement members    | Ctrl-I  | Jump to next pos.     | Vim
  |         | Override Methods     | Ctrl-O  | Jump to prev pos.     | Vim
  |         | Paramerer Info       | Ctrl-P  | Previous match        | Vim
  |         | Super Method         | Ctrl-U  | Scroll window up      | Vim
  |         | Update Project       | Ctrl-T  | Jump to older tag     | Vim

Converesly we have some keys with no corresponding "IdeaVim Command", but the
"IDE Command" has and equivalent "Vim Key". These keys are free for us to use
elsewhere.

  | Vim Key | IDE Command          | IDE Key | IdeaVim Command       | Handler
  | ------- | -----------          | ------- | -----------           | -------
  | n       | Find Next            | Ctrl-L  |                       | IDE
  | K       | Quick Documentation  | Ctrl-Q  |                       | IDE
  | :wa     | Save All             | Ctrl-S  |                       | IDE


To resolve this, I propose the following IDE re-mappings under `Settings ->
KeyMap`:

  | IDE Key      | IDE Command       | Location
  | -------      | -----------       | --------
  | Ctrl-Q       | Parameter Info    | Main Menu -> View -> Apperrance
  | Ctrl-Shift-Q | Type Info         | Main Menu -> View -> Apperrance
  | Ctrl-S       | Super Method      | Main Menu -> Navigate
  | Ctrl-L       | Update Project    | Main Menu -> VCS
  | Alt-I        | Implement members | Main Menu -> Code
  | Alt-O        | Override Methods  | Main Menu -> Code
  | Alt-K        | Commit            | Main Menu -> VCS

`Alt-\`           VCS operations  (conflicts with Gnome)

## Popup warnings

Disable notification popups for when ideavim key mappings clash with IDE

Settings -> Apperance & Behaviour -> Notifications

Set `ideavim` to `no popup` leave the logging checked.

## Configuration file

And the following `~/.ideavimrc`

~~~viml
" emulate vim-suround
set suround

" emulate vim-commentary
set commentary

" use relative line numbers
set relativenumber

" display the current mode in the status line
set showmode

" highlight increamental searches
set hlsearch
set incsearch

" quick command to clear search highlighting
map <silent> <leader><space> :nohlsearch<cr>

" use Idea's intelligent join function
set ideajoin
~~~

With seting commentary,
The `gc` action on motions and selections toggles the commenting of the region

Maybe more mappings to make this behave more vim like.
