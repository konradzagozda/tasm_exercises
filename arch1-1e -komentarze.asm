                
; Program znajdujacy najwieksza liczbe w tablicy  


.MODEL  SMALL ; najczęstszy model, kod i dane zawarte w oddzielnych segmentach. Każdy z nich  ma rozmiar mniejszy niż 64KB.

Dane            SEGMENT	; Oczywiście deklaracja segmentu

DL_TABLICA		DB 		12 
Tablica         DB      10h, 05h, 00h, 10h, 12h, 33h, 15h, 09h, 11h, 08h, 0Ah, 00h  ; każda z danych 10h,5h.... jest 8 bitowa (DB)
Najwieksza      DB      0

Dane            ENDS	; koniec segmentu

Kod             SEGMENT

                ASSUME  CS:Kod, DS:Dane		; ASSUME to dyrektywa która jest informacją dla ASEMBLERA nie dla procesora. Mówi mu gdzie ma się spodziewać rejestrów segmentowych.
;Zaladowanie rejestru segmentowego danych
Start:
                mov     ax, Seg Dane		; zaladowanie rejestru DS segmentem danych, dlaczego tak a nie od razu do ds? Tak to działa po prostu nie można nic bezpośrednio włożyć do segmentowych rejestrów, wszytko musi przejść przez rejestry ogólnego przeznaczenia. np ax. Przed nazwą segmentu musimy użyc operatora SEG 
                mov     ds, ax				; w ds już jest segment DANE
				
				; ponieżej bezpośredni tryb adresowania
				mov 	dl, Najwieksza			; dl - najwieksza liczba, dlaczego dl? traktuje to sb jako rejestr do ogólnego użytku, jak zmienną.
				mov 	cl, DL_TABLICA			; cl - dlugosc tablicy, dlaczego cl? bo to count register. ustawiając w cl długość tablicy ustawiam jednocześnie licznik pętli.
				mov 	bi, offset Tablica		; w bi będzie adres Tablicy, offset pobiera przemieszczenie danej w aktualnym segmencie danych zwracając adres.
				
				mov 	al, [bi]	; ustaw 1 element tablicy w al
				; [] + bi wskazują na indeksowy tryb adresowania. bi to base index register. 
				;UWAGA! jakby tam było bx. [bx] to byłby to już bazowy tryb adresowania.
				;
				l1:  ; przeiteruj DL_TABLICA(cl) razy
				

				; tab[bi] > najwieksza? jesli tak to zamień.
				cmp al, dl		; porównanie aktualnego elementu tablicy(al) i "najwieksza", jak działa cmp? odejmuje arg1 - arg2, wynik nie jest nigdzie zapisywany;
				; za to ustawiane są znaczniki przeniesienia i znacznik zera. Na ich podstawie może być podjęta akcja.
				jb noswap		; swapnij jezeli al jest wieksze jezeli nie to jumpuj do noswap.
				mov dl, al		; swap do dl jeżeli znalezlismy wieksza liczbe
				noswap:
				inc bi			; inkrementuj bi(adres elementu tablicy) w konsekwencji przechodzi do nastepnego elementu
				mov al, [bi]    ; włóż do al ten element (to przygotowuje do następnego porównania)
				loop l1			; wróć do etykiety l1. UWAGA! ten krok powoduje dekrementację cl.

				; na koniec przenosimy wartość otrzymaną do zmiennej wynik
				mov Najwieksza, dl  ; Najwieksza to wynik.

                mov     ah, 4ch
                int     21h ; wyjaśnione w zad11c :D


				
Kod          	ENDS	; każdy segment trzeba zakończyć, no chyba że to byłaby uproszczona dyrektywa .CODE to nie trzeba

                END    Start	; zamykamy najbardziej zewnętrzną etykietę.

