#!/usr/bin/env zsh
# recent-dirs.zsh — track visited directories and pick them from a horizontal strip.
#
# Behaviour
#   • Every directory change is recorded (via zsh's chpwd hook).
#   • A one-line, coloured strip of recent directory names sits directly above
#     the prompt, so it is there the moment a terminal opens.
#   • On an EMPTY prompt: press Tab to cycle a highlight through that same
#     strip — Tab / Right forward, Shift-Tab / Left back, typing filters,
#     Enter cds there, Esc cancels. Nothing is drawn below the prompt; the
#     strip you are already looking at is the thing that moves.
#   • On a NON-empty prompt: Tab behaves as normal completion.
#   • `rd` opens the same picker as a standalone command.
#
# The strip is part of PS1 rather than printed output, which is what lets ZLE
# repaint it in place via `zle reset-prompt`. That is the whole trick: printed
# output is frozen scrollback and would have to be duplicated below the prompt
# to animate it.
#
# Source this from ~/.zshrc AFTER the prompt (starship) init, so this file's
# precmd hook runs last and can wrap whatever PS1 the prompt just built.

RECENT_DIRS_FILE="${RECENT_DIRS_FILE:-$HOME/.cache/zsh_recent_dirs}"
RECENT_DIRS_MAX="${RECENT_DIRS_MAX:-50}"
RECENT_DIRS_SEP="${RECENT_DIRS_SEP:- · }"

