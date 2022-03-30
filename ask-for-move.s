.weak ask_for_move

.section .bss
  buffer: .space 1
  bufferLen = . - buffer

.section .data
  prompt: .ascii "Enter your move (1-9): "
  promptLen = . - prompt
  newline: .ascii "\n"

.section .text
  # in r15 = board: u64*
  # var r14d
  # out rax = move(0-9): u64, 9 = invalid choice
  ask_for_move:
    call write_prompt # ask the user to enter a move
    call read_byte

    cmpb $'1', %r14b # if we are not in range 1-9, we ask the user again
    jl invalid_value
    cmpb $'9', %r14b
    jg invalid_value

    sub $'1', %r14b # convert from ascii to int
    xorq %rax, %rax # move to rax our return register
    movb %r14b, %al
    ret

    invalid_value:
    movq $9, %rax
    ret

  write_prompt:
    movq $1, %rax # sys_write
    movq $1, %rdi # fd
    movq $promptLen, %rdx # len
    movq $prompt, %rsi # buffer
    syscall # %rax = number of bytes written or -1 on error
    ret

  # reads a single byte and discards everything else until a newline is read
  # out r14b = byte: u8
  read_byte:
    movq $0, %rax # sys_read
    movq $0, %rdi # fd
    movq $buffer, %rsi # buffer
    movq $1, %rdx # len
    syscall # %rax = number of bytes read or -1 on error
    movb (buffer), %r14b # save the first byte of the user input for returning

    read_byte_discard_remainder_loop: # discard user input until newline
    cmpb $'\n', (buffer)
    je read_byte_return
    movq $0, %rax # sys_read
    movq $0, %rdi # fd
    movq $buffer, %rsi # buffer
    movq $1, %rdx # len
    syscall # %rax = number of bytes read or -1 on error
    jmp read_byte_discard_remainder_loop
  
    read_byte_return:
    ret
