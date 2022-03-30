.globl _start

.section .bss
  buffer: .space   8
  bufferCap = . - buffer
  bufferLen: .space   8

.section .data
  winnerText: .ascii " has won!\n"
  winnerTextLen = . - winnerText
  tieText: .ascii "It is a tie!\n"
  tieTextLen = . - tieText
  board: .ascii "_________"
  player: .ascii "x"

.section .text
  _start:
  movq $board, %r15
  movq $player, %r14
  call draw_board
  call ask_for_move

  cmpq $9, %rax # if user entered invalid input
  je _start

  movq $board, %rdi # if user tries to place on a non empty field
  cmpb $'_', (%rdi, %rax, 1)
  jne _start

  movq $board, %rdi # place a cross or naught in the chosen cell
  movb (player), %cl
  movb %cl, (%rdi, %rax, 1)

  call check_win_condition # rax = 'n': no winner yet, 'y': winner 't': tie
  cmpb $'n', %al
  jne game_over

  cmpb $'x', (player) # switch the curent player
  je switch_to_o

  switch_to_x:
  movb $'x', (player)
  jmp _start

  switch_to_o:
  movb $'o', (player)
  jmp _start

  game_over:
  pushq %rax
  movq $board, %r15
  movq $player, %r14
  call draw_board
  popq %rax

  cmpb $'t', %al
  jne game_over_winner

  game_over_tie:
  # print tie message
  movq $1, %rax # sys_write
  movq $1, %rdi # fd
  movq $tieTextLen, %rdx # len
  movq $tieText, %rsi # buffer
  syscall # %rax = number of bytes written or -1 on error
  jmp game_over_end

  game_over_winner:
  # printer winning player
  movq $1, %rax # sys_write
  movq $1, %rdi # fd
  movq $1, %rdx # len
  movq $player, %rsi # buffer
  syscall # %rax = number of bytes written or -1 on error

  # print winner message
  movq $1, %rax # sys_write
  movq $1, %rdi # fd
  movq $winnerTextLen, %rdx # len
  movq $winnerText, %rsi # buffer
  syscall # %rax = number of bytes written or -1 on error

  game_over_end:
  movq $60, %rax # sys_exit
  movq $0, %rdi # exit code
  syscall
  
  check_win_condition:
  movb (player), %al
  # Row 1
  cmpb %al, (board)
  jne 0f
  cmpb %al, (board+1)
  jne 0f
  cmpb %al, (board+2)
  jne 0f
  jmp win
  
  0:
  # Row 2
  cmpb %al, (board+3)
  jne 0f
  cmpb %al, (board+4)
  jne 0f
  cmpb %al, (board+5)
  jne 0f
  jmp win

  0:
  # Row 3
  cmpb %al, (board+6)
  jne 0f
  cmpb %al, (board+7)
  jne 0f
  cmpb %al, (board+8)
  jne 0f
  jmp win

  0:
  # Col 1
  cmpb %al, (board)
  jne 0f
  cmpb %al, (board+3)
  jne 0f
  cmpb %al, (board+6)
  jne 0f
  jmp win
  
  0:
  # Col 2
  cmpb %al, (board+1)
  jne 0f
  cmpb %al, (board+4)
  jne 0f
  cmpb %al, (board+7)
  jne 0f
  jmp win

  0:
  # Col 3
  cmpb %al, (board+2)
  jne 0f
  cmpb %al, (board+5)
  jne 0f
  cmpb %al, (board+8)
  jne 0f
  jmp win

  0:
  # \
  cmpb %al, (board)
  jne 0f
  cmpb %al, (board+4)
  jne 0f
  cmpb %al, (board+8)
  jne 0f
  jmp win

  0:
  # /
  cmpb %al, (board+2)
  jne 0f
  cmpb %al, (board+4)
  jne 0f
  cmpb %al, (board+6)
  jne 0f
  jmp win

  0:
  # check for a tie
  cmpb $'_', (board)
  je 0f
  cmpb $'_', (board+1)
  je 0f
  cmpb $'_', (board+2)
  je 0f
  cmpb $'_', (board+3)
  je 0f
  cmpb $'_', (board+4)
  je 0f
  cmpb $'_', (board+5)
  je 0f
  cmpb $'_', (board+6)
  je 0f
  cmpb $'_', (board+7)
  je 0f
  cmpb $'_', (board+8)
  je 0f
  # tie
  movb $'t', %al

  win:
  ret

  0: # no winner
  movb $'n', %al
  ret

