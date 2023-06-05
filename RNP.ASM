;Program zamienia dzialania arytmetyczne (+ - * /) na liczbach do maksymalnie 16bit na ODWROTNA NOTACJE POLSKA!!!!!!!
;Dodatkowo uwzglednia liczby ujemne - gdy a - b , dla a<b, to program wyswietli komentarz, ze nie pracuje na liczbach ujemnych
;Rowniez program bierze pod uwage sytuacje dzielenia przez 0 i zapobiega bledom wynikajacym z tego
;Takze program jest odporny na jakkiekolwiek inne znaki wpisane przez uzytkownika zamiast liczb i operandow. Na przyklad (123+245)*asd , program poprosi o ponowne wpisanie dzialania.

org 100h
start:
finit

start2:

call CRLF
call Input
call CRLF
call checkVal
call showVar
call CRLF
call onp
call sayONP
call CRLF

call calc2

call CRLF

call sayWynik
call Display
;----------------------------
koniec:
	mov	ax, 4C00h
	int	21h

say db "Podaj dzialanie do 25 znakow, bez spacji. Przykladowo: (2+1)*3 : $"
say2 db "Postac w onp: $"
say3 db "Wprowadzone dzialanie: $"
say4 db "Wartosc wyrazenia wynosi: $"
sayMinEr db "Blad - Wynik odejmowania nie jest obslugiwany! $"
sayDivEr db "Blad - Wykryto dzielenie przez zero! $"
sayValid db "Nieprawidlowo wprowadzone dzialanie! Sprobuj jeszcze raz. $"
var db 25
	db 0 	
	times 26 db "$"

result	times 26 db "$"
a dw 0
x dw 0
y dw 0
ten dw 10
wynik dw 0
;----------------------------
checkVal:
pusha
pushf
xor ax,ax
xor bx,bx
xor cx,cx
xor dx,dx

mov si,var+2
mov cl,[var+1]
checkLup:
mov al,[si]

	cmp al, 48
	jl maybeV
	cmp al, 57
	jg notValid
	jmp chckLup2	;to liczba
	
maybeV:
	cmp al,40	;(
	je chckLup2
	cmp al,41	;)
	je chckLup2
	cmp al,42	;*
	je chckLup2
	cmp al,43	;+
	je chckLup2
	cmp al,45	;-
	je chckLup2
	cmp al,47	;
	je chckLup2
	;cmp al,33
	;je chckLup2
	
	jmp notValid

chckLup2:
inc si
dec cl
cmp cl,0

je oucik
jmp checkLup

notValid:
mov ah,9
mov dx,sayValid
int 21h
popf
popa
jmp start

oucik:
popf
popa
ret

sayWynik:
pusha
pushf
	
	mov ah,9
	mov dx,say4
	int 21h

popf
popa
ret

calc2:
pusha 
pushf
	xor ax,ax
	xor bx,bx
	xor dx,dx
	xor cx,cx
	
	mov si,result
	
hypeBae:
	mov al,[si]

	cmp al,124	;|
	je koncuje

	cmp al,48
	jl notDigit
	cmp al,57
	jg notDigit
	
	jmp tojestliczba
	
	tojestliczba:
	sub al,48
	
	
