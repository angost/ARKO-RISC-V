	.eqv PRINT_INT, 1
	.eqv PRINT_STR, 4
	.eqv PRINT_CHAR, 11
	.eqv GET_INT, 5
	.eqv SYS_EXIT, 10
	.eqv OPEN_FILE, 1024
	.eqv CLOSE_FILE, 57
	.eqv READ_FILE, 63
	.eqv WRITE_FILE, 64
	.eqv SBRK, 9
	
	.globl	main
	
	.data
bmp_header: .space 20
headers_data: .space 56
fill_color: .space 4
start_color: .space 4
current_color: .space 4
start_pixel_coords: .space 2
current_pixel_coords: .space 2
neigh_instr: .space 16
empty_heap_addr: .space 4
current_heap_addr: .space 4
heap_offset:	.space 4
bmp_path: .asciz "domek.bmp"

begin_mess: .asciz "You will be asked to enter x and y coordinates of the pixel from which to start coloring. Let (0,0) be bottom left corner of the image and (x_max, y_max) top right corner.\n"
get_x_mess: .asciz "Enter x coord of pixel:\n"
get_y_mess: .asciz "Enter y coord of pixel:\n"
color_mess: .asciz "\nYou will be asked to enter R, G and B values of the color you want to use to fill the area. Each has to be between <0,255>\n"
input_mess: .asciz ": "
error_mess: .asciz "############ An ERROR occured ############\n"


	.text
main:	
	# OPENING FILE AND GETTING INFO FROM HEADERS

	li	t0, -1
	# Open a file for reading
	li	a7, OPEN_FILE
	la	a0, bmp_path
	li	a1, 0
	ecall
	beq	a0, t0, error
	mv	t6, a0		# t6 - file descriptor
	# Read 14 Bytes of BMP header and 4 Bytes of DIB header
	li	a7, READ_FILE
	la	a1, bmp_header
	li	a2, 18
	ecall
	mv	t5, a0
	# Close the file
	li	a7, CLOSE_FILE
	mv	a0, t6
	ecall
	beq	t5, t0, error
	# Check type of DIB header
	la	t1, bmp_header # t1 - wkaznik na adres
	addi	t1, t1, 14
	#lbu	t2, (t1)	# t2 - size of DIB header
	lhu	t2, (t1)	# t2 - size of DIB header
	li	t3, 40
	# Supporting only BITMAPINFOHEADER of size 40
	bne	t2, t3, error 
	
	
	# Open a file for reading
	li	a7, OPEN_FILE
	la	a0, bmp_path
	li	a1, 0
	ecall
	beq	a0, t0, error
	mv	t6, a0		# t6 - file descriptor
	# Read 14 Bytes of BMP header and 40 Bytes of DIB header
	li	a7, READ_FILE
	mv	a0, t6
	la	a1, headers_data
	li	a2, 54
	ecall
	mv	t5, a0
	# Close the file
	li	a7, CLOSE_FILE
	mv	a0, t6
	ecall
	beq	t5, t0, error
	
	# Info from headers is now stored in headers_data
	
	
	
