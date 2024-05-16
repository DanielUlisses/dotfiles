if status is-interactive
    # Commands to run in interactive sessions can go here
end
set -U fish_user_paths ~/.tmuxifier/bin $fish_user_paths
set fish_greeting
starship init fish | source

