INCLUDE     Irvine32.inc

.data

tamanhoX  BYTE 15   ; coluna
tamanhoY  BYTE 9    ; linha

playerX	BYTE ?
playerY	BYTE ?

tempX     BYTE ?
tempY     BYTE ?

bombas    BYTE ?

flagWin   BYTE 0
flagVolta BYTE 0

msgBombas BYTE "Bombas: ",0

gameNome  BYTE "   ", 149, " Bombermaze ", 162, 0

menuVal   BYTE 1
msgMenu1  BYTE 0Ah, 0Ah, 09h, 2Ah, "Iniciar Jogo", 0Dh, 0Ah, 09h, " Instrucoes", 0Dh, 0Ah, 09h, " Sair", 0Dh, 0Ah, 0Ah, 0
msgMenu2  BYTE 0Ah, 0Ah, 09h, " Iniciar Jogo", 0Dh, 0Ah, 09h, 2Ah, "Instrucoes", 0Dh, 0Ah, 09h, " Sair", 0Dh, 0Ah, 0Ah, 0
msgMenu3  BYTE 0Ah, 0Ah, 09h, " Iniciar Jogo", 0Dh, 0Ah, 09h, " Instrucoes", 0Dh, 0Ah, 09h, 2Ah, "Sair", 0Dh, 0Ah, 0Ah, 0
msgMenu4  BYTE "   [W] = up  [S] = down  [ENTER] = seleciona", 0Dh, 0Ah, 0Ah, 0

msgRegras      BYTE 0Ah, 0Ah, 09h, "Voce controla o personagem principal (", 43, ")", 0Ah, 09h, "Seu objetivo eh escapar do labirinto e chegar ate a saida (", 186, ")", 0
msgRegras2     BYTE 0Ah, 0Ah, 09h, "Voce nao podera atravessar nenhum tipo de terreno (", 219, ", ", 177, ")", 0Ah, 09h, "Mas podera destruir as paredes destrutiveis (", 177, ")", 0
msgRegras3     BYTE 0Ah, 0Ah, 09h, "Para destruir basta usar suas bombas usando [SPACE]", 0Ah, 09h, "Suas bombas sao limitadas mas voce podera encontrar mais delas no chao (", 162, ")", 0
msgRegras4     BYTE 0Ah, 0Ah, "   [BACKSPACE] = volta", 0Dh, 0Ah, 0Ah, 0

msgWin    BYTE 0Ah, 0Ah, 09h, "Parabens voce conseguiu escapar do labirinto!", 0
msgWin2   BYTE 0Ah, 0Ah, "   [pressione qualquer botao para voltar]", 0Dh, 0Ah, 0Ah, 0

msgControles   BYTE 0Ah, 0Ah, "   [WASD] = movimentacao  [SPACE] = usa bomba  [BACKSPACE] = volta ao menu principal", 0Dh, 0Ah, 0Ah, 0



MAP BYTE 135 DUP(?) ; tamanhoX * tamanhoY

linha1    BYTE 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219
linha2    BYTE 219, ' ', ' ', 177, 219, 162, 219, ' ', ' ', ' ', 177, ' ', ' ', ' ', 219
linha3    BYTE 219, ' ', ' ', 177, ' ', ' ', 219, ' ', ' ', ' ', 177, 219, 219, ' ', 219
linha4    BYTE 219, 177, 177, 177, 219, 219, 219, ' ', ' ', ' ', 177, ' ', 219, ' ', 219
linha5    BYTE 219, ' ', ' ', 219, 219, 219, 219, ' ', 219, 177, 219, 177, 219, ' ', 219
linha6    BYTE 219, ' ', ' ', 177, ' ', ' ', ' ', ' ', 219, 162, 219, 177, 219, ' ', 219
linha7    BYTE 219, ' ', ' ', 177, 219, 219, 219, 219, 219, 219, 219, ' ', 219, 177, 219
linha8    BYTE 219, ' ', ' ', 177, 177, 177, ' ', 162, 162, 219, 219, ' ', 177, 186, 219
linha9    BYTE 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219

; 219 = #
; 177 = X
; 162 = B
; 186 = S
;  43 = P

