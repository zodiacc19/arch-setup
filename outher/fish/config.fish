if status is-interactive

    ## Variáveis ##
    set -g fish_greeting
    set -g fish_prompt_pwd_dir_length 0

    ## Inicializações ##

    # Starship
    # starship init fish | source

    # Zoxide
    zoxide init fish | source

    ## Aliases ##

    # Zoxide
    alias cd="z"

    # Eza
    alias ls="eza --icons"
    alias ll="eza --icons -lh"
    alias la="eza --icons -a"
    alias lla="eza --icons -lah"
    alias lt="eza --icons --tree"

    # SEToolkit
    alias setoolkit="sudo setoolkit"

    # Metasploit
    alias msf="msfdb start && msfconsole"

    # Limpar histórico
    alias hc="history clear"

end

# fish_add_path /home/vinicius/.spicetify
