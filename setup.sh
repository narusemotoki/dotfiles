#!/bin/bash

cd `dirname $0`

ln -s `pwd`/.byobu ~/.
ln -s `pwd`/.gitconfig ~/.
ln -s `pwd`/.mozc ~/.
ln -s `pwd`/.zshrc ~/.
ln -s `pwd`/.Xmodmap ~/.
ln -s `pwd`/.profile ~/.

cd
