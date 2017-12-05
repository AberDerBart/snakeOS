snakeos.img: snake loader
	cat loader snake > snakeos.img
	truncate -s 1474560 snakeos.img
snake: snake.asm
	nasm snake.asm
loader: loader.asm
	nasm loader.asm
clean:
	rm -f snakeos.img
	rm -f loader
	rm -f snake
