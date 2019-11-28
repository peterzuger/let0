/**
 * @file   let0/include/handlers.hpp
 * @author Peter Züger
 * @date   08.05.2019
 * @brief  Interrupt handlers
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
#ifndef LET0_HANDLERS_HPP
#define LET0_HANDLERS_HPP

#include <cstdint>

extern volatile std::uint32_t jiffies;
extern volatile std::int32_t milliseconds;
extern volatile std::int32_t seconds;

#endif /* LET0_HANDLERS_HPP */
