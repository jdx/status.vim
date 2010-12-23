"============================================================================
"File:        statusline.vim
"Description: Status Line Plugin
"Maintainer:  Jeff Dickey <dickeytk@gmail.com>
"Version:     1.0.0
"Last Change: 15 Dec, 2010
"============================================================================

" Set Version {{{1
let s:statusline_plugin = '1.0.0'

" If already loaded do not load again.
if exists("g:loaded_statusline_plugin") || &cp
    finish
endif

let g:loaded_statusline_plugin = 1

"Function: s:setVariable {{{1
"Desc: Sets user defaults if not defined.
"
"Arguments: var [String], value [Boolean], force [Boolean]
function! s:setVariable(var, value, force)
    if !exists(a:var) || a:force
        exec 'let ' . a:var . ' = ' . "'" . substitute(a:value, "'", "''", "g") . "'"
        return 1
    endif
    return 0
endfunction

" Set User defaults if unset. {{{1
call s:setVariable("g:statusline_fugitive", "1", 0)
call s:setVariable("g:statusline_syntastic", "1", 0)
call s:setVariable("g:statusline_rvm", "1", 0)
call s:setVariable("g:statusline_fullpath", "0", 0)
call s:setVariable("g:statusline_enabled", "1", 0)
if !exists("g:statusline_order")
    let g:statusline_order = [
        \ 'Filename',
        \ 'CheckUnix',
        \ 'Encoding',
        \ 'Help',
        \ 'Filetype',
        \ 'Modified',
        \ 'Fugitive',
        \ 'RVM',
        \ 'TabWarning',
        \ 'TrailingSpaceWarning',
        \ 'Syntastic',
        \ 'Paste',
        \ 'ReadOnly',
        \ 'RightSeperator',
        \ 'CurrentHighlight',
        \ 'CursorColumn',
        \ 'LineAndTotal',
        \ 'FilePercent']
endif

"Function: s:loadPlugins {{{1
"Desc: Loads plugin if user has it enabled.
"
"Arguments: option_name [String], loaded_var [String], plugin [String]
function s:loadPlugins(option_name, loaded_var, plugin)
    if a:option_name && !exists(a:loaded_var)
        exec 'runtime ' . a:plugin
        return 1
    endif
    return 0
endfunction

" Load required plugins if user wants them. {{{2
call s:loadPlugins(g:statusline_fugitive, "g:loaded_fugitive", "plugin/fugitive.vim")
call s:loadPlugins(g:statusline_syntastic, "g:loaded_syntastic_plugin", "plugin/syntastic.vim")
call s:loadPlugins(g:statusline_rvm, "g:loaded_rvm", "plugin/rvm.vim")

if g:statusline_fugitive && !exists('g:loaded_fugitive')
    call s:setVariable("g:statusline_fugitive", "0", 1)
endif

if g:statusline_syntastic && !exists('g:loaded_syntastic_plugin')
    call s:setVariable("g:statusline_syntastic_plugin", "0", 1)
endif

if g:statusline_rvm && !exists('g:loaded_rvm')
    call s:setVariable("g:statusline_rvm", "0", 1)
endif

