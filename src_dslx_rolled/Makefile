GITROOT=$(shell git rev-parse --show-toplevel)
CLOCK_TARGET_PS ?= 1000 # 1 GHz clock rate
GENERATOR_TYPE ?= pipeline
DELAY_MODEL ?= unit

NAME=donut_inner
SRCS=donut_rolled.x
ENTRY=__donut_rolled__donut_inner
DSLX=1

include ${GITROOT}/common.mk
