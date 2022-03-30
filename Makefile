OBJECTS   := $(patsubst %.s,%.o,$(wildcard *.s))
ASFLAGS   += --64 --gen-debug

all: tictactoe

.PHONY: all clean

tictactoe: $(OBJECTS)
	ld -o $@ $^ $(LDFLAGS)

clean:
	rm -rf tictactoe $(OBJECTS)