etykieta:
	
	inc si
	mov bl,[si]
	cmp bl,48
	jl notDigit
	cmp bl,57
	jg notDigit
	sub bl,48
	
	jmp itsDigit
	
	
	notDigit:
	mov bl,[si]
	
	cmp bl,32	;czy to spacja
	je loudDig
	
	cmp bl,43 	; czy to plus
	je fSum
	
	cmp bl,45	;czy to mninus
	je fDiff
	
	cmp bl,42	; czy mnozenie
	je fMulti
	
	cmp bl,47	;czy dzielenie
	je fDivi
	
	loudDig:
	cmp ax,32
	jne skok
	xor ax,ax
	inc si
	jmp hypeBae
	skok:
	mov [a], ax
	fild word [a]
	
	xor ax,ax	;xoruje CAŁY REJESTR 16 BITOWY !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	
	mov al,0
	mov [a],al
	inc si
	jmp hypeBae
	
	
	itsDigit:
	mov cl,10
	mul cx	;ax 1*10
	
	add ax,bx	; al = al + bl
	
	jmp etykieta
	
	fDivi:
	fistp word [x]	;przy sytuacji 50/ [x] = 0 , [y] = 5 /// 05/ [x] = 5 ,[y] = 0
	
	xor bx,bx
	mov bx,[x]
	cmp bx,0
	jz divZeroE
	fild word [x]
	fdivp			;Divide ST(0) by ST(1), store result in ST(1), and pop the register stack.			;42/ st(0)=2 , st(1)=4 => st(1)/(st0)
	inc si
	jmp hypeBae
	
	
	fMulti:
	fmulp
	
	inc si
	jmp hypeBae
	
	fSum:
	faddp
	inc si
	
	jmp hypeBae
	
	fDiff:
	fistp word [x]	;przy sytuacji 12- [x] = 2 , [y] = 1 /// 21- [x] = 1 ,[y] = 2
	fistp word [y]
	xor dx,dx
	xor bx,bx
	mov bx,[x]
	mov dx,[y]
	
	cmp dx,bx	;Jesli y>x to mozna odejmowac, ale jesli nie to musimy przerwać program i wyrzucić błąd ponieważ nie uwzględniam liczb ujemnych
	jl MinExc
	
	fild word [y]
	fild word [x]
	
	fsubp
	inc si
	jmp hypeBae
	
	MinExc:
	mov ah,9
	mov dx,sayMinEr
	int 21h
	jmp wynocha
	
	divZeroE:
	mov ah,9
	mov dx,sayDivEr
	int 21h
	jmp wynocha
	
	
	koncuje:
	fist word [wynik]
	
	
	wynocha:
popf 
popa
ret

onp:
pusha
pushf
	xor ax,ax

	mov cl,[var+1]	;ilosc znakow
	mov si,var+2
	mov di,result
	xor dx,dx

