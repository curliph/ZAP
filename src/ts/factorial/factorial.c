/* Computes factorial and stores 3.14 in 2004 memory location. */

void main (void)
{
        char *x = (char *)2000;
        float *y = (float*) 2004;
        x[0] = 5;
        x[1] = fact(x[0]);    
        *y = 3.14;           
}

int fact (int x)
{
        if ( x == 0 )
                return 1;
        else
                return x * fact(x-1);
}

////////////////// VECTORS /////////////////////////

void __undef(void) {
        return;
} 

void __swi (void) {
        return;
}

void __pabt (void) {
        return;
}

void __dabt (void) {
        return;
}

void __irq (void) {
        return;
}

void __fiq (void) {
        return;
}
