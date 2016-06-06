" ___vital___
" NOTE: lines between '" ___vital___' is generated by :Vitalize.
" Do not mofidify the code nor insert new lines before '" ___vital___'
if v:version > 703 || v:version == 703 && has('patch1170')
  function! vital#_operator_exec_command#Unlocker#Holder#Register#import() abort
    return map({'is_makeable': '', 'make': ''},  'function("s:" . v:key)')
  endfunction
else
  function! s:_SID() abort
    return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze__SID$')
  endfunction
  execute join(['function! vital#_operator_exec_command#Unlocker#Holder#Register#import() abort', printf("return map({'is_makeable': '', 'make': ''}, \"function('<SNR>%s_' . v:key)\")", s:_SID()), 'endfunction'], "\n")
  delfunction s:_SID
endif
" ___vital___
scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:obj = {}

function! s:obj.get()
	return getreg(self.__name)
endfunction


function! s:obj.set(value)
	if self.__option == ""
		call setreg(self.__name, a:value)
	else
		call setreg(self.__name, a:value, self.__option)
	endif
	return self
endfunction


function! s:is_makeable(expr)
	return type(a:expr) == type("") && a:expr =~# '^@.\+'
endfunction


function! s:make(expr, ...)
	let result = deepcopy(s:obj)
	let result.__name = (strlen(a:expr) == 1 ? a:expr : a:expr[1:])
	let result.__option = get(a:, 1, "")
	return result
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
