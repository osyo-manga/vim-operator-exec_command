scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

function! s:_vital_loaded(V)
	let s:V = a:V
	let s:Search = a:V.import("Coaster.Search")
endfunction


function! s:_vital_depends()
	return [
\		"Coaster.Search"
\	]
endfunction


" a <= b
function! s:pos_less_equal(a, b)
	return a:a[0] == a:b[0] ? a:a[1] <= a:b[1] : a:a[0] <= a:b[0]
endfunction


function! s:as_wise_key(name)
	return a:name ==# "char"  ? "v"
\		 : a:name ==# "line"  ? "V"
\		 : a:name ==# "block" ? "\<C-v>"
\		 : a:name
endfunction

function! s:get_text_from_latest_yank(...)
	let wise = get(a:, 1, "v")
	let register = v:register == "" ? '"' : v:register

	let old_selection = &selection
	let &selection = 'inclusive'
	let old_pos = getpos(".")
	let old_reg = getreg(register)
	try
		execute printf('silent normal! `[%s`]y', wise)
		return getreg(register)
	finally
		let &selection = old_selection
		call setreg(register, old_reg)
		call cursor(old_pos[1], old_pos[2])
	endtry
endfunction


function! s:get_text_from_region(first, last, ...)
	let wise = get(a:, 1, "v")

	let old_first = getpos("'[")
	let old_last  = getpos("']")
	try
		call setpos("'[", a:first)
		call setpos("']", a:last)
		return s:get_text_from_latest_yank(wise)
	finally
		call setpos("'[", old_first)
		call setpos("']", old_last)
	endtry
endfunction


function! s:get_text_from_pattern(pattern)
	let [first, last] = s:Search.region(a:pattern, "Wncb", "Wnce")
	if first == [0, 0]
		return ""
	endif
	if last == [0, 0]
		return ""
	endif
	let result = s:get_text_from_region([0] + first + [0], [0] + last + [0], "v")
	if result =~ '^' . a:pattern . '$'
		return ""
	endif
	return result
endfunction



function! s:_as_config(config)
	let default = {
\		"textobj" : "",
\		"is_cursor_in" : 0,
\		"noremap" : 0,
\	}
	let config
\		= type(a:config) == type("") ? { "textobj" : a:config }
\		: type(a:config) == type({}) ? a:config
\		: {}
	return extend(default, config)
endfunction


let s:region = []
let s:wise = ""
function! s:_buffer_region_operator(wise)
	let reg_save = @@
	let s:wise = a:wise
	let s:region = [getpos("'[")[1:], getpos("']")[1:]]
	let @@ = reg_save
endfunction

nnoremap <silent> <Plug>(vital-coaster_buffer_region)
\	:<C-u>set operatorfunc=<SID>_buffer_region_operator<CR>g@


function! s:get_region_from_textobj(textobj)
	let s:region = []
	let config = s:_as_config(a:textobj)

	let pos = getpos(".")
	try
		silent execute (config.noremap ? 'onoremap' : 'omap') '<expr>'
\			'<Plug>(vital-coaster_buffer_region-target)' string(config.textobj)

		let tmp = &operatorfunc
		silent execute "normal \<Plug>(vital-coaster_buffer_region)\<Plug>(vital-coaster_buffer_region-target)"
		let &operatorfunc = tmp

		if !empty(s:region) && !s:pos_less_equal(s:region[0], s:region[1])
			return ["", []]
		endif
		if !empty(s:region) && config.is_cursor_in && (s:pos_less(pos[1:], s:region[0]) || s:pos_less(s:region[1], pos[1:]))
			return ["", []]
		endif
		return deepcopy([s:wise, s:region])
	finally
		call cursor(pos[1], pos[2])
	endtry
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
