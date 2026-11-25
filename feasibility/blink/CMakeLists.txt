# SPDX-License-Identifier: Apache-2.0
# Feasibility prototype (throwaway): blink the on-board WS2812 RGB LED.

cmake_minimum_required(VERSION 3.20.0)

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
project(feasibility_blink)

target_sources(app PRIVATE src/main.cpp)
