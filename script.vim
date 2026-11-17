function! RandomShuffle(allChars) abort
    let chars = a:allChars
    let i = len(chars) - 1

    while i > 0
        let j = rand() % (i + 1)
        let tmp = chars[i]
        let chars[i] = chars[j]
        let chars[j] = tmp
        let i -= 1
    endwhile

    return chars
endfunction


function! GetFileInfo() abort
    " let filename = bufname("%")
    let lines=getline(1, '$')

    let cntCharInLine = []
    let allChars = []

    for line in lines
        call add(cntCharInLine, len(line))
        
        for char in line
            call add(allChars, char)
        endfor
    endfor

    return [lines, cntCharInLine, allChars]
endfunction

function! ShuffleFile() abort
    let [lines, cntCharInLine, allChars] = GetFileInfo()
    let allChars = RandomShuffle(allChars)

    " applying shuffle to all lines
    let was = 0
    for i in range(0, len(lines) - 1)
        let lines[i] = join(slice(allChars, was, was + cntCharInLine[i]), '')
        let was += cntCharInLine[i]
    endfor

    call setline(1, lines)
    if line('$') > len(lines)
        call deletebufline(bufnr('%'), len(lines) + 1, '$')
    endif
endfunction


set updatetime=5000

function! s:StopOnKey(popup, key) abort
  if a:key !=# "\<CursorHold>"
    call popup_close(a:popup)
  endif
  return 0
endfunction

function! s:StartShuffle() abort
  let [row, col] = win_screenpos(0)
  let popup = popup_create(getline(1, '$'), {
        \ 'line': row, 'col': col, 'minwidth': winwidth(0),
        \ 'minheight': winheight(0), 'maxheight': winheight(0),
        \ 'wrap': 0, 'scrollbar': 0, 'filter': function('s:StopOnKey'),
        \ 'highlight': 'Normal',
        \ })

  call win_execute(popup, 'setlocal modifiable | call ShuffleFile()')
  let timer = timer_start(100,
        \ {id -> win_execute(popup, 'call ShuffleFile() | redraw')},
        \ {'repeat': -1})
  call popup_setoptions(popup, {'callback': {id, result -> timer_stop(timer)}})
endfunction

augroup IdleShuffle
  autocmd!
  autocmd CursorHold,CursorHoldI * call <SID>StartShuffle()
augroup END
