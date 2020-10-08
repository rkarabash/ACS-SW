format PE console
entry start

include 'win32a.inc'

section '.data' data readable writable

        strVecSize   db 'Input array size: ', 0
        strIncorSize db 'Invalid array size = %d', 10, 0
        strVecElemI  db 'Input A[%d] element of array: ', 0
        strScanInt   db '%d', 0
        strMinValue  db 'Minimal value = %d', 10, 0
        strVecElemOut  db 'B[%d] = %d', 10, 0

        vec_size     dd 0
        min          dd ?
        i            dd 0
        size_tmp     dd ?
        tmp          dd ?
        tmpStack     dd ?
        vec          rd 3

;--entry point--
section '.code' code readable executable
start:
; 1) input of array A
        call VectorInput
; 2) get min value
        call MinValue
; 3) print min value
        push [min]
        push strMinValue
        call [printf]
; 4) output of array B
        call VectorOut
finish:
        call [getch]

        push 0
        call [ExitProcess]

;--input of array A--
VectorInput:
        push strVecSize
        call [printf]
        add esp, 4

        push vec_size
        push strScanInt
        call [scanf]
        add esp, 8


        mov eax, [vec_size]
        cmp eax, 0
        jg  getVector
; invalid array size instruction
        push [vec_size]
        push strIncorSize
        call [printf]
        jmp finish

getVector:
        xor ecx, ecx
        mov ebx, vec
getVecLoop:
        mov [tmp], ebx
        cmp ecx, [vec_size]
        jge endInputVector

        mov [i], ecx
        push ecx
        push strVecElemI
        call [printf]
        add esp, 8

        push ebx
        push strScanInt
        call [scanf]
        add esp, 8

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp getVecLoop
endInputVector:
        ret
;--get min value--
MinValue:
        xor ecx, ecx
        mov ebx, vec
        mov [min], ebx
        inc ecx
        add ebx, 4
minValLoop:
        cmp ecx, [vec_size]
        je endMinValue

        mov eax, [ebx]

        cmp [min], eax
        jge startMin

        inc ecx
        add ebx, 4

        jmp minValLoop
startMin:
        mov [min], eax
        inc ecx
        add ebx, 4
        jmp minValLoop
endMinValue:
        ret
;--output of array B--
VectorOut:
        mov [tmpStack], esp
        xor ecx, ecx
        xor eax, eax
        mov ebx, vec
putVecLoop:
        cmp ecx, [vec_size]
        je endOutputVector

        mov eax, [ebx]
        cmp eax, [min]
        je MinMethod

        mov [i], ecx
        mov [tmp], ebx

        push dword [ebx]
        push ecx
        push strVecElemOut
        call [printf]

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp putVecLoop
MinMethod:
        dec [vec_size]
        add ebx, 4
        jmp putVecLoop
endOutputVector:
        mov esp, [tmpStack]
        ret

;--import getch, scanf, printf--
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess',\
           HeapCreate,'HeapCreate',\
           HeapAlloc,'HeapAlloc'
  include 'api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'