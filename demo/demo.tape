# VHS documentation
#
# Output:
#   Output <path>.gif               Create a GIF output at the given <path>
#   Output <path>.mp4               Create an MP4 output at the given <path>
#   Output <path>.webm              Create a WebM output at the given <path>
#
# Require:
#   Require <string>                Ensure a program is on the $PATH to proceed
#
# Settings:
#   Set FontSize <number>           Set the font size of the terminal
#   Set FontFamily <string>         Set the font family of the terminal
#   Set Height <number>             Set the height of the terminal
#   Set Width <number>              Set the width of the terminal
#   Set LetterSpacing <float>       Set the font letter spacing (tracking)
#   Set LineHeight <float>          Set the font line height
#   Set LoopOffset <float>%         Set the starting frame offset for the GIF loop
#   Set Theme <json|string>         Set the theme of the terminal
#   Set Padding <number>            Set the padding of the terminal
#   Set Framerate <number>          Set the framerate of the recording
#   Set PlaybackSpeed <float>       Set the playback speed of the recording
#   Set MarginFill <file|#000000>   Set the file or color the margin will be filled with.
#   Set Margin <number>             Set the size of the margin. Has no effect if MarginFill isn't set.
#   Set BorderRadius <number>       Set terminal border radius, in pixels.
#   Set WindowBar <string>          Set window bar type. (one of: Rings, RingsRight, Colorful, ColorfulRight)
#   Set WindowBarSize <number>      Set window bar size, in pixels. Default is 40.
#   Set TypingSpeed <time>          Set the typing speed of the terminal. Default is 50ms.
#
# Sleep:
#   Sleep <time>                    Sleep for a set amount of <time> in seconds
#
# Type:
#   Type[@<time>] "<characters>"    Type <characters> into the terminal with a
#                                   <time> delay between each character
#
# Keys:
#   Escape[@<time>] [number]        Press the Escape key
#   Backspace[@<time>] [number]     Press the Backspace key
#   Delete[@<time>] [number]        Press the Delete key
#   Insert[@<time>] [number]        Press the Insert key
#   Down[@<time>] [number]          Press the Down key
#   Enter[@<time>] [number]         Press the Enter key
#   Space[@<time>] [number]         Press the Space key
#   Tab[@<time>] [number]           Press the Tab key
#   Left[@<time>] [number]          Press the Left Arrow key
#   Right[@<time>] [number]         Press the Right Arrow key
#   Up[@<time>] [number]            Press the Up Arrow key
#   Down[@<time>] [number]          Press the Down Arrow key
#   PageUp[@<time>] [number]        Press the Page Up key
#   PageDown[@<time>] [number]      Press the Page Down key
#   Ctrl+<key>                      Press the Control key + <key> (e.g. Ctrl+C)
#
# Display:
#   Hide                            Hide the subsequent commands from the output
#   Show                            Show the subsequent commands in the output

Output demo.mp4

Require echo
Require nvim

Set Shell "zsh"
Set Padding 0
Set Margin 0
Set FontFamily "DejaVuSansMono NF"
Set FontSize 15
Set Width 1200
Set Height 600

# Preparation commands
Hide
Type "nvim ./file.txt" Enter
Sleep 1s
Enter
Escape
Space
Type "snd" # hide all notifications from my LazyVim
Type "" Escape # close any notifications

Show
Sleep 1s

Type "i" Enter
Type "Welcome to yazi.nvim!" Enter
Sleep 1s
Type "Let's open a couple of files with yazi." Escape
Sleep 2.5s

# open yazi
Up
Sleep 2.5s

# select ./file-1.txt and open it with Enter
Down
Sleep 0.8s
Enter
Sleep 2s

Type "Go" Enter Enter
Sleep 0.5s
Type "Besides opening in the current buffer," Enter
Type "files can also be opened in splits." Enter
Type "Now let's open a file in a vertical split." Escape
Sleep 1s

# open yazi
Up
Sleep 2s

# select ./file-2.txt
Down
Sleep 0.8s
# open in vertical split
Ctrl+V
Sleep 1s
Type "Go" Enter Enter
Sleep 0.5s
Type "Let's open the next file in a horizontal split." Escape
Sleep 0.5

# open yazi
Up
Sleep 2s

# select ./file-1.txt
Down
Sleep 0.8s
# open in horizontal split
Ctrl+S
Sleep 2s

Type "Go" Enter Enter
Sleep 0.5s
Type "Yazi can also select multiple files" Enter
Type "with <space> or <c-a>." Enter 
Type "This will place them in the quickfix list." Enter 
Sleep 0.5
Type "Let's see what that looks like." Escape
Sleep 1

# close the new split windows in order to make room for the quickfix list
Space 
Type "wd"
Sleep 0.2
Space 
Type "wd"
Sleep 0.2

# open yazi
Up
Sleep 2s
Ctrl+A
Sleep 1s
Enter

Sleep 0.5
