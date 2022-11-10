option casemap:none							; Labels and func names are case-sensitive

public getValFromASM2 

.code

getValFromASM2 proc

	; SHR, SHL, SAR, SAL
	mov al, 11010110b
	shr al, 3 ; Shift 3 bits right. 3rd bit ends up in CF. Left 3 bits filled with zeros
	mov cl, 2 ; As if divided by 4
	clc ; Clear carry flag
	shr al, cl ; Only cl can be used here as second param

	mov al, 129 ; Negativ number
	sar al, 6 ; Left 3 bits filled with ones

	ret

getValFromASM2 endp
end