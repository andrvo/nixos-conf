{ user, ... }:

let
  home           = builtins.getEnv "HOME";
	# hx_confDir = "${home}/.config/helix";
	zsh_confDir = "${home}/.config/zsh";
in
{
	# "${hx_confDir}/config.toml" = {
	# 	text = ''
	# 		theme = 'kanagawa'

	# 		[editor]
	# 		true-color = true
	# 		line-number = "relative"
	# 		lsp.display-inlay-hints = true
	# 		soft-wrap.enable = true
	# 	'';
	# };
	
	"${zsh_confDir}/.zprofile" = {
		executable = false;
		text = ''
			if [ "X$TMUX" = "X" ];
			then
	        test $SSH_AUTH_SOCK && ln -sf "$SSH_AUTH_SOCK" "/tmp/ssh-agent-$USER-tmux"
			else
	        export SSH_AUTH_SOCK="/tmp/ssh-agent-$USER-tmux"
			fi
		'';
	};

}
