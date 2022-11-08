
option casemap:none							; Labels and func names are case-sensitive

public start								; Otherwise linker throws an error
public getValFromASM 

.code
start:

getValFromASM proc
	mov eax, 5
	ret
getValFromASM endp
end