{ config, pkgs, lib, home, ... }:
let
  rga-fzf =
    ''
      rga-fzf() {
        RG_PREFIX="rga --files-with-matches"
        local file
        file="$(
          FZF_DEFAULT_COMMAND="$RG_PREFIX '$1'" \
            fzf --sort --preview="[[ ! -z {} ]] && rga --pretty --context 5 {q} {}" \
              --phony -q "$1" \
              --bind "change:reload:$RG_PREFIX {q}" \
              --preview-window="70%:wrap"
        )" &&
        echo "opening $file" &&
        xdg-open "$file"
      }
    '';
  vterm-print = 
    ''
      vterm_printf(){
        if [ -n "$TMUX" ] && ([ "''${TERM%%-*}" = "tmux" ] || [ "''${TERM%%-*}" = "screen" ] ); then
            # Tell tmux to pass the escape sequences through
            printf "\ePtmux;\e\e]%s\007\e\\" "$1"
        elif [ "''${TERM%%-*}" = "screen" ]; then
            # GNU screen (screen, screen-256color, screen-256color-bce)
            printf "\eP\e]%s\007\e\\" "$1"
        else
            printf "\e]%s\e\\" "$1"
        fi
      }
    '';
in {
  programs.zsh = {
    enable = true;
    #history.size = 10000;
    histSize = 10000;
    #enableSyntaxHighlighting = true;
    syntaxHighlighting = {
      enable = true;
    };
    enableCompletion = true;
    #initExtra = rga-fzf + "\n" + vterm-print;
    shellInit = rga-fzf + "\n" + vterm-print + "\n[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh";
    promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    #oh-my-zsh = {
    ohMyZsh = {
      enable = true;
      #plugins = [ "git-prompt" "fzf" ];
      plugins = [ "fzf" ];
      #theme = "agnoster";
    };
  };

  #home.file.".p10k.zsh".source = ./.p10k.zsh;
  
  # Is the following necessary?
  #home.packages = with pkgs; [
  #  zsh-completions
  #];
}
