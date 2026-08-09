#!/usr/bin/env zsh
# recent-dirs.zsh — track visited directories and pick them from an inline list.
#
# Behaviour
#   • Every directory change is recorded (via zsh's chpwd hook).
#   • On an EMPTY prompt: press Tab to open a list of recent dirs drawn inline,
#     directly below the prompt. Tab / Down cycles the highlight forward,
#     Shift-Tab / Up cycles back, typing filters, Enter cds there, Esc cancels.
#   • On a NON-empty prompt: Tab behaves as normal completion.
#   • `rd` opens the same picker as a normal command.
#
# The list is rendered through ZLE's POSTDISPLAY rather than an fzf overlay, so
# it appears below the prompt without repainting the screen — whatever is above
# (fastfetch, previous output) stays put, and the list vanishes on pick/cancel.
#
# Source this from ~/.zshrc (after the completion / plugin setup).

RECENT_DIRS_FILE="${RECENT_DIRS_FILE:-$HOME/.cache/zsh_recent_dirs}"
RECENT_DIRS_MAX="${RECENT_DIRS_MAX:-50}"
RECENT_DIRS_VISIBLE="${RECENT_DIRS_VISIBLE:-10}"
RECENT_DIRS_HL="${RECENT_DIRS_HL:-standout}"
RECENT_DIRS_DIM="${RECENT_DIRS_DIM:-fg=8}"

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

# --- picker state ---------------------------------------------------------
# Kept in globals so the ZLE widget and the `rd` command share one implementation.
typeset -ga _rd_cands _rd_view _rd_out
typeset -g  _rd_query _rd_key
typeset -gi _rd_sel _rd_scroll _rd_selline

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
_rd_filter() {
  _rd_view=()
  local q=${(L)1} c
  for c in "$_rd_cands[@]"; do
    [[ -z $q || ${(L)c} == *$q* ]] && _rd_view+=("$c")
  done
}

# Truncate from the left, keeping the tail — for paths, the leaf dir matters most.
_rd_fit() {
  local s=$1
  local -i max=$2
  (( max < 8 )) && max=8
  if (( $#s > max )); then
    print -r -- "…${s[$(( -max + 1 )),-1]}"
  else
    print -r -- "$s"
  fi
}

# Truncate from the right — for the header/footer, where the start matters.
_rd_fit_r() {
  local s=$1
  local -i max=$2
  (( max < 8 )) && max=8
  if (( $#s > max )); then
    print -r -- "${s[1,$(( max - 1 ))]}…"
  else
    print -r -- "$s"
  fi
}

# Render the current state into _rd_out, recording which line is selected.
# Line 1 and the final line are the header/footer and get the dim style.
_rd_lines() {
  local -i n=$#_rd_view
  local -i w=${COLUMNS:-80}
  local -i vis=$RECENT_DIRS_VISIBLE
  (( vis > n )) && vis=n

  # Clamp the scroll window so the selection stays visible.
  (( _rd_sel < 1 )) && _rd_sel=1
  (( _rd_sel > n )) && _rd_sel=n
  (( _rd_sel < _rd_scroll + 1 ))   && _rd_scroll=$(( _rd_sel - 1 ))
  (( _rd_sel > _rd_scroll + vis )) && _rd_scroll=$(( _rd_sel - vis ))
  (( _rd_scroll > n - vis ))       && _rd_scroll=$(( n - vis ))
  (( _rd_scroll < 0 ))             && _rd_scroll=0

  _rd_out=()
  _rd_selline=0
  _rd_out+=("$(_rd_fit_r 'recent dirs · tab next · shift-tab prev · enter cd · esc cancel' $(( w - 1 )))")

  local -i i
  for (( i = _rd_scroll + 1; i <= _rd_scroll + vis; i++ )); do
    local disp=${_rd_view[i]/#$HOME/\~}
    local marker='  '
    (( i == _rd_sel )) && marker='› '
    local line="${marker}$(_rd_fit "$disp" $(( w - 3 )))"
    if (( i == _rd_sel )); then
      line=${(r:$(( w - 1 )):)line}     # pad so the highlight reads as a full bar
      _rd_selline=$(( $#_rd_out + 1 ))
    fi
    _rd_out+=("$line")
  done

  local footer
  if (( n == 0 )); then
    footer='no matches'
  else
    footer="${_rd_sel}/${n}"
    (( n > vis )) && footer+=" (showing $(( _rd_scroll + 1 ))-$(( _rd_scroll + vis )))"
  fi
  [[ -n $_rd_query ]] && footer+="   filter: $_rd_query"
  _rd_out+=("$(_rd_fit_r "$footer" $(( w - 1 )))")
}

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
    $'\C-n')          _rd_key=down ;;
    $'\C-p')          _rd_key=up ;;
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
          A) _rd_key=up ;;
          B) _rd_key=down ;;
          Z) _rd_key=shift-tab ;;
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
    tab|down)
      (( n )) && (( _rd_sel = _rd_sel % n + 1 )) ;;
    shift-tab|up)
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

# --- ZLE widget: inline list below the prompt ------------------------------
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

  local saved_post=$POSTDISPLAY
  local -a saved_hl=("$region_highlight[@]")

  _rd_query='' _rd_sel=1 _rd_scroll=0
  _rd_filter ''

  local dir=''
  while true; do
    _rd_lines
    # (pj:\n:) — the p flag is required, or the lines join on a literal "\n".
    POSTDISPLAY=$'\n'${(pj:\n:)_rd_out}

    # Offsets past $#BUFFER continue into POSTDISPLAY, so plain (non-P) ranges work.
    local -a hl=()
    local -i base=$#BUFFER off=1 idx=1 start end
    local line
    for line in "$_rd_out[@]"; do
      start=$(( base + off ))
      end=$(( start + $#line ))
      if (( idx == _rd_selline )); then
        hl+=("$start $end $RECENT_DIRS_HL")
      elif (( idx == 1 || idx == $#_rd_out )); then
        hl+=("$start $end $RECENT_DIRS_DIM")
      fi
      (( off += $#line + 1 ))
      (( idx++ ))
    done
    region_highlight=("$hl[@]")

    zle -R
    _rd_read_key || break
    _rd_handle_key
    case $? in
      1) dir=$_rd_view[_rd_sel]; break ;;
      2) break ;;
    esac
  done

  POSTDISPLAY=$saved_post
  region_highlight=("$saved_hl[@]")

  if [[ -n $dir ]]; then
    BUFFER="cd ${(q-)dir}"
    CURSOR=$#BUFFER
    zle accept-line
  else
    zle redisplay
  fi
}
zle -N _rd_widget
bindkey '^I' _rd_widget       # Tab

# --- `rd`: the same picker as a plain command ------------------------------
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

  local dir='' line
  local -i drawn=0 i
  {
    while true; do
      _rd_lines
      (( drawn )) && printf '\e[%dA' $drawn >/dev/tty
      for (( i = 1; i <= $#_rd_out; i++ )); do
        line=$_rd_out[i]
        if (( i == _rd_selline )); then
          printf '\e[2K\e[7m%s\e[0m\n' "$line" >/dev/tty
        elif (( i == 1 || i == $#_rd_out )); then
          printf '\e[2K\e[2m%s\e[0m\n' "$line" >/dev/tty
        else
          printf '\e[2K%s\n' "$line" >/dev/tty
        fi
      done
      drawn=$#_rd_out

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
