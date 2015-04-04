scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! s:_vital_loaded(V)
	let s:V = a:V
	let s:Value = a:V.import("Unlocker.Holder.Value")
	let s:Variable = a:V.import("Unlocker.Holder.Variable")
	let s:Multi = a:V.import("Unlocker.Holder.Multi")
endfunction


function! s:_vital_depends()
	return [
\		"Unlocker.Holder.Variable",
\		"Unlocker.Holder.Value",
\		"Unlocker.Holder.Multi",
\	]
endfunction


function! s:is_holder(rhs)
	return type(a:rhs) == type({})
\		&& type(get(a:rhs, "get", "")) == type(function("tr"))
\		&& type(get(a:rhs, "set", "")) == type(function("tr"))
endfunction


function! s:is_option(rhs)
	return type(a:rhs) == type("")
\		&& exists("&" . a:rhs)
endfunction


function! s:throw(exp)
	execute "throw" string(a:exp)
endfunction


function! s:make(rhs, ...)
	return a:0 >= 1 ? s:Multi.make(map([a:rhs] + a:000, "s:make(v:val)"))
\		 : s:is_holder(a:rhs)   ? a:rhs
\		 : s:Value.is_makeable(a:rhs) ? s:Value.make(a:rhs)
\		 : s:Variable.is_makeable(a:rhs) ? s:Variable.make(a:rhs)
\		 : s:is_option(a:rhs) ? s:Variable.make("&" . a:rhs)
\		 : s:throw("vital-unlocker Unlocker.Holder.Any.make() : No supported value.")
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
