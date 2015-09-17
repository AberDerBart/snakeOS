all: snakeos.img snake

snakeos: snake loader
	cat loader snake > snakeos
snake: snake.asm
	nasm snake.asm
loader: loader.asm
	nasm loader.asm
snakeos.img: snakeos
	floppymaker snakeos snakeos.img
clean:
	rm -f snakeos
	rm -f snakeos.img
	rm -f loader
	rm -f snake
	rm -f os
