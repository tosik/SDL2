#!/bin/bash

set -x
set -e
cd `dirname "$0"`

generate_shaders()
{
    platform=$1
    xcrun -sdk macosx metal -c ./SDL_shaders_metal.metal -o sdl.air
    xcrun -sdk macosx metallib sdl.air -o sdl.metallib
    xxd -i sdl.metallib | perl -w -p -e 's/\Aunsigned /const unsigned /;' >./SDL_shaders_metal_$platform.h
    rm -f sdl.air sdl.metalar sdl.metallib
}

generate_shaders osx
generate_shaders ios
