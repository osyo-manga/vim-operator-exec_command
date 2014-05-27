scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! s:_vital_loaded(V)
	let s:V = a:V
endfunction


function! s:_vital_depends()
	return [
\	]
endfunction


function! s:region(pattern, ...)
	let flag_first = get(a:, 1, "")
	let flag_last  = get(a:, 2, "")
	return [searchpos(a:pattern, flag_first), searchpos(a:pattern, flag_last)]
endfunction


function! s:region_pair(fist, last, ...)
	" todo
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
