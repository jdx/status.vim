"============================================================================
"File:        statusline.vim
"Description: Status Line Plugin
"Maintainer:  Jeff Dickey <dickeytk@gmail.com>
"Version:     1.0.0
"Last Change: 09 Dec, 2010
"============================================================================

" Set Version
let s:statusline_plugin = '1.0.0'

" If already loaded do not load again.
if exists("g:loaded_statusline_plugin") || &cp
    finish
endif

let g:loaded_statusline_plugin = 1

" FUNCTION: Sets User defaults if not defined.
function! s:setVariable(var, value, force)
    if !exists(a:var) || a:force
        exec 'let ' . a:var . ' = ' . "'" . substitute(a:value, "'", "''", "g") . "'"
        return 1
    endif
    return 0
endfunction

" Set User defaults if unset.
call s:setVariable("g:statusline_fugitive", "1", 0)
call s:setVariable("g:statusline_syntastic", "1", 0)
call s:setVariable("g:statusline_rvm", "1", 0)
call s:setVariable("g:statusline_fullpath", "0", 0)
call s:setVariable("g:statusline_enabled", "1", 0)

" FUNCTION: Loads plugin if user has it enabled
function s:loadPlugins(option_name, loaded_var, plugin)
    if a:option_name && !exists(a:loaded_var)
        exec 'runtime ' . a:plugin
        return 1
    endif
    return 0
endfunction

" Load required plugins if user wants them.
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

if g:statusline_enabled && has('statusline')
    " Status bar
    if g:statusline_fullpath
        set statusline=%F\  " Full Path
    else
        set statusline=%f\   " Relative file path
    endif

    "display a warning if fileformat isnt unix
    set statusline+=%#warningmsg#
    set statusline+=%{&ff!='unix'?'['.&ff.']':''}
    set statusline+=%*

    "display a warning if file encoding isnt utf-8
    set statusline+=%#warningmsg#
    set statusline+=%{(&fenc!='utf-8'&&&fenc!='')?'['.&fenc.']':''}
    set statusline+=%*

    set statusline+=%h      "help file flag
    set statusline+=%y      "filetype
    set statusline+=%m      "modified flag

    " display current git branch
    if g:statusline_fugitive
        set statusline+=\ %{fugitive#statusline()}
    endif

    " Display RVM 
    if g:statusline_rvm
        set statusline+=\ %{rvm#statusline()}
    endif

    "display a warning if &et is wrong, or we have mixed-indenting
    set statusline+=%#error#
    set statusline+=%{StatuslineTabWarning()}
    set statusline+=%*

    set statusline+=%{StatuslineTrailingSpaceWarning()}

    if g:statusline_syntastic
        set statusline+=%#warningmsg#
        set statusline+=%{SyntasticStatuslineFlag()}
        set statusline+=%*
    endif

    "display a warning if &paste is set
    set statusline+=%#error#
    set statusline+=%{&paste?'[paste]':''}
    set statusline+=%*

    "display a warning if &ro is set
    set statusline+=%#error#
    set statusline+=%{&ro?'[ro]':''}
    set statusline+=%*

    set statusline+=%=      "left/right separator
    set statusline+=%{StatuslineCurrentHighlight()}\ \ "current highlight
    set statusline+=%c,     "cursor column
    set statusline+=%l/%L   "cursor line/total lines
    set statusline+=\ %P    "percent through file
    set laststatus=2        " Always show status line

    if has("autocmd")
        "recalculate the tab warning flag when idle and after writing
        autocmd cursorhold,bufwritepost * unlet! b:statusline_tab_warning
    endif

endif

"return the syntax highlight group under the cursor ''
function! StatuslineCurrentHighlight()
    let name = synIDattr(synID(line('.'),col('.'),1),'name')
    if name == ''
        return ''
    else
        return '[' . name . ']'
    endif
endfunction

"recalculate the trailing whitespace warning when idle, and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_trailing_space_warning

"return '[\s]' if trailing white space is detected
"return '' otherwise
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

"return '[&et]' if &et is set wrong
"return '[mixed-indenting]' if spaces and tabs are used to indent
"return an empty string if everything is fine
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

"return a warning for "long lines" where "long" is either &textwidth or 80 (if
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

"return a list containing the lengths of the long lines in this buffer
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

"find the median of the given array of numbers
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
