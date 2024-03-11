{ user, ... }:

let
  home           = builtins.getEnv "HOME";
  # xdg_configHome = "${home}/.config";
  # xdg_dataHome   = "${home}/.local/share";
  # xdg_stateHome  = "${home}/.local/state"; 
	hx_confDir = "${home}/.config/helix";
in
{
	"${hx_confDir}/config.toml" = {
		text = ''
			theme = 'kanagawa'

			[editor]
			true-color = true
			line-number = "relative"
			lsp.display-inlay-hints = true
			soft-wrap.enable = true
		'';
	};
	
  # "${xdg_configHome}/rofi/styles.rasi".text = builtins.readFile ./config/rofi/styles.rasi;

  # "${xdg_configHome}/rofi/bin/launcher.sh" = {
  #   executable = true;
  #   text = ''
  #     #!/bin/sh

  #     rofi -no-config -no-lazy-grab -show drun -modi drun -theme ~/.config/rofi/launcher.rasi
  #   '';
  # };
}
