#!/bin/bash

cd `dirname $0`

ln -s `pwd`/.byobu ~/.
ln -s `pwd`/.gitconfig ~/.
ln -s `pwd`/.mozc ~/.
ln -s `pwd`/.zshrc ~/.

cd