" Setup status line if we have +statusline and the plugin is enabled. {{{1
if g:statusline_enabled && has('statusline')
    " Give us something to work with.
    set statusline=

    "Function: Filename {{{2
    "Desc: Returns the filename using the relative path or full path based on
    "g:statusline_fullpath.
    function! s:Filename()
        if g:statusline_fullpath
            set statusline+=%F\  " Full Path
        else
            set statusline+=%f\   " Relative file path
        endif
    endfunction

    "Function: CheckUnix {{{2
    "Desc: Display a warning if fileformat isn't unix
    "TODO: Make more generic or provide dos counterpart.
    function! s:CheckUnix()
        set statusline+=%#warningmsg#
        set statusline+=%{&ff!='unix'?'['.&ff.']':''}
        set statusline+=%*
    endfunction

    "Function: Encoding {{{2
    "Desc: Display a warning if the file encoding isn't utf-8
    function! s:Encoding()
        set statusline+=%#warningmsg#
        set statusline+=%{(&fenc!='utf-8'&&&fenc!='')?'['.&fenc.']':''}
        set statusline+=%*
    endfunction

    "Function: Help {{{2
    "Desc: Display the Help file flag
    function! s:Help()
        set statusline+=%h
    endfunction

    "Function: Filetype {{{2
    "Desc: Display the filetype
    function! s:Filetype()
        set statusline+=%y
    endfunction

    "Function: Modified {{{2
    "Desc: Display the modified flag
    function! s:Modified()
        set statusline+=%m
    endfunction

    "Function: Fugitive {{{2
    "Desc: Displays the current git branch if the user has the Fugitive plugin
    "installed and enabled.
    function! s:Fugitive()
        if g:statusline_fugitive
            set statusline+=\ %{fugitive#statusline()}
        endif
    endfunction

    "Function: RVM {{{2
    "Descc: Displays Ruby version from RVM if the plugin is installed and
    "enabled.
    function! s:RVM()
        if g:statusline_rvm
            set statusline+=\ %{rvm#statusline()}
        endif
    endfunction

    "Function: TabWarning {{{2
    "Desc: @see StatuslineTabWarning
    function! s:TabWarning()
        set statusline+=%#error#
        set statusline+=%{StatuslineTabWarning()}
        set statusline+=%*
    endfunction

    "Function: TrailingSpaceWarning {{{2
    "Desc: @see StatuslineTrailingSpaceWarning
    function! s:TrailingSpaceWarning()
        set statusline+=%{StatuslineTrailingSpaceWarning()}
    endfunction

    "Function: Syntastic {{{2
    "Desc: Displays code errors and warnings from Syntastic if the plugin is
    "installed and enabled.
    function! s:Syntastic()
        if g:statusline_syntastic
            set statusline+=%#warningmsg#
            set statusline+=%{SyntasticStatuslineFlag()}
            set statusline+=%*
        endif
    endfunction

    "Function: Paste {{{2
    "Desc: Display a warning [paste] if paste is currently enabled.
    function! s:Paste()
        set statusline+=%#error#
        set statusline+=%{&paste?'[paste]':''}
        set statusline+=%*
    endfunction

    "Function: ReadOnly {{{2
    "Desc: Display a warning [ro] if &ro is set.
    function! s:ReadOnly()
        set statusline+=%#error#
        set statusline+=%{&ro?'[ro]':''}
        set statusline+=%*
    endfunction

    "Function: RightSeperator {{{2
    "Desc: Everything after this is aligned to the right of the statusline.
    function! s:RightSeperator()
        set statusline+=%=
    endfunction

    "Function: CurrentHighlight {{{2
    "Desc: @see StatusLineCurrentHighlight
    function! s:CurrentHighlight()
        set statusline+=%{StatuslineCurrentHighlight()}\ \ "current highlight
    endfunction

    "Function: CursorColumn {{{2
    "Desc: Display the cursor column.
    function! s:CursorColumn()
        set statusline+=%c,
    endfunction

    "Function: LineAndTotal {{{2
    "Desc: Display cursor line/total lines for the current buffer
    function! s:LineAndTotal()
        set statusline+=%l/%L
    endfunction

    "Function: FilePercent {{{2
    "Desc: Display percentage through file.
    function! s:FilePercent()
        set statusline+=\ %P
    endfunction

    " Always display the status line. 
    set laststatus=2

    if has("autocmd")
        "Recalculate the tab warning flag when idle and after writing.
        autocmd cursorhold,bufwritepost * unlet! b:statusline_tab_warning
    endif

    for i in g:statusline_order
        if i =~? "\^[a-z0-9_]"
            call eval('s:' . i . '()')
       endif
    endfor
endif

"Function: StatuslineCurrentHighlight {{{1
"Desc: Returns the syntax highlight group under the cursor.
function! StatuslineCurrentHighlight()
    let name = synIDattr(synID(line('.'),col('.'),1),'name')
    if name == ''
        return ''
    else
        return '[' . name . ']'
    endif
endfunction

"Function: StatuslineTrailingSpaceWarning {{{1
"Desc: Returns '[\s]' if trailing white space detected
function! StatuslineTrailingSpaceWarning()
    if !exists("b:statusline_trailing_space_warning")
        if search('\s\+$', 'nw') != 0
            let b:statusline_trailing_space_warning = '[\s]'
        else
            let b:statusline_trailing_space_warning = ''
        endif
    endif
    return b:statusline_trailing_space_warning
endfunction

"Function: StatuslineTabWarning {{{1
"Desc: Returns '[&et]' if &et is set wrong
"      Returns '[mixed-indenting]' if spaces and tabs are used to indent
function! StatuslineTabWarning()
    if !exists("b:statusline_tab_warning")
        let tabs = search('^\t', 'nw') != 0
        let spaces = search('^ ', 'nw') != 0

        if tabs && spaces
            let b:statusline_tab_warning =  '[mixed-indenting]'
        elseif (spaces && !&et) || (tabs && &et)
            let b:statusline_tab_warning = '[&et]'
        else
            let b:statusline_tab_warning = ''
        endif
    endif
    return b:statusline_tab_warning
endfunction

"Function: StatuslineLongLineWarning {{{1
"Desc: Return a warning for "long lines" where "long" is either &textwidth or 80 (if
"no &textwidth is set)
"
"return '' if no long lines
"return '[#x,my,$z] if long lines are found, were x is the number of long
"lines, y is the median length of the long lines and z is the length of the
"longest line
function! StatuslineLongLineWarning()
    if !exists("b:statusline_long_line_warning")
        let long_line_lens = s:LongLines()

        if len(long_line_lens) > 0
            let b:statusline_long_line_warning = "[" .
                        \ '#' . len(long_line_lens) . "," .
                        \ 'm' . s:Median(long_line_lens) . "," .
                        \ '$' . max(long_line_lens) . "]"
        else
            let b:statusline_long_line_warning = ""
        endif
    endif
    return b:statusline_long_line_warning
endfunction

"Function: LongLines {{{1
"Desc: Return a list containing the lengths of the long lines in this buffer
function! s:LongLines()
    let threshold = (&tw ? &tw : 80)
    let spaces = repeat(" ", &ts)

    let long_line_lens = []

    let i = 1
    while i <= line("$")
        let len = strlen(substitute(getline(i), '\t', spaces, 'g'))
        if len > threshold
            call add(long_line_lens, len)
        endif
        let i += 1
    endwhile

    return long_line_lens
endfunction

"Function: Median {{{1
"Desc: Find the median of the given array of numbers
"
"Arguments: nums [Integer]
function! s:Median(nums)
    let nums = sort(a:nums)
    let l = len(nums)

    if l % 2 == 1
        let i = (l-1) / 2
        return nums[i]
    else
        return (nums[l/2] + nums[(l/2)-1]) / 2
    endif
endfunction
