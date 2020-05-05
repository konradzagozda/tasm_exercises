
; Format         : COM                                                        ;
; Cwiczenie      : Program dodający 2 liczby z zakresu [-32768 ... 32767]     ;

PrintCode      EQU     09h								; 09h - funkcja zmienająca znak w miejscu ustawienia kursora
WriteCharCode  EQU     0Ah								; kod zapisu znaku
ExtCode        EQU     4Ch                              ; kod funkcji zakończenia programu


.386p													; udostępnienie instrukcji procesora 80386
Code			SEGMENT USE16							; segmentacja 16bitowa ( co 16 bitów nowy segment )
		
				ORG		100h							; ustawienie wskaźnika pozycji na 100h, pierwsze 256 bajtów zajmuje obszar psp
				ASSUME	CS:Code, DS:Code, SS:Code		; informacja dla kompilatora które segmenty są wskazywane przez rejestry
	
Main:

				call 	GetInput						; pobranie 1 danej
				cwde									; convert word to double extended, zamienia słowo w AX na podwójne słowo w EAX 
				mov 	First_Number, eax						
				call	GetInput						; pobranie 2 danej
				cwde
				add		eax, First_Number				; dodanie
				call	Print							; wydruk
				mov		ah,ExtCode						
				int		21h								; 21h = przerwania uniwersalne system MS-DOS (współpracuje z ah)


GetInput		PROC

				mov 	dx, OFFSET Prompt				; offset pobierze przemieszczenie w danym segmencie symbolu PROMP => w dx adres Prompt
				mov		ah, PrintCode					; 09h - funkcja zmienająca znak w miejscu ustawienia kursora
				int 	21h								; pokaż prompt
			
				mov		dx, OFFSET Array_Structure		; w dx mamy adres Array_Structure DS:DX - adres bufora wejściowego dla funkcji WriteCharCode).
				mov		ah, WriteCharCode
				int		21h								; wykonaj pobranie
														 
				xor		cx,cx							; czyści rejestr cx (count register)
				mov		cl, Array_Length				; cl wskazuje na Array_Length, counter równy ilości znaków.
				mov		si, OFFSET Array_Characters		; Array_Characters jako adreś źródła operacji łańcuchowej ( si - source index )
				
				mov		bl, '-'							
				cmp 	Array_Characters, bl			; porównaj 1 znak Array_Characters i '-'

				jne		Check_if_number_loop 			; jne = jump not equal
				; jezeli ujemna to wykonaj to
				dec		cl								; zmniejsz cl o jeden
				inc 	si								; zwiększ si o jeden

Check_if_number_loop:									; tu skocz jeśli Array_Characters != '-'
				mov		bl ,[si]						; indeksowy tryb adresowania, prześlij daną o adresie si do bl
				cmp		bl, '0'							; porównaj bl i '0'
				jb		Error							; jeśli < 0 to nie jest liczba.
				cmp		bl, '9'							; jeśli > 9 to nie jest liczba
				ja		Error							
				inc		si								; si zwiększ o jeden
				loop	Check_if_number_loop			; i sprawdz nastepny znak
				jmp		Input_is_a_number

Error:													; error jesli liczba nie jest z zakresu 0-9
				mov 	dx, OFFSET Error_Notice			; w dx wartość pierwszego znaku "Error_Notice"
				mov		ah, PrintCode					; 09h
				int 	21h	
				mov		ah, ExtCode						; jeżeli error to zamknij program
				int		21h

Input_is_a_number:					
				mov		cl, Array_Length				; w cl długość arraya
				mov		si, OFFSET Array_Characters		; si wskazuje na 1 faktyczny znak
				
				mov		bl, '-'
				cmp 	Array_Characters, bl			; arr[0] == '-' ?
				jne		Num_is_positive	                ; jeżeli nie jest ujemna to skocz to IsPositive
				dec		cl								
				inc 	si
Num_is_positive:			
				xor		ax, ax
				xor		dx, dx 
				mov 	bx, 10							; w bx 10
Change_ASCII_array_to_num_loop:							; algorytm zamiany  ASCII na liczbę
				mul		bx 								; ax * bx 
				mov		dl ,[si]						; w dl każda kolejny znak ASCII ciągu
				sub		dl, '0'							; konwersja znaku ASCII na faktyczną cyfrę.
				add		ax, dx
				inc		si								; wskaż na następny znak ascii
				loop	Change_ASCII_array_to_num_loop
														; tutaj już mamy w ax liczbę 
				mov		bl, '-'
				cmp		Array_Characters, bl			; arr[0] == '-'?										
				jne		Dont_convert_to_U2
				neg		ax								; jeżeli liczba była ujemna to przekształcamy ją na kod U2 
Dont_convert_to_U2:
				push	ax								; Nasza liczba pod ax leci na stos
				mov		ah, 02h							; 02h - write character to stdout
				mov		dl, 0Ah						    ; dl - character to write ( 0ah = new line )
				int 	21h								
				pop		ax								; zdejmij liczbe ze stosu
				
				ret
GetInput		ENDP

Print			PROC

				mov		ebx, 10							; ebx = 10
				cmp		eax, 0							; w eax jest liczba do druku, 
				jge		Convert_to_ASCII				; num >= 0 ? jesli tak to skacz
				push	eax								; jeżeli jest ujemna to jej wartość na stos, i wydrukuj '-'
				mov		dl, '-'							; wypisze '-'
				mov		ah, 02h							; write character to stdout
				int 	21h								
				pop		eax								; zdejmij liczbe ze stosu
				neg		eax								; skoro była ujemna to odwracamy kodowanie U2 na zwykłe kodowanie.
Convert_to_ASCII:										; rozdziel liczbę w eax na znaki ascii.
				xor 	edx, edx						; edx = 0
				div		ebx								; podziel liczbę przez 10. w eax całkowity wynik w edx reszta z dzielenia. 
				mov		Remainder, edx					
				mov		dx, word ptr Remainder			; w dx młodsze słowo Remainder ( 0 - 9 )
				add		dl, '0'							; konwertuj to na znak ascii
				push	dx								; dx na stos
				inc		cx								; cx++, przygotowanie do pętli drukującej
				cmp		eax, 0							; sprawdza czy są same 0,
				jnz		Convert_to_ASCII				; jezeli cos zostalo to powtórz
				mov		ah, 02h							; drukuj to co w dl 
print_each_char:										; po kolei zdejmuj ze stosu i drukuj znaki ASCII.
				pop		dx					
				int 	21h
				loop 	print_each_char
				ret

Print			ENDP

Prompt				DB		"Podaj liczbe $"				; declare byte, Prompt - adres ciągu znaków 
Error_Notice		DB		"Niepoprawne dane $"			; Error_notice - adres ciagu znaków
First_Number		DD		?								; declare double word
Remainder			DD		?

Array_Structure		DB		7								; Pod to miejsce zostanie wczytany wiersz (maks 6 znaków np. -31111), 1 cyfra zarewerwowana na długość arraya.
Array_Length		DB		?								; rzeczywista długość ciągu znaków
Array_Characters	DB		?								; Właściwe znaki 

Code			ENDS
				
				END 	Main