.code
main PROC
topo:
     call clrscr
     call menuInicial

     mov al, menuVal
     cmp al, 2
     JB comeca
     JE regras
     JA fim
jmp topo

regras:
     call menuRegras
jmp topo

comeca:
     call IniciaJogo
jmp topo


fim:
     call clrscr

exit
main ENDP



; FUNCOES


; IMPRIME MENU 'Instrucoes'
menuRegras PROC USES EDX EAX
call clrscr
mov dx, 0
call gotoxy
     mov edx, OFFSET msgRegras
     call writestring
     mov edx, OFFSET msgRegras2
     call writestring
     mov edx, OFFSET msgRegras3
     call writestring
     mov edx, OFFSET msgRegras4
     call writestring

     tenta:
     call readchar
     cmp al, 8; 'BACKSPACE'
     JE volta
     jmp tenta

     volta:
     call clrscr
          ret

menuRegras ENDP


; IMPRIME E ATUALIZA O MENU PRINCIPAL
menuInicial PROC USES EBX EAX EDX
     topo:
     mov dx, 0
     call gotoxy

     mov edx, OFFSET gameNome
     call writestring

     mov bl, menuVal
     cmp bl, 2
     JB menu1
     JE menu2
     JA menu3

     menu1:
     mov menuVal, 1
     mov edx, OFFSET msgMenu1
     jmp fim

     menu2 :
     mov edx, OFFSET msgMenu2
     jmp fim

     menu3 :
     mov menuVal, 3
     mov edx, OFFSET msgMenu3
     jmp fim


     fim :
     call writestring
     mov edx, OFFSET msgMenu4
     call writestring
     call readchar

     cmp al, 'w'
     JE sobe
     cmp al, 's'
     JE desce
     cmp al, 13; 'ENTER'
     JE entrou

     jmp topo

     sobe :
     dec menuVal
     jmp topo
     desce :
     inc menuVal
     jmp topo

     jmp topo

entrou :
     ret
menuInicial ENDP


; CARREGA O MAPA E INICIALIZA FLAGS, BOMBAS E POSICAO INICIAL DO JOGADOR
loadMAP PROC USES ESI EDX ECX EAX
     mov esi, 0
     mov edx, OFFSET linha1
     mov ecx, SIZEOF MAP
     carregaMapa :
          mov al, [edx]
          mov MAP[esi + 1], al
          inc esi
          inc edx
     loop carregaMapa

; INICIALIZANDO
     mov flagWin, 0
     mov flagVolta, 0
     mov playerX, 2
     mov playerY, 2
     mov bombas, 3
     ret
loadMAP ENDP


; FUNCAO EXPLODIR BOMBA
Explode PROC USES EDX EAX
     mov al, bombas
     cmp al, 0
     JNA fim

     dec bombas

     mov dl, playerX
     mov tempX, dl
     
     mov dl, playerY
     mov tempY, dl

     inc playerX
     call ApagaJogador
     dec playerX
     dec playerX
     call ApagaJogador
     inc playerX

     inc playerY
     call ApagaJogador
     dec playerY
     dec playerY
     call ApagaJogador
     
     mov dl, tempX
     mov playerX, dl
     mov dl, tempY
     mov playerY, dl
     fim:
     ret
Explode ENDP


; FUNCAO QUE FAZ LEITURA DO TECLADO E MOVIMENTA O JOGADOR, TESTA COLISAO, USA BOMBA, PEGA BOMBA, ATUALIZA FLAGS DE VITORIA E VOLTA PRO MENU PRINCIPAL
Anda PROC USES EDX EAX EBX
     mov dl, playerX
     mov tempX, dl

     mov dl, playerY
     mov tempY, dl

     call ReadChar

     comparaA:
          cmp al, 61h; 'a'
          JNE comparaD
          dec tempX; x - 1 (<-)
          jmp colisao

     comparaD:
          cmp al, 64h; 'd'
          JNE comparaS
          inc tempX; x + 1 (->)
          jmp colisao

     comparaS:
          cmp al, 73h; 's'
          JNE comparaW
          inc tempY; y + 1 (sul)
          jmp colisao

     comparaW:
          cmp al, 77h; 'w'
          JNE comparaSPACE
          dec tempY; y - 1 (norte)
          jmp colisao

     comparaSPACE:
          cmp al, 20h; 'SPACE'
          JNE comparaVolta
          call Explode
          jmp fim

     comparaVolta:
          cmp al, 8; 'BACKSPACE'
          JNE fim
          mov flagVolta, 1
          jmp fim


