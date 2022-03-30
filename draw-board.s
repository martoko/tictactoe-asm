.weak draw_board

.section .data
  clear: .ascii "\033[H\033[J"
  clearLen = . - clear
  empty: .ascii "_"
  x: .ascii "x"
  o: .ascii "o"
  newline: .ascii "\n"
  currentPlayerText1: .ascii "Current player is "
  currentPlayerText1Len = . - currentPlayerText1
  currentPlayerText2: .ascii ".\n"
  currentPlayerText2Len = . - currentPlayerText2

.section .text
  # r15 = board: u64*
  # r14 = player: u64*
  draw_board:
  # clear the screen
  movq $1, %rax # sys_write
  movq $1, %rdi # fd
  movq $clearLen, %rdx # len
  movq $clear, %rsi # len
  syscall # %rax = number of bytes written or -1 on error

  # Draw each cell
  movq %r15, %rsi # buffer
  call draw_char
  inc %r15
  movq %r15, %rsi # buffer
  call draw_char
  inc %r15
  movq %r15, %rsi # buffer
  call draw_char
  inc %r15
  movq $newline, %rsi # buffer
  call draw_char

  movq %r15, %rsi # buffer
  call draw_char
  inc %r15
  movq %r15, %rsi # buffer
  call draw_char
  inc %r15
  movq %r15, %rsi # buffer
  call draw_char
  inc %r15
  movq $newline, %rsi # buffer
  call draw_char

  movq %r15, %rsi # buffer
  call draw_char
  inc %r15
  movq %r15, %rsi # buffer
  call draw_char
  inc %r15
  movq %r15, %rsi # buffer
  call draw_char
  inc %r15
  movq $newline, %rsi # buffer
  call draw_char
  call draw_char

  call print_current_player

  ret

  # rsi = cell type: u8*
  draw_char:
    movq $1, %rax # sys_write
    movq $1, %rdi # fd
    movq $1, %rdx # len
    syscall # %rax = number of bytes written or -1 on error
    ret

  # r14 = player: u8*
  print_current_player:
    movq $1, %rax # sys_write
    movq $1, %rdi # fd
    movq $currentPlayerText1Len, %rdx # len
    movq $currentPlayerText1, %rsi # buffer
    syscall # %rax = number of bytes written or -1 on error

    movq $1, %rax # sys_write
    movq $1, %rdi # fd
    movq $1, %rdx # len
    movq %r14, %rsi # buffer
    syscall # %rax = number of bytes written or -1 on error

    movq $1, %rax # sys_write
    movq $1, %rdi # fd
    movq $currentPlayerText2Len, %rdx # len
    movq $currentPlayerText2, %rsi # buffer
    syscall # %rax = number of bytes written or -1 on error

    ret