get_input:
	# GETTING AND VALIDATING INPUT FROM USER - START PIXEL, COLOR TO FILL
	
	# Choose start pixel
	li	a7, PRINT_STR
	la	a0, begin_mess
	ecall
	# x coord
	li	a7, PRINT_STR
	la	a0, get_x_mess
	ecall
	li	a7, GET_INT
	ecall
	mv	t0, a0	# t0 - x
	# y coord
	li	a7, PRINT_STR
	la	a0, get_y_mess
	ecall
	li	a7, GET_INT
	ecall
	mv	t1, a0	#t1 - y
	# Validate coords
	# Validate x
	la	t2, headers_data # t2 - wkaznik na adres
	addi	t2, t2, 18	# address of bmp width in pixels
	lbu	t3, (t2)	# t3 - bmp width in pixels
	bltz	t0, error
	bgeu	t0, t3, error
	# Validate y
	addi	t2, t2, 4	# address of bmp height in pixels
	lbu	t3, (t2)	# t3 - bmp height in pixels
	bltz	t1, error
	bgeu	t1, t3, error
	# Save coords
	la	t2, start_pixel_coords
	sb	t0, (t2)
	sb	t1, 1(t2)
	
	# Display chosen pixel coords
	li	a7, PRINT_CHAR
	li	a0, '('
	ecall
	li	a7, PRINT_INT
	mv	a0, t0
	ecall
	li	a7, PRINT_CHAR
	li	a0, ','
	ecall
	li	a7, PRINT_INT
	mv	a0, t1
	ecall
	li	a7, PRINT_CHAR
	li	a0, ')'
	ecall
	
	# Choose fill color
	li	a7, PRINT_STR
	la	a0, color_mess
	ecall
	# R
	li	a7, PRINT_CHAR
	li	a0, 'R'
	ecall
	li	a7, PRINT_STR
	la	a0, input_mess
	ecall
	li	a7, GET_INT
	ecall
	mv	t2, a0	# t2 - value of R
	# G
	li	a7, PRINT_CHAR
	li	a0, 'G'
	ecall
	li	a7, PRINT_STR
	la	a0, input_mess
	ecall
	li	a7, GET_INT
	ecall
	mv	t3, a0	# t3 - value of G
	# B
	li	a7, PRINT_CHAR
	li	a0, 'B'
	ecall
	li	a7, PRINT_STR
	la	a0, input_mess
	ecall
	li	a7, GET_INT
	ecall
	mv	t4, a0	# t4 - value of B
	# Validate fill color
	li	t5, 255
	# Validate R
	bltz	t2, error
	bgtu 	t2, t5, error
	# Validate G
	bltz	t3, error
	bgtu 	t3, t5, error
	# Validate B
	bltz	t4, error
	bgtu 	t4, t5, error
	# Save fill color
	la	t0, fill_color
	sb	t2, (t0)
	sb	t3, 1(t0)
	sb	t4, 2(t0)
	
	# Display chosen color
	li	a7, PRINT_CHAR
	li	a0, '('
	ecall
	li	a7, PRINT_INT
	mv	a0, t2
	ecall
	li	a7, PRINT_CHAR
	li	a0, ','
	ecall
	li	a7, PRINT_INT
	mv	a0, t3
	ecall
	li	a7, PRINT_CHAR
	li	a0, ','
	ecall
	li	a7, PRINT_INT
	mv	a0, t4
	ecall
	li	a7, PRINT_CHAR
	li	a0, ')'
	ecall
	

allocate_memory:
	# ALLOCATE SPACE FOR WHOLE WHOLE BMP AND PIXEL TRACKER
	
	la	t0, headers_data # t0 - pointer to header
	addi	t0, t0, 2
	lhu	t1, (t0) 	# t1 - size of whole bmp
	
	# Dynamically allocating memory for the whole BMP
	li	a7, SBRK
	mv	a0, t1
	ecall
	mv	t2, a0		# t2 - Address of allocated block for whole BMP
	
	# Open a file for reading
	li	a7, OPEN_FILE
	la	a0, bmp_path
	li	a1, 0
	ecall
	beq	a0, t0, error
	mv	t6, a0		# t6 - file descriptor
	# Read whole BMP
	li	a7, READ_FILE
	mv	a0, t6
	mv	a1, t2
	mv	a2, t1
	ecall
	mv	t5, a0
	# Close the file
	li	a7, CLOSE_FILE
	mv	a0, t6
	ecall
	beq	t5, t0, error
	
	# Calculate nr of pixels in image
	addi	t0, t0, 16
	lbu	t3, (t0)	# t3 - width in pixels
	addi	t0, t0, 4
	lbu	t4, (t0)	# t4 - height in pixels
	mul	t3, t3, t4	# t3 - nr of pixels
	# Dynamically allocate space for pixel tracker
	li	a7, SBRK
	mv	a0, t3
	ecall
	mv	t3, a0		# t3 - Address of allocated block for pixel tracker

set_empty_heap_pointer:
	# Address indicating empty heap
	li	a7, SBRK
	li	a0, 2
	ecall
	li	t0, 0
	sw	a0, empty_heap_addr, t0
	
