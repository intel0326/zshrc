# Created by newuser for 5.4.2
#変更後はコンパイル
#$ zcompile ~/.zshrc
#設定
#$ source ~/.zshrc

#コマンド
#ls   ディレクトリとファイルの表示。
#     ディレクトリには「/」と「色」で表示
#     ファイルならば白文字
#
#la   隠しファイルも表示
#
#ディレクトリ名のみ　自動cd(cdなしでおｋ

# ショートカットキー
#C-r履歴から検索
#Esc-hman呼び出し
#Esc-q現在入力中の文字列を退避
#C-a先頭に移動
#C-a末尾に移動
#C-kカーソルから末尾まで削除
#C-wカーソルから行頭まで削除
#Esc-?コマンドのパスを表示
#C-lクリア
#M-up上のディレクトリ
#M-left戻る

################
### 基本設定 ###
################

# 他のターミナルとヒストリーを共有
setopt share_history

# ヒストリーに重複を表示しない
setopt histignorealldups

#履歴の保存先
HISTFILE=$HOME/.zsh-history
## メモリに展開する履歴の数
HISTSIZE=5000
## 保存する履歴の数
SAVEHIST=100000

#直前と同じコマンドをヒストリに追加しない
setopt hist_ignore_dups

#全履歴の一覧を出力する
function history-all { history -E 1 }

#移動履歴をプッシュ(cd -[Tab]
setopt auto_pushd

#移動履歴をキューではなくスタックで番号付け(最近居た場所が上になる)
setopt pushd_minus

#移動履歴の重複禁止
setopt PUSHD_IGNORE_DUPS

#command not foundの時にはインストール方法を提示
#source /etc/zsh_command_not_found

#Ctrl-dでログアウトしない
#setopt ignore_eof

################
### 環境変数 ###
################

#日本語utf-8
export LANG=ja_JP.UTF-8

#ライブラリパス
export LD_LIBRARY_PATH=$HOME/local/lib:$LD_LIBRARY_PATH

### 非端末プロセスなら終了 ###
[ $#PROMPT -eq 0 -o $#TERM -eq 0 ] &&; return

#################
### プロンプト ###
#################

#黒赤緑黄青紫水白
#local BLACK=$'%{\e[1;30m%}'
#local RED=$'%{\e[1;31m%}'
local GREEN=$'%{\e[1;32m%}'
#local YELLOW=$'%{\e[1;33m%}'
local BLUE=$'%{\e[1;34m%}'
#local PURPLE=$'%{\e[1;35m%}'
#local LIGHTBLUE=$'%{\e[1;36m%}'
#local WHITE=$'%{\e[1;37m%}'
local DEFAULT=$'%{\e[1;m%}'
#%nユーザー名
#%Mコンピュータ名
#%cカレントディレクトリ

#通常
#PROMPT=$DEFAULT"%n@%M:"$BLUE"%c"$DEFAULT"$ "
PROMPT=$DEFAULT"%n""["$GREEN"%T"$DEFAULT"]"":"$GREEN"%c"$DEFAULT"  "'`rprompt-git-current-branch`'$DEFAULT"
$ "
#複数行
PROMPT2="%_$ "
#確認
SPROMPT="%r is correct? [n,y,a,e]: "

#右プロンプト
# git ブランチ名を表示するメソッド
# こちらを引用：https://qiita.com/nishina555/items/f4f1ddc6ed7b0b296825
function rprompt-git-current-branch {
  local branch_name st branch_status

  if [ ! -e  ".git" ]; then
    # gitで管理されていないディレクトリは何も返さない
    return
  fi
  branch_name=`git rev-parse --abbrev-ref HEAD 2> /dev/null`
  st=`git status 2> /dev/null`
  if [[ -n `echo "$st" | grep "^nothing to"` ]]; then
    # 全てcommitされてクリーンな状態
    branch_status="%F{green}"
  elif [[ -n `echo "$st" | grep "^Untracked files"` ]]; then
    # gitに管理されていないファイルがある状態
    branch_status="%F{red}?"
  elif [[ -n `echo "$st" | grep "^Changes not staged for commit"` ]]; then
    # git addされていないファイルがある状態
    branch_status="%F{red}+"
  elif [[ -n `echo "$st" | grep "^Changes to be committed"` ]]; then
    # git commitされていないファイルがある状態
    branch_status="%F{yellow}!"
  elif [[ -n `echo "$st" | grep "^rebase in progress"` ]]; then
    # コンフリクトが起こった状態
    echo "%F{red}!(no branch)"
    return
  else
    # 上記以外の状態の場合は青色で表示させる
    branch_status="%F{blue}"
  fi
  # ブランチ名を色付きで表示する
  echo "${branch_status}[$branch_name]"
}
# プロンプトが表示されるたびにプロンプト文字列を評価、置換する
setopt prompt_subst

#%*時間(HH:MM:SS)
#%T 時間(HH:MM)
#RPROMPT='`rprompt-git-current-branch`'$DEFAULT

#複数行右プロンプト
#RPROMPT2

#タイトル
case "${TERM}" in
kterm*|xterm)
  precmd() {
    echo -ne "\033]0;`basename ${PWD}`[${PWD}]\007"
  }
  ;;
esac

#補完候補にもlsと同じ色付き表示
#eval `dircolors`
#zstyle ':completion:*:default' list-colors ${LS_COLORS}
zstyle ':completion:*:default' list-colors di=32
#kill の候補にも色付き表示
#zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([%0-9]#)*=0=01;31'

# コマンドの実行ごとに改行
function precmd() {
    # Print a newline before the prompt, unless it's the
    # first prompt in the process.
    if [ -z "$NEW_LINE_BEFORE_PROMPT" ]; then
        NEW_LINE_BEFORE_PROMPT=1
    elif [ "$NEW_LINE_BEFORE_PROMPT" -eq 1 ]; then
        echo ""
    fi
}

