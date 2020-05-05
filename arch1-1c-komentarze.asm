; Format         : COM                                                        
                       
; Uwagi          : Program obliczajacy wzor: (a-b)*c/d          



                .MODEL TINY ;model tiny = 1 segment nie większy niż 64KB
                .CODE   ; uproszczona dyrektywa segmentu kodu _TEXT
                ORG    100h  ;konieczne przemieszczenie dla plików typu .com, ORG = ustawienie wskaźnika pozycji
Start:          ; to jest etykieta Start
                jmp		Poczatek ; skocz do etykiety pod nazwą Poczatek

a               DW      20       ; deklaracje zmiennych DW - declare word, DB - declare byte
b               DW      10
c               DW     100
d               DW       5
;wynik           DW       ?       ; ? = zmienna niezainicjowana

Poczatek:		; to jest etykieta Poczatek

				mov ax, a       ; wkładamy do ax zmienną a, możemy to zrobić bo zgadzają się typy danych, ax to rejest 16 bitowy, a jest typu word więc też jest 16 bitowa.
				sub ax, b       ; a - b, odejmuje od ax b
				mul c           ; (a - b) * c, tutaj nie podajemy tylko jeden argument, bo mul pracuje na tzw. TRYB ADRESOWANIA DOMYŚLNY tzn. że jego argumenten jest domyślny rejestr AX, lub AL ( w zależności od typu danej (8bit, 16bit))
                div d           ; ((a - b) * c) / d ta sama historia co u góry ax to domyślny rejestr
                                ; w ax jest wynik.

                ;mov wynik, ax  ; ale można wprowadzić zmienną wynik jeżeli to konieczne


                mov     ah, 4ch   ; w ah ma być kod funkcji przerwania 21h (uniwersalnego)
                mov     al, 0     ; w al ma być kod wyjścia
                int     21h ; koniec programu
                            ; dlaczego to kończy program? int 21h to wykonanie przerwania czyli rozkaz do działania dla procesora.
                            ;21h to przerwanie uniwersalne i zupełnie jak instrukcja przyjmuje rejestr domyślny którym jest ah i al. 
                            ; w ah znajduje się numer instrukcji którą chcemy wywołać ( te numery są określone poprzez system ms-dos )
                            ; w al znajduje się kod wyjścia(exit code) więc jeżeli oczekujemy że program się poprawnie wykonał dajemy tu 0.

END Start      ; aby poprawnie zakończyć program po prostu zamykamy najbardziej zewnętrzną etykietę.