# Entries cycle through these colours — the module output colours from
# ~/.config/fastfetch/config-dark.jsonc, so the strip reads as the same family
# as the greeting printed directly above it. These are pastels chosen to sit on
# the dark background; the terminal's own ANSI ramp is far too muted here and
# reads as low contrast.
typeset -ga RECENT_DIRS_COLORS
(( $#RECENT_DIRS_COLORS )) || RECENT_DIRS_COLORS=(
  '#9EC1FF'   # fastfetch keys      — pastel blue
  '#A8D5BA'   # os / packages       — sage
  '#F2B5D4'   # title / memory      — pink
  '#F3E7B3'   # shell               — sand
  '#CBB6FF'   # terminal            — lavender
  '#F4C095'   # uptime              — apricot
)
# Separators and the '‹ ›' overflow markers. fastfetch's own '@' colour: present
# enough to read, quiet enough to stay behind the names.
RECENT_DIRS_DIM_COLOR="${RECENT_DIRS_DIM_COLOR:-#9A9287}"

# Precompute the SGR bodies once — hex is what the config speaks, but the
# terminal wants 38;2;r;g;b and this runs on every keystroke while cycling.
typeset -ga _rd_sgr
typeset -g  _rd_dim_sgr
_rd_hex_sgr() {
  local h=${1#\#}
  print -rn -- "38;2;$(( 16#${h[1,2]} ));$(( 16#${h[3,4]} ));$(( 16#${h[5,6]} ))"
}
_rd_init_colors() {
  _rd_sgr=()
  local c
  for c in "$RECENT_DIRS_COLORS[@]"; do
    _rd_sgr+=("$(_rd_hex_sgr $c)")
  done
  _rd_dim_sgr=$(_rd_hex_sgr $RECENT_DIRS_DIM_COLOR)
}
_rd_init_colors

mkdir -p "${RECENT_DIRS_FILE:h}"

# --- tracking -------------------------------------------------------------
_recent_dirs_add() {
  local dir="$PWD"
  [[ "$dir" == "$HOME" ]] && return                 # skip home (matches old setup)
  local tmp="${RECENT_DIRS_FILE}.$$"
  {
    print -r -- "$dir"
    [[ -f "$RECENT_DIRS_FILE" ]] && grep -vxF -- "$dir" "$RECENT_DIRS_FILE"
  } 2>/dev/null | head -n "$RECENT_DIRS_MAX" > "$tmp" && mv "$tmp" "$RECENT_DIRS_FILE"
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _recent_dirs_add                 # fires on cd / pushd / popd / autocd
_recent_dirs_add                                    # record the starting directory

# --- state ----------------------------------------------------------------
typeset -ga _rd_cands _rd_view _rd_spans
typeset -g  _rd_query _rd_key _rd_line _rd_base_ps1
typeset -gi _rd_sel _rd_scroll _rd_hl_start _rd_hl_end _rd_active

# Existing dirs from history, excluding the current one, newest first.
_rd_candidates() {
  _rd_cands=()
  [[ -f "$RECENT_DIRS_FILE" ]] || return
  local line
  while IFS= read -r line; do
    [[ -d "$line" && "$line" != "$PWD" ]] && _rd_cands+=("$line")
  done < "$RECENT_DIRS_FILE"
}

# Narrow _rd_cands into _rd_view by a case-insensitive substring query.
# Matched against the leaf name only — that is what the strip actually shows,
# and matching the full path silently keeps entries whose parent happens to
# contain the query, which reads as the filter being broken.
_rd_filter() {
  _rd_view=()
  local q=${(L)1} c
  for c in "$_rd_cands[@]"; do
    [[ -z $q || ${(L)${c:t}} == *$q* ]] && _rd_view+=("$c")
  done
}

# --- laying out the strip -------------------------------------------------
# Lay _rd_view out as a single line of leaf names, widest window that fits.
#   $1 = columns available for the whole line
# Reads  : _rd_view, _rd_sel (0 = no highlight), _rd_scroll
# Writes : _rd_line, plus _rd_spans as "start:end:colour" triples giving each
#          visible entry's 0-based half-open character range within _rd_line,
#          and _rd_hl_start/_rd_hl_end marking the selected one (-1 for none).
_rd_build() {
  local -i w=$1
  local -i n=$#_rd_view
  local -i seplen=$#RECENT_DIRS_SEP
  # Reserve four columns for the '‹ ' / ' ›' overflow markers so adding them
  # later can never push the line — and with it the highlight — off the edge.
  local -i avail=$(( w - 4 ))
  (( avail < 4 )) && avail=4

  _rd_line='' _rd_hl_start=-1 _rd_hl_end=-1
  _rd_spans=()
  (( n == 0 )) && { _rd_line='(no matches)'; return }

  (( _rd_sel > 0 && _rd_sel < _rd_scroll + 1 )) && _rd_scroll=$(( _rd_sel - 1 ))
  (( _rd_scroll > n - 1 )) && _rd_scroll=$(( n - 1 ))
  (( _rd_scroll < 0 )) && _rd_scroll=0

  # Grow a window forward from _rd_scroll; if the selection falls outside it,
  # slide the window right and retry until it doesn't.
  local lbl
  local -i first last used need i
  while true; do
    first=$(( _rd_scroll + 1 ))
    used=0 last=0
    for (( i = first; i <= n; i++ )); do
      lbl=${_rd_view[i]:t}; [[ -z $lbl ]] && lbl=/
      need=$#lbl
      (( i > first )) && (( need += seplen ))
      (( used + need > avail )) && break
      (( used += need ))
      last=$i
    done
    (( last == 0 )) && last=$first                  # always show one, truncated below
    (( _rd_sel == 0 || _rd_sel <= last )) && break
    (( _rd_scroll++ ))
    if (( _rd_scroll >= n )); then _rd_scroll=$(( n - 1 )); break; fi
  done

  local out='' col
  local -i ncol=$#_rd_sgr
  (( first > 1 )) && out+='‹ '
  for (( i = first; i <= last; i++ )); do
    lbl=${_rd_view[i]:t}; [[ -z $lbl ]] && lbl=/
    (( $#lbl > avail )) && lbl="${lbl[1,$(( avail - 1 ))]}…"
    (( i > first )) && out+=$RECENT_DIRS_SEP
    # Keyed off the absolute index so an entry keeps its colour while you
    # cycle or the window scrolls.
    col=$_rd_sgr[$(( (i - 1) % ncol + 1 ))]
    _rd_spans+=("$#out:$(( $#out + $#lbl )):$col")
    if (( i == _rd_sel )); then
      _rd_hl_start=$#out
      _rd_hl_end=$(( $#out + $#lbl ))
    fi
    out+=$lbl
  done
  (( last < n )) && out+=' ›'

  # Belt and braces: never hand back a line wider than the terminal, and keep
  # every range inside whatever survives, or the highlight draws a stray bar.
  (( $#out > w )) && out="${out[1,$(( w - 1 ))]}…"
  _rd_line=$out
  if (( _rd_hl_start >= 0 )); then
    if (( _rd_hl_start >= $#_rd_line )); then
      _rd_hl_start=-1 _rd_hl_end=-1
    elif (( _rd_hl_end > $#_rd_line )); then
      _rd_hl_end=$#_rd_line
    fi
  fi
  local -a kept=()
  local sp rest
  local -i ss ee
  for sp in "$_rd_spans[@]"; do
    ss=${sp%%:*} rest=${sp#*:} ee=${rest%%:*}
    (( ss >= $#_rd_line )) && continue
    (( ee > $#_rd_line )) && ee=$#_rd_line
    kept+=("${ss}:${ee}:${rest#*:}")
  done
  _rd_spans=("$kept[@]")
}

# --- rendering ------------------------------------------------------------
# Colour _rd_line with SGR escapes: each entry in its own colour, separators
# and markers dim, the selection additionally in reverse video.
#   $1 = 'ps1' to wrap escapes in %{ %} and double literal '%' for prompt
#        expansion; anything else emits a plain string for direct printing.
_rd_paint() {
  local mode=$1 esc=$'\e' out='' sp rest txt o c_ c
  local -i pos=0 s e
  # In PS1 mode zero-width escapes must be fenced off or zsh miscounts the
  # prompt width and the cursor lands in the wrong column.
  if [[ $mode == ps1 ]]; then o='%{' c_='%}'; else o='' c_=''; fi
  _rd_esc() {   # $1 = SGR body, $2 = text
    local t=$2
    [[ $mode == ps1 ]] && t=${t//\%/%%}
    print -rn -- "${o}${esc}[${1}m${c_}${t}${o}${esc}[0m${c_}"
  }
  for sp in "$_rd_spans[@]"; do
    s=${sp%%:*} rest=${sp#*:} e=${rest%%:*} c=${rest#*:}
    (( s > pos )) && out+=$(_rd_esc "$_rd_dim_sgr" "${_rd_line[$(( pos + 1 )),$s]}")
    txt=${_rd_line[$(( s + 1 )),$e]}
    if (( _rd_hl_start == s )); then
      out+=$(_rd_esc "7;${c}" "$txt")
    else
      out+=$(_rd_esc "$c" "$txt")
    fi
    pos=$e
  done
  (( pos < $#_rd_line )) && out+=$(_rd_esc "$_rd_dim_sgr" "${_rd_line[$(( pos + 1 )),-1]}")
  # No spans at all (the '(no matches)' case) — paint the whole line dim.
  (( $#_rd_spans )) || out=$(_rd_esc "$_rd_dim_sgr" "$_rd_line")
  unfunction _rd_esc
  print -rn -- "$out"
}

# --- the strip as a prompt line -------------------------------------------
# Rebuild PS1 as "<strip>\n<the prompt starship built>". Called from precmd and
# again on every keystroke while the picker is open.
_rd_apply_ps1() {
  if (( $#_rd_view == 0 && _rd_active == 0 )); then
    PS1=$_rd_base_ps1
    return
  fi
  _rd_build $(( ${COLUMNS:-80} - 1 ))
  local strip
  strip=$(_rd_paint ps1)
  if (( _rd_active )) && [[ -n $_rd_query ]]; then
    strip+="%{"$'\e'"[${_rd_dim_sgr}m%}  /${_rd_query//\%/%%}%{"$'\e'"[0m%}"
  fi
  PS1="${strip}"$'\n'"${_rd_base_ps1}"
}

# Runs after the prompt's own precmd, so $PS1 here is the finished prompt.
_rd_precmd() {
  _rd_active=0 _rd_query='' _rd_sel=0 _rd_scroll=0
  _rd_candidates
  _rd_view=("$_rd_cands[@]")
  _rd_base_ps1=$PS1
  _rd_apply_ps1
}
add-zsh-hook precmd _rd_precmd

# --- key handling ---------------------------------------------------------
# Read one keypress into _rd_key as a normalised name. Returns 1 on EOF.
_rd_read_key() {
  _rd_key=ignore
  local k rest c seq
  read -k 1 -r k </dev/tty || return 1
  case $k in
    $'\t')            _rd_key=tab ;;
    $'\n'|$'\r')      _rd_key=enter ;;
    $'\C-?'|$'\C-h')  _rd_key=backspace ;;
    $'\C-c'|$'\C-g')  _rd_key=cancel ;;
    $'\C-n')          _rd_key=right ;;
    $'\C-p')          _rd_key=left ;;
    $'\e')
      # Escape alone cancels; escape followed by a sequence is an arrow / shift-tab.
      if ! read -k 1 -r -t 0.05 rest </dev/tty; then
        _rd_key=cancel
      elif [[ $rest == '[' || $rest == 'O' ]]; then
        seq=''
        while read -k 1 -r -t 0.05 c </dev/tty; do
          seq+=$c
          [[ $c == [A-Za-z~] ]] && break
        done
        case $seq in
          C|B) _rd_key=right ;;    # right / down both advance along the strip
          D|A) _rd_key=left ;;
          Z)   _rd_key=shift-tab ;;
        esac
      else
        _rd_key=cancel
      fi ;;
    *) [[ $k == [[:print:]] ]] && _rd_key="char:$k" ;;
  esac
  return 0
}

# Apply a keypress to the picker state.
# Returns 0 to keep looping, 1 to accept the selection, 2 to cancel.
_rd_handle_key() {
  local -i n=$#_rd_view
  case $_rd_key in
    tab|right)
      (( n )) && (( _rd_sel = _rd_sel % n + 1 )) ;;
    shift-tab|left)
      (( n )) && (( _rd_sel = (_rd_sel + n - 2) % n + 1 )) ;;
    enter)
      (( n )) && return 1
      return 2 ;;
    cancel)
      return 2 ;;
    backspace)
      _rd_query=${_rd_query%?}
      _rd_filter "$_rd_query"
      _rd_sel=1 _rd_scroll=0 ;;
    char:*)
      _rd_query+=${_rd_key#char:}
      _rd_filter "$_rd_query"
      _rd_sel=1 _rd_scroll=0 ;;
  esac
  return 0
}

# --- ZLE widget: cycle the strip in place ---------------------------------
_rd_widget() {
  if [[ -n $BUFFER ]]; then
    zle expand-or-complete
    return
  fi

  _rd_candidates
  if (( $#_rd_cands == 0 )); then
    zle -M "no recent directories yet"
    return
  fi

  _rd_active=1
  _rd_query='' _rd_sel=1 _rd_scroll=0
  _rd_filter ''

  local dir=''
  while true; do
    _rd_apply_ps1
    # reset-prompt only marks the prompt dirty; without the -R the repaint is
    # deferred until the widget returns and the highlight never visibly moves.
    zle reset-prompt
    zle -R
    _rd_read_key || break
    _rd_handle_key
    case $? in
      1) dir=$_rd_view[_rd_sel]; break ;;
      2) break ;;
    esac
  done

  # Back to the plain strip: full list, nothing highlighted, no filter.
  _rd_active=0 _rd_query='' _rd_sel=0 _rd_scroll=0
  _rd_view=("$_rd_cands[@]")
  _rd_apply_ps1
  zle reset-prompt

  if [[ -n $dir ]]; then
    BUFFER="cd ${(q-)dir}"
    CURSOR=$#BUFFER
    zle accept-line
  fi
}
zle -N _rd_widget
bindkey '^I' _rd_widget       # Tab

# --- `rd`: the same picker as a standalone command -------------------------
# Draws its own strip inline, since outside ZLE there is no prompt to repaint.
rd() {
  _rd_candidates
  if (( $#_rd_cands == 0 )); then
    print -u2 'rd: no recent directories yet'
    return 1
  fi

  local saved_stty
  saved_stty=$(stty -g </dev/tty) || return 1
  stty -echo </dev/tty

  _rd_query='' _rd_sel=1 _rd_scroll=0
  _rd_filter ''

  local dir='' painted
  local -i drawn=0
  {
    while true; do
      _rd_build $(( ${COLUMNS:-80} - 1 ))
      painted=$(_rd_paint)
      [[ -n $_rd_query ]] && painted+=$'\e'"[${_rd_dim_sgr}m  /${_rd_query}"$'\e'"[0m"
      (( drawn )) && printf '\e[%dA' $drawn >/dev/tty
      printf '\e[2K%s\n' "$painted" >/dev/tty
      drawn=1

      _rd_read_key || break
      _rd_handle_key
      case $? in
        1) dir=$_rd_view[_rd_sel]; break ;;
        2) break ;;
      esac
    done
  } always {
    (( drawn )) && printf '\e[%dA\e[J' $drawn >/dev/tty
    stty "$saved_stty" </dev/tty
  }

  [[ -n $dir ]] && cd "$dir"
}
