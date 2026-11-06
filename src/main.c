
#include <stdint.h>

/* STM32F407 Register Addresses */

#define RCC_AHB1ENR  (*(volatile uint32_t*)0x40023830)

#define GPIOD_MODER  (*(volatile uint32_t*)0x40020C00)

#define GPIOD_ODR    (*(volatile uint32_t*)0x40020C14)

#define LED_PIN     (12U)

/* Forward declaration */
void Reset_Handler(void);

int main(void)
{
    /* 1. Enable clock for GPIO Port D */
    RCC_AHB1ENR |= (1U << 3);

    /* 2. Configure PD12 as output */
    GPIOD_MODER &= ~(3U << (LED_PIN * 2));
    GPIOD_MODER |=  (1U << (LED_PIN * 2));

    while (1)
    {
        /* 3. Turn LED ON */
        GPIOD_ODR |= (1U << LED_PIN);

        /* 4. Delay */
        for (volatile uint32_t i = 0; i < 1000000; i++);

        /* 5. Turn LED OFF */
        GPIOD_ODR &= ~(1U << LED_PIN);

        /* 6. Delay */
        for (volatile uint32_t i = 0; i < 1000000; i++);
    }
}

/* Cortex-M startup handler */
void Reset_Handler(void)
{
    main();

    while (1);
}

/* Vector table */
__attribute__((section(".isr_vector")))
const uintptr_t vector_table[] =
{
    0x20020000,                 /* Initial stack pointer */
    (uintptr_t)Reset_Handler    /* Reset handler */
};
