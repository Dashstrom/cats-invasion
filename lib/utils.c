/* Trové sur
 * https://www.geeksforgeeks.org/c-program-to-rotate-bits-of-a-number/
 * */

#include <stdint.h>
#include<stdio.h>
#define INT_BITS 32

/*Function to left rotate n by d bits*/
uint32_t leftRotate(uint32_t n, uint32_t d)
{
   /* In n<<d, last d bits are 0. To put first 3 bits of n at
     last, do bitwise or of n<<d with n >>(INT_BITS - d) */
   return (n << d)|(n >> (INT_BITS - d));
}

/*Function to right rotate n by d bits*/
uint32_t rightRotate(uint32_t n, uint32_t d)
{
   /* In n>>d, first d bits are 0. To put last 3 bits of at
     first, do bitwise or of n>>d with n <<(INT_BITS - d) */
   return (n >> d)|(n << (INT_BITS - d));
}
