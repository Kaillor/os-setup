#!/bin/bash

info() {
  message="$1"
  __printLog "\e[34mINFO\e[0m" "$message"
}

warning() {
  message="$1"
  __printLog "\e[33mWARNING\e[0m" "$message"
}

error() {
  message="$1"
  __printLog "\e[31mERROR\e[0m" "$message"
}

__printLog() {
  level="$1"
  message="$2"
  printf "[%s] [%b] %s\n" "$(date '+%Y-%m-%d %H:%M:%S.%3N')" "$level" "$message"
}
