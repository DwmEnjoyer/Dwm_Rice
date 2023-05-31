if status is-interactive
	##FUNCTIONS
	function ls
		exa --icons $argv
	end
	##VARIABLES
	set fish_greeting
	##STARTUP COMMANDS
	fm6000 -n -c cyan -f ~/.config/pixelart/space_invader.txt
	##INIT STARSHIP PROMPT
	starship init fish | source
end