loopik:

	mov al,[si]

	cmp al, 48
	jl notNumb
	cmp al, 57
	jg notNumb

	jmp itsNumb

	itsNumb:	;Jeśli to liczba to wrzucam na output

	mov [di],al
	inc di
	jmp checkCl
	
	;------------------
	notNumb:	;Jesli nie liczba do dzieją się dymy

	cmp al,40	;(
	je leftBra
	
	cmp al,41	;)
	je rightBra

	cmp al,43 	;+
	je isPluMin

	cmp al,45	;-
	je isPluMin

	cmp al,42	;*
	je isMulDiv

	cmp al,47	;/
	je isMulDiv
	
	
	OPERAND:	;miejsce z dzialaniami na operandach !
	
	;Jesli lewy nawias to wrzucam na stos 
	leftBra:
	xor ah,ah
	push ax
	jmp checkCl
	
	
	
	;/////////////////////////////
	;Procedura isPluMin
	;/////////////////////////////
	isPluMin:	;plus lub minus (ta sama waga operandu)
	mov bl,32
	mov [di],bl
	inc di
	
	
	mov bp,sp
	mov dl,[bp]	;sprawdzam co jest na wierzchu stosu, jesli jest tam jakis operand to musze sprawdzic ktoery jest wazniejszy
	;///////////////////////////////
	cmp dl,43	;sprawdzam czy na wierzchu stosu jest plus
	je Plus

	cmp dl,45	; sprawdzam czy na wirzchu stosu jest minus
	je Plus		;skacze do Plusa bo + i - maja ta sama wage

	cmp dl,42
	je Plus

	cmp dl,47
	je Plus
	
	;Jesli juz nie ma operandow na stosie, to wrzucam + lub -
	notPlus:	;jesli na stosie nie ma plusa albo nie ma nic to wrzucam moj operand - plus na stos i ide dalej
	xor ah,ah
	mov al,[si]
	push ax
	jmp checkCl
	
	;/////////////////////////////
	;Procedura isMulDiv
	;/////////////////////////////
	
	isMulDiv:
	mov bl,32
	mov [di],bl
	inc di
	
	mov bp,sp
	mov dl,[bp]

	cmp dl,42
	je MuLDiv

	cmp dl,47
	je MuLDiv

	notMul:
	xor ah,ah
	mov al,[si]
	push ax
	jmp checkCl
	
	;/////////////////////////////
	;Procedury MulDiv i Plus
	;/////////////////////////////
	
	MuLDiv:
	xor dh,dh
	xor ah,ah
	pop dx
	mov [di],dl
	inc di
	
	jmp isMulDiv
	


	Plus:
	xor dh,dh
	xor ah,ah
	pop dx
	mov [di],dl
	inc di
	
	jmp isPluMin

	;/////////////////////////////
	;Miejsce kończenia naszej pętli oraz przesuwania sie po input, -dec cl , -inc si
	;/////////////////////////////
	checkCl:

	dec cl
	cmp cl,0
	je stosWork
	inc si
	jmp loopik

	;/////////////////////////////
	;Miejsce w ktorym pozbywamy sie operatorow ze stosu
	;/////////////////////////////
	stosWork:

	ClearSt:

	;/////////////////////////////
	;Sprawdzam czy na wierzchu stosu jest operand a nie jakis bajzel
	;/////////////////////////////
	rightBra: ;moze tutaj bo trzeba popowac stos az do nawiasu lewego
	
	mov bp,sp
	xor dx,dx
	mov dx,[bp]
	
	cmp dl,40	;(
	je rmvBraL
	cmp dl,43	;sprawdzam czy jest plus
	je PopujSt
	cmp dl,45	;sprawdzam czh jest minus
	je PopujSt
	cmp dl,42	;sprawdzam czy jesy mnozenie
	je PopujSt
	cmp dl,47	;sprawdzam czy jest dzielenie
	je PopujSt

	;jesli jest smiec albo juz skonczyly sie operandy uciekamy 
	
	jmp enduj2

	;Popujemy operandy ze stosu i doczepiamy do outputu :>>
	PopujSt:
	
	mov al,32	;rozdzielam spacją znaki 
	mov [di],al
	inc di
	
	pop bx		;tutaj popuje operandy i dodaje do outputu
	mov [di],bl
	inc di
	
	jmp ClearSt
	
rmvBraL:
pop bx
xor bx,bx
jmp checkCl		;wracamy do loopa i sprawdzenia czy jeszcze zostalo cos w inpucie

	enduj2:
	
;///////////////////
;DAJE | zeby bylo potem latwiej obliczyc wartosc
	mov bl,124 ;'!'
	mov [di],bl	
;//////////////////
popf
popa

ret


showVar:
pusha
pushf
	mov ah,9
	mov dx,say3
	int 21h

	mov ah,9
	mov dx, var+2
	int 21h
	
popa
popf
ret

Input:
pusha
pushf

	mov ah,9
	mov dx, say
	int 21h
	
	mov ah,10
	mov dx,var
	int 21h

popf
popa

ret	

CRLF:
pusha
pushf

	mov ah,2
	mov dl,13
	int 21h
	mov dl,10
	int 21h

popf
popa
ret

sayONP:
pusha
pushf

mov ah,9
mov dx,say2
int 21h



mov ah,9
mov dx,result
int 21h

popf
popa
ret


Display:
pusha
	pushf
	xor cx,cx

	mov ax,[wynik]	
	mov bx,10		


	dispLoop:
	xor dx,dx	
	div bx		;dzielimy przez 10 zeby otrzymac konkretna cyfre w liczbie !!!!!!!!!	W DX RESZTA , AX CALOSC !!!!!!!!
	push dx		;pushuje na stos RESZTE 


	inc cl		;Cl = ilosc "cyfr w liczbie"
	cmp ax,0	;Jesli w koncu calosc wynosi 0 to juz nie dzielimy tylko wychodzimy
	jne dispLoop

	mov ah,2

	disLoop2:
	pop dx		;popujemy nastepujace cyfry  
	add dx,48	;powrot do cyferki wlasciwej
	int 21h		;wyswietlam cyferke

	dec cl
	cmp cl,0
	jne disLoop2

popf
popa
ret
   
   


