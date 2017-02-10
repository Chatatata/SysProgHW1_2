//
//  Bugra Ekuklu, Babil Ovunc Diler
//  150120016, 150110803
//

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>

#ifdef BUFSIZ
#undef BUFSIZ
#define BUFSIZ 200
#endif

void generate_r(int **bin_buffer, int bin_buf_frame_width, int bin_buf_frame_height, int *rule_buffer, int **draw_buffer);

int main(int argc, const char * argv[]) {
    FILE *f_ptr = NULL;
    int bin_buffer[BUFSIZ][BUFSIZ];
    int draw_buffer[BUFSIZ][BUFSIZ];
    int rule_buffer[BUFSIZ];
    
    if (argc != 3) {
        printf("no file name specified%d\n", argc);
        exit(1);
    }
    
    if (!(f_ptr = fopen(argv[1], "r"))) {
        perror("file couldn't be opened");
        exit(9);
    }
    
    printf("Reading binary buffer from file...\n");
    
    int axis_cursor = 0;
    int axis = 0;
    int ordinate = 0;
    int eol_flag = 0;
    int nl_flag = 0;
    
    while (!feof(f_ptr)) {
        char ch = getc(f_ptr);

        if (ch == '\n' && nl_flag == 0) {
            nl_flag = 1;
            continue;
        }

        if (nl_flag == 0) continue;
        
        if (axis == BUFSIZ || ordinate == BUFSIZ) {
            perror("file too long");
            exit(1);
        }
        
        switch (ch) {
            case '\n':
            case '\t':
                //  Set axis if not set
                if (axis == 0) {
                    axis = axis_cursor;
                }
                
                //  Initialize axis cursor
                axis_cursor = 0;
                
                //  Increment ordinate by 1
                ordinate += 1;
                
                //  Raise EOL flag
                eol_flag = 1;
                break;
                
            case EOF:
                //  Decrement ordinate by 1 if EOL flag is set
                if (eol_flag == 1) {
                    ordinate -= 1;
                }
                
                goto first_bailout;
                
            case ' ':
                continue;
                
            case '0':
            case '1':
                //  Mark the point in the matrix
                bin_buffer[ordinate][axis_cursor] = atoi(&ch);
                
                //  Forward axis cursor
                axis_cursor += 1;
                
                //  Flush EOL flag
                eol_flag = 0;
                break;
                
            default:
                perror("unexpected input sequence");
                exit(1);
        }
    }
    
first_bailout:
    //  Release the file handle
    fclose(f_ptr);
    
    if (!(f_ptr = fopen(argv[2], "r"))) {
        perror("file couldn't be opened");
        exit(9);
    }

    printf("Input matrix: \n");
    
    for (size_t a = 0; a < ordinate; ++a) {
        for (size_t b = 0; b < axis; ++b) {
            printf("%d", bin_buffer[a][b]);
        }
        
        printf("\n");
    }

    printf("\n");
    
    printf("Reading rule buffer from file...\n");
    
    int index = 0;
    
    while (!feof(f_ptr)) {
        if (index > 32) {
            perror("rule buffer too long");
            exit(1);
        }
        
        char ch = getc(f_ptr);
        
        if (axis == BUFSIZ || ordinate == BUFSIZ) {
            perror("file too long");
            exit(1);
        }
        
        switch (ch) {
            case '\n':
            case '\t':
            case EOF:
                
                goto last_bailout;
            case ' ':
                continue;
                
            case '0':
            case '1':
                //  Mark the point in the matrix
                rule_buffer[index] = atoi(&ch);
                
                //  Forward index
                index += 1;
                break;
                
            default:
                perror("unexpected input sequence");
                exit(1);
        }
    }
last_bailout:
    //  Release the file handle
    fclose(f_ptr);

    printf("Rule buffer: ");
    
    for (size_t i = 0; i < index; ++i) {
        printf("%d", rule_buffer[i]);
    }

    printf("\n");

    printf("Binary buffer addr: %x\nAxis addr: %x\nOrdinate addr: %x\nRule buffer addr: %x\nDraw buffer addr: %x\n", &bin_buffer, &axis, &ordinate, &rule_buffer, &draw_buffer);
    
    printf("\n");

    printf("Press any key to generate a matrix or Ctrl-C to exit.\n");

    while (getc(stdin)) {
        printf("\n");

        generate_r((int **)bin_buffer, axis, ordinate, rule_buffer, (int **)draw_buffer);

        for (size_t a = 0; a < ordinate; ++a) {
            for (size_t b = 0; b < axis; ++b) {
                printf("%d", draw_buffer[a][b]);
            }

            memcpy(bin_buffer[a], draw_buffer[a], sizeof(int) * BUFSIZ);
            
            printf("\n");
        }
    }
    
    return 0;
}










