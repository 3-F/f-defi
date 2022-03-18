#!/bin/sh
git pull
hugo
rm -rf ~/f/home/defi
mv public/ ~/f/home/defi