; testa colisao da nova posicao do jogador
     colisao:
          movzx ebx, tempY
          dec ebx
          movzx eax, tamanhoX
          mul ebx
          movzx ebx, tempX
          add eax, ebx
          mov al, MAP[eax]

          cmp al, 177; 'parede'
          JE fim
          cmp al, 219; 'indestrutivel'
          JE fim
          cmp al, 186; 'saida'
          JE win
          cmp al, 162; 'bomba'
          JE Bomba
          jmp andou

          Bomba:
               inc bombas
               jmp andou
          win:
               inc flagWin
               jmp andou
          
; se nao houve colisao, playerX e playerY sera atualizado
     andou:
          call ApagaJogador
          mov dl, tempX
          mov playerX, dl

          mov dl, tempY
          mov playerY, dl

          fim:

     ret
Anda ENDP


; PREENCHE TODAS AS CELULAS COM ALGO (usado apenas na etapa de testes)
Preenche PROC USES ECX
     mov ecx, SIZEOF MAP
     l1:
          mov MAP[ecx], '-'
     loop l1

     ret
Preenche ENDP


; ATUALIZA NOVA POSICAO DO JOGADOR         (coluna + ((linha - 1) * 9)
AtualizaJogador PROC USES EAX EBX
     movzx ebx, PlayerY
     dec ebx
     movzx eax, tamanhoX
     mul ebx
     movzx ebx, PlayerX
     add eax, ebx
     mov MAP[eax], 43; '+'
          
     ret
AtualizaJogador ENDP


; APAGA O CONTEUDO DE [X,Y] NO MAPA
ApagaJogador PROC USES EAX EBX
     movzx ebx, PlayerY
     dec ebx
     movzx eax, tamanhoX
     mul ebx
     movzx ebx, PlayerX
     add eax, ebx
     mov ebx, eax

     movzx eax, MAP[ebx]
     cmp al, 219; 'indestrutivel'
     JE fim
     cmp al, 186; 'saida'
     JE fim

     mov MAP[ebx], ' '
     jmp fim

     fim:
     ret
ApagaJogador ENDP


; DESENHA TELA DE JOGO
Desenha PROC USES ECX ESI EDX EAX
     mov esi, OFFSET MAP
     movzx ecx, tamanhoY
     l4:
          mov edx, ecx
          movzx ecx, tamanhoX

          l5:
               mov al, [esi + 1]
               call writechar
               inc esi
          loop l5

          mov ecx, edx
          call crlf
     loop l4

     call crlf
     call crlf
     mov edx, OFFSET msgBombas
     call writestring
     mov al, bombas
     add al, 48
     call writechar
     call crlf
     mov edx, OFFSET msgControles
     call writestring

     ret
Desenha ENDP


; LACO PRINCIPAL QUE RODA O JOGO
IniciaJogo PROC USES ECX EAX
     call loadMAP
     call clrscr
     call AtualizaJogador
     call Desenha

     mov ecx, 1
     teste:
          call Anda
          call AtualizaJogador
          mov dx, 0
          call gotoxy
          call Desenha

          mov al, flagWin
          cmp al, 1
          JE venceu
          
          mov al, flagVolta
          cmp al, 1
          JE fim
          jmp ante

          venceu:
               mov ecx, 1
               jmp fim
          
          ante:
               inc ecx


          fim:
         
     loop teste

          mov al, flagWin
          cmp al, 1
          JE telaWin
          jmp finao

          telaWin:
               call clrscr
               mov edx, OFFSET msgWin
               call writestring
               mov edx, OFFSET msgWin2
               call writestring
               call readchar
               call clrscr

               finao:

     ret
IniciaJogo ENDP


END main
