scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of("operator_exec_command")
let s:C = s:V.import("Coaster.Buffer")
let s:U = s:V.import("Unlocker.Rocker")

function! s:exec(format, input, wise)
" 	let exec = a:format
" 	silent! let exec = printf(a:format, a:input)
	let exec = substitute(substitute(a:format, "%t", a:input, "g"), "%v", a:wise, "g")
	let locker = s:U.lock("&selection")
	set selection=inclusive
	try
		execute exec
	finally
		call locker.unlock()
	endtry
endfunction


function! operator#exec_command#do(wise)
	let wise = s:C.as_wise_key(a:wise)
	let text = s:C.get_text_from_latest_yank(wise)
	if exists("s:exec_format")
		call s:exec(s:exec_format, text, wise)
		unlet s:exec_format
	endif
endfunction
:call operator#user#define('exec_command-do', 'operator#exec_command#do')


function! operator#exec_command#mapexpr(format)
	let s:exec_format = a:format
	return "\<Plug>(operator-exec_command-do)"
endfunction


function! operator#exec_command#mapexpr_v_keymapping(key, ...)
	let noremap = get(a:, 1, 0)
	if noremap
		let format = printf("normal! `[%v`]%s", a:key)
	else
		let format = printf("normal `[%v`]%s", a:key)
	endif
	return operator#exec_command#mapexpr(format)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