start_pixel:
	la	t0, start_pixel_coords
	lbu	t5, (t0)
	lbu	t6, 1(t0)
	
	# ADD START PIXEL TO HEAP
	li	a7, SBRK
	li	a0, 2
	ecall
	mv	t0, a0		# t0 - Address of allocated block
	sb	t5, (t0)
	sb	t6, 1(t0)
	sw	a0, current_heap_addr, t0
	#li	t1, 2
	#sw	t1, heap_offset, t0
	
	
	#ADDR OF START PIXEL
	# 1. calc nr in pixel tracker
	mv	t0, t2
	addi	t0, t0, 18
	lbu	t3, (t0)	# t3 - width in pixels
	# Pixel nr (in pixel tracker) = y*width + x
	mul	t4, t6, t3
	add	t4, t4, t5	# t4 - pixel nr (in pixel tracker)
	# 2. calc address
	mv	t0, t2
	addi	t0, t0, 10
	lbu	t1, (t0) 	# t1 - offset
	add	t0, t2, t1	# t0 - pointer to image data = start+offset
	li	t1, 3
	mul	t1, t4, t1	# t1 - offset of chosen pixel data from start of image data
	
	# CHECK FOR PADDING
	li	t4, 4
	remu	t4, t3, t4	# t0 - remainder from width/4
	mul	t4, t4, t6	# Padding = adding N zero bytes at the end of every row; 
				#N=width%4; How many we should add? y*N (+N bajtow w kazdym rzedzie, rzedow od poczatku jest y)
	add	t1, t1, t4
	
	add	t0, t0, t1	# t0 - start of chosen pixel data
	# t0 - pixel addr
	
	#COLOR OF START PIXEL
	la	t1, start_color
	lbu	t5, (t0) #B
	sb	t5, 2(t1)
	lbu	t5, 1(t0) #G
	sb	t5, 1(t1)
	lbu	t5, 2(t0) #R
	sb	t5, (t1)
	
	


set_up_neighbour_instructions:
	la	t0, neigh_instr
	li	t1, 0
	li	t3, 1
	sb	t1, (t0)
	sb	t3, 1(t0)
	li	t1, 1
	li	t3, 1
	sb	t1, 2(t0)
	sb	t3, 3(t0)
	li	t1, 1
	li	t3, 0
	sb	t1, 4(t0)
	sb	t3, 5(t0)
	li	t1, 1
	li	t3, -1
	sb	t1, 6(t0)
	sb	t3, 7(t0)
	li	t1, 0
	li	t3, -1
	sb	t1, 8(t0)
	sb	t3, 9(t0)
	li	t1, -1
	li	t3, -1
	sb	t1, 10(t0)
	sb	t3, 11(t0)
	li	t1, -1
	li	t3, 0
	sb	t1, 12(t0)
	sb	t3, 13(t0)
	li	t1, -1
	li	t3, 1
	sb	t1, 14(t0)
	sb	t3, 15(t0)
	

	
loop:
	# LOAD NEW PIXEL IF HEAP NOT EMPTY
	# Check if heap with pixels is empty
	#lw	t0, empty_heap_addr
	lw	t0, current_heap_addr
	lw	t1, empty_heap_addr
	beq	t0, t1, save_bmp
#find_next_pixel
	# Not empty -> get last (newest) pixel
	#lw	t1, empty_heap_addr
	#add	t1, t1, t0 # last = empty + offset
	lw	t1, current_heap_addr
	# Load cell content
	lbu	t5, (t1)
	lbu	t6, 1(t1)
	
	li	a7, PRINT_INT
	mv	a0, t5
	ecall
	mv	a0, t6
	ecall
	
	li	t3, 255
	bne	t5, t3, not_checked_pixel
	bne	t6, t3, not_checked_pixel
	#checked pixel
	#addi	t0, t0, -2
	#sw	t0, heap_offset, t3
	addi	t1, t1, -4
	sw	t1, current_heap_addr, t5
	b	loop
	
not_checked_pixel:
	#sw	t1, current_heap_addr, t0
	# t1 - newest pixel/empty heap
	
	lb	t5, (t1)
	lb	t6, 1(t1)
	# Save base coordinates
	la	t0, current_pixel_coords
	sb	t5, (t0)
	sb	t6, 1(t0)


calc_pixel_addr:
	# CHANGES X,Y COORDINATES TO PIXEL ADDRESS IN BMP
	# t2 - Address of allocated block for whole BMP
	# t5 - x
	# t6 - y
	# 1. calc nr in pixel tracker
	mv	t0, t2
	addi	t0, t0, 18
	lbu	t3, (t0)	# t3 - width in pixels
	
	# Pixel nr (in pixel tracker) = y*width + x
	mul	t4, t6, t3
	add	t4, t4, t5	# t4 - pixel nr (in pixel tracker)
	
	# 2. calc address
	mv	t0, t2
	addi	t0, t0, 10
	lbu	t1, (t0) 	# t1 - offset
	add	t0, t2, t1	# t0 - pointer to image data = start+offset
	li	t1, 3
	mul	t1, t4, t1	# t1 - offset of chosen pixel data from start of image data
	
	# CHECK FOR PADDING
	li	t4, 4
	remu	t4, t3, t4	# t0 - remainder from width/4
	mul	t4, t4, t6	# Padding = adding N zero bytes at the end of every row; 
				#N=width%4; How many we should add? y*N (+N bajtow w kazdym rzedzie, rzedow od poczatku jest y)
	add	t1, t1, t4
	
	add	t0, t0, t1	# t0 - start of chosen pixel data

