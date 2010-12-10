Statusline
==========

**Homepage**:   [https://github.com/dickeytk/status.vim](https://github.com/dickeytk/status.vim)  
**Author**:     Jeff Dickey  

About
-----

Simple vim plugin to extend your statusline. Originally based on comments made
on
[reddit](http://www.reddit.com/r/vim/comments/e19bu/whats_your_status_line/).

Dependencies
------------

All dependencies are optional, however they are expected to be installed by
default. If either are not found you will see an error message. You can disable
these errors by setting some options in your ~/.vimrc.

Example:

    "Load Fugitive
    let g:statusline_fugitive = 1
    "Do Not Load Syntastic
    let g:statusline_syntastic = 0


* [Fugitive](https://github.com/tpope/vim-fugitive)
* [Syntastic](https://github.com/scrooloose/syntastic)

Install
------

With pathogen it's recommended to install as a submodule.

    cd ~/.vim
    git submodule add git://github.com/dickeytk/status.vim.git bundle/status.vim

To install as a normal plugin grab a tarball
[here](https://github.com/dickeytk/status.vim/tarball/master) and extract it.
Then just copy statusline.vim to your plugin directory.

    cp plugin/status.vim ~/.vim/plugin/
