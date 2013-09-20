export LANG=ja_JP.UTF-8

## 履歴の保存先
HISTFILE=$HOME/.zsh_history
## メモリに展開する履歴の数
HISTSIZE=100000
## 保存する履歴の数
SAVEHIST=100000

## 補完機能の強化
autoload -U compinit
compinit

## コアダンプサイズを制限
limit coredumpsize 102400
## 出力の文字列末尾に改行コードが無い場合でも表示
unsetopt promptcr
## Emacsライクキーバインド設定
bindkey -e

## 色を使う
setopt prompt_subst
## ビープを鳴らさない
setopt nobeep
## 内部コマンド jobs の出力をデフォルトで jobs -l にする
setopt long_list_jobs
## 補完候補一覧でファイルの種別をマーク表示
setopt list_types
## サスペンド中のプロセスと同じコマンド名を実行した場合はリジューム
setopt auto_resume
## 補完候補を一覧表示
setopt auto_list
## 直前と同じコマンドをヒストリに追加しない
setopt hist_ignore_dups
## cd 時に自動で push
setopt auto_pushd
## 同じディレクトリを pushd しない
setopt pushd_ignore_dups
## ファイル名で #, ~, ^ の 3 文字を正規表現として扱う
setopt extended_glob
## TAB で順に補完候補を切り替える
setopt auto_menu
## zsh の開始, 終了時刻をヒストリファイルに書き込む
setopt extended_history
## =command を command のパス名に展開する
setopt equals
## --prefix=/usr などの = 以降も補完
setopt magic_equal_subst
## ヒストリを呼び出してから実行する間に一旦編集
setopt hist_verify
## ファイル名の展開で辞書順ではなく数値的にソート
setopt numeric_glob_sort
## 出力時8ビットを通す
setopt print_eight_bit
## ヒストリを共有
setopt share_history
## 補完候補のカーソル選択を有効に
zstyle ':completion:*:default' menu select=1
## 大文字小文字を無視した補完
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
## ディレクトリ名だけで cd
setopt auto_cd
## カッコの対応などを自動的に補完
setopt auto_param_keys
## ディレクトリ名の補完で末尾の / を自動的に付加し、次の補完に備える
setopt auto_param_slash
## スペルチェック
setopt correct
## {a-c} を a b c に展開する機能を使えるようにする
setopt brace_ccl
## Ctrl+S/Ctrl+Q によるフロー制御を使わないようにする
setopt NO_flow_control
## コマンドラインの先頭がスペースで始まる場合ヒストリに追加しない
setopt hist_ignore_space
## コマンドラインでも # 以降をコメントと見なす
setopt interactive_comments
## ファイル名の展開でディレクトリにマッチした場合末尾に / を付加する
setopt mark_dirs
## history (fc -l) コマンドをヒストリリストから取り除く。
setopt hist_no_store
## 補完候補を詰めて表示
setopt list_packed
## 最後のスラッシュを自動的に削除しない
setopt noautoremoveslash

# 補完される前にオリジナルのコマンドまで展開してチェックする
setopt complete_aliases
# エイリアス
alias h='history -E -32'
RPROMPT='%/'

# Git
autoload -Uz add-zsh-hook
autoload -Uz colors
colors
autoload -Uz vcs_info

zstyle ':vcs_info:*' enable git svn hg bzr
zstyle ':vcs_info:*' formats '(%s)-[%b]'
zstyle ':vcs_info:*' actionformats '(%s)-[%b|%a]'
zstyle ':vcs_info:(svn|bzr):*' branchformat '%b:r%r'
zstyle ':vcs_info:bzr:*' use-simple true

autoload -Uz is-at-least
if is-at-least 4.3.10; then
  # この check-for-changes が今回の設定するところ
  zstyle ':vcs_info:git:*' check-for-changes true
  zstyle ':vcs_info:git:*' stagedstr "+"    # 適当な文字列に変更する
  zstyle ':vcs_info:git:*' unstagedstr "-"  # 適当の文字列に変更する
  zstyle ':vcs_info:git:*' formats '(%s)-[%b] %c%u'
  zstyle ':vcs_info:git:*' actionformats '(%s)-[%b|%a] %c%u'
fi

function _update_vcs_info_msg() {
    psvar=()
    LANG=en_US.UTF-8 vcs_info
    [[ -n "$vcs_info_msg_0_" ]] && psvar[1]="$vcs_info_msg_0_"
}
add-zsh-hook precmd _update_vcs_info_msg
RPROMPT="%1(v|%F{green}%1v%f|) [%d]"


#--------------
# コマンド実行後に右プロンプトを消す
#--------------
setopt transient_rprompt

