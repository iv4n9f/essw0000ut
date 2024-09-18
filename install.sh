#!/bin/bash

echo "Installing dependencies..."

sudo apt-get install $packages -y
sudo chmod +x utils/*
sudo cp utils/* /usr/bin/