scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


let s:holders = map(split(globpath(expand("<sfile>:p:h") . "/Holder", "*"), "\n"), "fnamemodify(v:val, ':t:r')")

function! s:_vital_loaded(V)
	let s:V = a:V
	for name in s:holders
		let {"s:".name} = a:V.import("Unlocker.Holder." . name)
	endfor
endfunction


function! s:_vital_depends()
	return map(copy(s:holders), "'Unlocker.Holder.' . v:val")
endfunction


function! s:as_get_deepcopy(holder)
	if has_key(a:holder, "__holder_as_get_deepcopy_get")
		return a:holder
	endif
	let result = copy(a:holder)
	let result.__holder_as_get_deepcopy_get = result.get
	function! result.get()
		return deepcopy(self.__holder_as_get_deepcopy_get())
	endfunction
	return result
endfunction


function! s:as_set_extend(holder)
	if has_key(a:holder, "__holder_as_set_extend_set")
		return a:holder
	endif
	let result = copy(a:holder)
	let result.__holder_as_set_extend_set = result.set
	function! result.set(value)
		let result = deepcopy(extend(self.get(), a:value))
		call self.__holder_as_set_extend_set(result)
	endfunction
	return result
endfunction


for s:name in s:holders
	execute
\		"function! s:" . tolower(s:name) . "(...)\n"
\		"	return call(s:" . s:name . ".make, a:000, s:" . s:name . ")\n"
\		"endfunction\n"
endfor


function! s:option(name)
	return s:Variable.make("&" . a:name)
endfunction




let &cpo = s:save_cpo
unlet s:save_cpo
