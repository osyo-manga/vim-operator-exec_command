scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:C = vital#of("operator_exec_command").import("Coaster.Buffer")

function! s:exec(format, input, wise)
" 	let exec = a:format
" 	silent! let exec = printf(a:format, a:input)
	let exec = substitute(substitute(a:format, "%t", a:input, "g"), "%v", a:wise, "g")
	execute exec
endfunction


function! operator#exec_command#do(wise)
	let wise = s:C.as_wise_key(a:wise)
	let text = s:C.get_text_from_latest_yank(wise)
	if exists("s:exec_format")
		call s:exec(s:exec_format, text, wise)
		unlet s:exec_format
	endif
endfunction

call operator#user#define('exec_command-do', 'operator#exec_command#do')


function! operator#exec_command#mapexpr(format)
	let s:exec_format = a:format
	return "\<Plug>(operator-exec_command-do)"
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