##################
### シェル変数 ###
##################

#補完関数用フォルダ
fpath=(~/.compfunc ${fpath})

############
### 関数 ###
############
# Pythonのスクリプトをカレントになければ~/bin/から探す
function myPyOpen() {
  if [ -f $1 ] ; then
    python $@
  else
    python ~/bin/$@
  fi
}

# 上方向へcdする
# hitode909様より拝借
function up() {
  to=$(perl -le '$p=$ENV{PWD}."/";$d="/".$ARGV[0]."/";$r=rindex($p,$d);$r>=0 && print substr($p, 0, $r+length($d))' $1)
  if [ "$to" = "" ]; then
    echo "no such file or directory: $1" 1>&2
    return 1
  fi
  cd $to
}
# 上へ移動する
# naoya様より拝借
function cdup() {
  cd ..
  zle reset-prompt
}
# 戻る
# ↑を少し変えただけ
function cdback() {
  cd -1
  zle reset-prompt
}

# nautilusでフォルダ開く
function naop() {
  if [ "$#" = "0" ]; then
    nautilus ./
  else
    for d in $@
    do
      echo "nautilus $d"
      nautilus $d
    done
  fi
}

###########
## alias ##
###########

#ls
#alias ls="ls -F --color=auto -v"#ディレクトリには/, 色つき, 番号順
alias la="ls -a"#隠しファイルも
alias ll="ls -lh"#詳細付き, ファイルサイズに接頭語
alias lla="ls -lha"#全部詳細
# Mac用のls
alias ls="ls -G"
export LSCOLORS=Cxfxcxdxbxegedabagacad

#cp
alias cp="cp -i"#上書きを確認

#sl
alias -g sl="echo you are an idiot!"

#打ち間違い対策
alias s="ls"
alias l="ls"

#grep
#alias grep="grep --color=auto"
#alias fgrep="fgrep --color=auto"
#alias egrep="egrep --color=auto"

#ln
#alias ln="ln -i -v"

#geditのデバッグを消去
#alias gedit="gedit $@ > /dev/null 2> /dev/null"

#拡張子で自動化
#alias -s c=gedit
#alias -s C=gedit
#alias -s cpp=gedit
#alias -s h=gedit
#alias -s html=google-chrome
#alias -s java=gedit
#alias -s pdf=google-chrome
#alias -s py=myPyOpen
#alias -s txt=gedit
#alias -s xhtml=google-chrome
#alias -s xml=gedit
#alias -s zip=zipinfo

#apache2
#alias apache2="sudo /etc/init.d/apache2"

#sudo用gedit
#alias suedit="sudo XMODIFIERS=@im=ibus GTK_IM_MODULE=xim gedit"

#stdoutをクリップボードへ
#alias -g toclip=" | xsel -bi"
#stdout+stderrをクリップボードへ
#alias -g toclipall=" 2>&1 | xsel -bi"
#stdoutをクリップボードとstdoutへ
#alias -g andclip=" | (cat 1>&2 | xsel -bi) 2>&1"
#stdout+stderrをクリップボードとstdoutへ
#alias -g andclipall=" 2>&1 | (cat 1>&2 | xsel -bi) 2>&1"

#gnome-open
#alias gopen="gnome-open"

#geditのデバッグがウザい
#alias gedit="gedit >/dev/null 2>/dev/null"

#clでclear
alias cl='clear'

#brew
alias br='brew'

#treeで日本語出力したい
alias tree='tree -N'

#vscodeをvsで開きたい
#alias vscode='code'
alias vscode='/Applications/Visual\ Studio\ Code\ -\ Exploration.app/Contents/Resources/app/bin/code'

####################
### キーバインド ###
####################

zle -N cdup
bindkey '^[[1;3A' cdup
zle -N cdback
bindkey '^[[1;3D' cdback

##################
### 補完ルール ###
##################

#コマンドラインオプションも補完
autoload -U compinit
compinit

#補完関数をできるだけ過剰に
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*' group-name ''

# 補完の時に大文字小文字を区別しない(但し、大文字を打った場合は小文字に変換しない)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

#矢印キー補完選択
zstyle ':completion:*:default' menu select

#先方予測・学習機能
#autoload predict-on
#predict-on

#自動cd(cdなしでおｋ
setopt auto_cd

#コマンド修正提示
#setopt correct #通常
setopt correct_all #ファイル名まで考慮

#補完候補が複数ある時に、一覧表示する
setopt auto_list

#タブキー連打で補完候補を順に表示
setopt auto_menu

# 補完候補が複数ある時、一覧表示 (auto_list) せず、すぐに最初の候補を補完する
setopt menu_complete

#補完候補一覧でファイルの種別を識別マーク表示(ls -F の記号)
setopt list_types

#'='以降でも補完できるようにする( --prefix=/usr 等の場合)
setopt magic_equal_subst

#補完される前にオリジナルのコマンドまで展開してチェックする
setopt complete_aliases

## カッコの対応などを自動的に補完
setopt auto_param_keys

#末尾の/を消去しない
setopt noautoremoveslash

#出力の文字列末尾に改行コードが無い場合でも表示
unsetopt promptcr


##############
## Mac用パス ##
##############

# パス
export PATH=/usr/bin:/usr/local/bin:/bin:/usr/sbin:/sbin

# homebrew用パス
export PATH=$PATH:/opt/homebrew/bin

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/$USER/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    echo "fatal: conda_setup"
    eval "$__conda_setup"
else
    if [ -f "/Users/$USER/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/$USER/opt/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/$USER/opt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# nodeのバージョンマネージャーのパス
eval "$(anyenv init -)"
