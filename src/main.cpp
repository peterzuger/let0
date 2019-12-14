/**
 * @file   let0/src/main.cpp
 * @author Peter Züger
 * @date   22.04.2018
 * @brief  let0 empty main
 *
 * This file is part of let0 (https://gitlab.com/peterzuger/let0).
 * Copyright (c) 2019 Peter Züger.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
#include <RCC/GPIO.hpp>
#include <RCC/USART.hpp>
#include <GPIO.hpp>
#include <SysTick.hpp>
#include <USART.hpp>

#include "handlers.hpp"

int main(){
    {
        using namespace let::STK;
        SetSysTickLoad(1000);
        ClearSysTickCurrent();
        EnableSysTickCounter();
        EnableSysTickException();
    }
    {
        using namespace let::RCC;
        EnableGPIOAClock();
        EnableGPIOCClock();
        EnableUSART2Clock();
    }

    using namespace let::GPIO;
    Pin<GPIOA, 5> led{Mode::Output};
    Pin<GPIOC, 13> button{Mode::Input};

    AlternateFunction<GPIOA, 2>(7); // TX
    AlternateFunction<GPIOA, 3>(7); // RX
    let::USART::USART<let::USART::USART2> debug{230400};

    auto intervall = [](std::uint32_t time, auto fun){
                         while(true){
                             auto _j = jiffies + time;
                             while((_j > jiffies));
                             fun();
                         }
                     };

    intervall(500,
              [&led, &debug]{
                  led.toggle();
                  debug.write("Hello World\n\r");
              });
}
