scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

" let s:V = vital#of("operator_exec_command")
let s:V = vital#operator_exec_command#of()
let s:C = s:V.import("Coaster.Buffer")
let s:U = s:V.import("Unlocker.Rocker")
let s:Prelude = s:V.import("Data.String")

function! s:exec(formats, input, wise)
	let locker = s:U.lock("&selection")
	set selection=inclusive
	try
		for format in a:formats
			let exec = substitute(substitute(format, "%t", a:input, "g"), "%v", a:wise, "g")
			execute exec
		endfor
	finally
		call locker.unlock()
	endtry
	if exists("s:cursor")
		call setpos(".", s:cursor)
		unlet s:cursor
	endif
endfunction


function! operator#exec_command#do(wise)
	let s = s:exec_formats
	let wise = s:C.as_wise_key(a:wise)
	let text = s:C.get_text_from_latest_yank(wise)
	if exists("s:exec_formats")
		call s:exec(s:exec_formats, text, wise)
" 		unlet s:exec_formats
	endif
endfunction
call operator#user#define('exec_command-do', 'operator#exec_command#do')


function! operator#exec_command#mapexpr(format, ...)
	let s:exec_formats = type(a:format) == type([]) ? a:format : [a:format]
	let config = get(a:, 1, {})
	if get(config, "stay_cursor", 0)
		let s:cursor = getpos(".")
	endif
	return "\<Plug>(operator-exec_command-do)"
endfunction


function! operator#exec_command#mapexpr_v_keymapping(key, ...)
	let noremap = get(a:, 1, 0)
	let config = get(a:, 2, {})
	if noremap
		let format = printf("normal! `[%v`]%s", a:key)
	else
		let format = printf("normal `[%v`]%s", a:key)
	endif
	return operator#exec_command#mapexpr(format)
endfunction


function! s:set_search_regeister(text)
	let format = s:config.search_register_format
	let @/ = substitute(format, "%t", s:Prelude.escape_pattern(a:text), "g")
endfunction


function! operator#exec_command#mapexpr_gn(key, ...)
	let noremap = get(a:, 1, 0)
	let config = extend({
\		"search_register_format" : '\<%t\>'
\	}, get(a:, 2, {}))
	let s:config = config
	return operator#exec_command#mapexpr(["call s:set_search_regeister('%t')", printf('call feedkeys(''%sgn'', ''%s'')', a:key, noremap ? "n" : "m")], config)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