remove_from_heap:
	# Releasing memory (coords of current pixel)
	#li	a7, SBRK
	#li	a0, -2
	#ecall
	# Setting cell to ff value; decreasing offset
	lw	t1, current_heap_addr
	li	t3, 255
	# w t1 adres -> chce modyfikowac cos pod tym adresem
	sb	t3, (t1)
	sb	t3, 1(t1)
	
	#la	t3, heap_offset
	#lw	t1, (t3)
	#addi	t1, t1, -2
	#sw	t1, heap_offset, t3
	
	
compare_colors:
	# t0 - chosen pixel address
	# t1 - R/G/B
	# t3 - start_color addr
	# t4 - start R/G/B
	# t5 - x
	# t6 - y
	la	t3, start_color
	
	lbu	t1, 2(t0) #R
	lbu	t4, (t3)
	bne	t1, t4, loop
	lbu	t1, 1(t0) #G
	lbu	t4, 1(t3)
	bne	t1, t4, loop
	lbu	t1, (t0) #B
	lbu	t4, 2(t3)
	bne	t1, t4, loop
	# equal
	
change_pixel_color:
	# t0 - chosen pixel address
	# t3 - fill_color addr
	# t4 - fill R/G/B
	# t5 - x
	# t6 - y
	la	t3, fill_color
	
	lbu	t4, (t3) #R
	sb	t4, 2(t0)
	lbu	t4, 1(t3) #G
	sb	t4, 1(t0)
	lbu	t4, 2(t3) #B
	sb	t4, (t0)
	
adding_neighbours:
	# t2 - Address of allocated block for whole BMP
	# t5 - x_base
	# t6 - y_base
	li	t1, -2
	
potential_neighbour:
	addi	t1, t1, 2
	li	t5, 16
	beq	t1, t5, loop
	
	# Set coords back to base
	la	t0, current_pixel_coords
	lb	t5, (t0)
	lb	t6, 1(t0)
	
	la	t0, neigh_instr
	add	t0, t0, t1
	# Validete x
	lb	t3, (t0) # instr for x
	add	t5, t5, t3 # new_x
	bltz	t5, potential_neighbour
	lbu	t4, 18(t2)	# t4 - bmp width in pixels
	bgeu	t5, t4, potential_neighbour
	addi	t0, t0, 1
	# Validate y
	lb	t3, (t0) # instr for y
	add	t6, t6, t3 # new_y
	bltz	t6, potential_neighbour
	lbu	t4, 22(t2)	# t4 - bmp height in pixels
	bgeu	t6, t4, potential_neighbour
	# neighbour exists
	
add_neighbour:
	# Dynamically allocate space
	li	a7, SBRK
	li	a0, 2
	ecall
	mv	t0, a0		# t0 - Address of allocated block
	sb	t5, (t0)
	sb	t6, 1(t0)
	
	#la	t6, heap_offset
	#lw	t5, (t6)
	#addi	t5, t5, 2
	#sw	t5, heap_offset, t6
	sw	t0, current_heap_addr, t6
	
	b	potential_neighbour
	

save_bmp:
	# t2 - Address of allocated block for whole BMP
	
	li	t0, -1
	# Open a file for writing
	li	a7, OPEN_FILE
	la	a0, bmp_path
	li	a1, 1
	ecall
	beq	a0, t0, error
	mv	t6, a0		# t6 - file descriptor
	# Write updated BMP
	mv	t1, t2
	addi	t1, t1, 2
	lhu	t3, (t1)	# t3 - size of whole BMP
	
	li	a7, WRITE_FILE
	mv	a1, t2
	mv	a2, t3
	ecall
	mv	t5, a0
	# Close the file
	li	a7, CLOSE_FILE
	mv	a0, t6
	ecall
	beq	t5, t0, error
	b	fin
	
error:
	li	a7, PRINT_STR
	la	a0, error_mess
	ecall
fin:
	li	a7, 10
	ecall