# --------------------------------------
# screenの名前を自動でセットする
typeset -ga precmd_functions
typeset -ga preexec_functions
if [[ $ZSH_VERSION == (<5->|4.<4->|4.3.<10->)* ]]; then
  # set window title of screen
  function set_screen_title () { echo -ne "\ek$1\e\\" }
  function { # use current directory as a title
    function precmd_screen_window_title () {
      if [[ "$TERM" = 'screen-bce' ]]; then
        local dir
        dir=`pwd`
        dir=`print -nD "$dir"`
        if [[ ( -n "$vcs" ) && ( "$repos" != "$dir" ) ]]; then
          # name of repository and directory
          dir="${repos:t}:${dir:t}"
        else
          # name of directory
          dir=${dir:t}
        fi
      set_screen_title "$dir"
      fi
    }
  }
  typeset -A SCREEN_TITLE_CMD_ARG; SCREEN_TITLE_CMD_ARG=(ssh -1 su -1 man -1)
  typeset -A SCREEN_TITLE_CMD_IGNORE; SCREEN_TITLE_CMD_IGNORE=()
  function { # use command name as a title
    function set_cmd_screen_title () {
      local -a cmd; cmd=(${(z)1})
      while [[ "$cmd[1]" =~ "[^\\]=" ]]; do shift cmd; done
      if [[ "$cmd[1]" == "env" ]]; then shift cmd; fi
      if [[ -n "$SCREEN_TITLE_CMD_IGNORE[$cmd[1]]" ]]; then
        return
      elif [[ -n "$SCREEN_TITLE_CMD_ARG[$cmd[1]]" ]]; then
        # argument of command
        cmd[1]=$cmd[$SCREEN_TITLE_CMD_ARG[$cmd[1]]]
      fi
      set_screen_title "$cmd[1]:t"
    }
    function preexec_screen_window_title () {
      local -a cmd; cmd=(${(z)2}) # command in a single line
      if [[ "$TERM" = 'screen-bce' ]]; then
        case $cmd[1] in
          fg)
            if (( $#cmd == 1 )); then
              cmd=(builtin jobs -l %+)
            else
              cmd=(builtin jobs -l $cmd[2])
            fi
              ;;
            %*)
              cmd=(builtin jobs -l $cmd[1])
              ;;
            *)
              set_cmd_screen_title "$cmd"
              return
              ;;
        esac
          # resolve command in jobs
          local -A jt; jt=(${(kv)jobtexts})
          $cmd >>(read num rest
            cmd=(${(z)${(e):-\$jt$num}})
            set_cmd_screen_title "$cmd"
          ) 2>/dev/null
      fi
    }
  }
  function title() {
    if [[ -n "$SCREENTITLE" ]]; then
      if [[ -n "$1" ]]; then
        # set title explicitly
        export SCREENTITLE=explicit
        set_screen_title "$1"
      else
        # automatically set title
        export SCREENTITLE=auto
      fi
    fi
  }
  precmd_functions+=precmd_screen_window_title
  preexec_functions+=preexec_screen_window_title
fi
# --------------------

if [ "Linux" = `uname` ]
then #Linux
  eval `dircolors`
  export ZLS_COLORS=$LS_COLORS
  zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
  alias ls='ls --color=auto'
  alias ll='ls -laF --color | more'
  alias emacs='emacs -nw'
  GEM_PATH=/var/lib/gems/1.8/bin
  export PATH=~/bin:~/Dropbox/scripts:$GEM_PATH:$PATH
else #Linux以外(Macを想定)Darwinと比較するべきか
  alias ll='ls -laF | more'
  export PATH=/opt/local/bin:$HOME/bin:$PATH
fi

export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
export ANDROID_SDK_HOME=~/lib/android-sdks
export ANDROID_HOME=~/lib/android-sdks
export APPENGINE_JAVA_SDK=~/app/appengine-java-sdk
export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-amd64
export _JAVA_OPTIONS="-Dfile.encoding=UTF-8"
VTE_CJK_WIDTH=1
export VTE_CJK_WIDTH
export EDITOR=emacsclient

gbmec() {
  git status | awk '/both modified:/{print $4}' | xargs emacsclient
}

kill-emacsclient() {
  emacsclient -e '(kill-emacs)'
}

timestamp() {
  printf '%ld\n' $(expr `date +%s%N` / 1000000)
}

alias mvneclipse='mvn clean eclipse:clean eclipse:eclipse -DdownloadSources=true'

alias j=autojump
if [ -e /usr/share/autojump/autojump.zsh ]; then
    source /usr/share/autojump/autojump.zsh
fi

[[ -s $HOME/.pythonz/etc/bashrc ]] && source $HOME/.pythonz/etc/bashrc

if [ -f /usr/local/bin/virtualenvwrapper.sh ]; then
  export WORKON_HOME=$HOME/.virtualenvs
  source /usr/local/bin/virtualenvwrapper.sh
fi


alias python_dev_http_server="python -m SimpleHTTPServer 8080"
alias e=emacsclient
alias sudo='sudo env PATH=$PATH'

export LC_CTYPE=ja_JP.UTF-8
