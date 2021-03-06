XLS_HOME ?= ~/sw/xls
XLSCC=${XLS_HOME}/bazel-bin/xls/contrib/xlscc/xlscc
XLS_OPT_MAIN=${XLS_HOME}/bazel-bin/xls/tools/opt_main
XLS_CODEGEN_MAIN=${XLS_HOME}/bazel-bin/xls/tools/codegen_main
XLS_DSLX_INTERP=$(XLS_HOME)/bazel-bin/xls/dslx/interpreter_main
XLS_DSLX_IR_CONV=${XLS_HOME}/bazel-bin/xls/dslx/ir_converter_main
CLANG_HOME=/usr/include/clang/10.0.0/include

ifneq (${DSLX},1)
${NAME}: ${SRCS} ${HDRS}
	${CXX} ${CPPFLAGS} ${CXXFLAGS} ${SRCS} -o ${NAME}
else
${NAME}: ${SRCS} ${HDRS}
	${XLS_DSLX_INTERP} --compare_jit=false ${SRCS}
endif

ifneq (${DSLX},1)
run: ${NAME}
	./${NAME} ${EXEC_ARGS}
else
run: ${NAME}
endif

ENTRY ?= ${NAME}

clang_args:
	echo '-D__SYNTHESIS__ \
-I${XLS_HOME} \
-I${CLANG_HOME}' > clang.args

ifneq (${DSLX},1)
${NAME}.ir: clang_args ${NAME}
	${XLSCC} --clang_args_file clang.args --entry=${NAME} ${SRCS} > ${NAME}.ir
else
${NAME}.ir: ${NAME}
	${XLS_DSLX_IR_CONV} ${SRCS} --entry=${NAME} > ${NAME}.ir
endif

${NAME}_opt.ir: ${NAME}.ir
	${XLS_OPT_MAIN} ${NAME}.ir --entry=${ENTRY} > ${NAME}_opt.ir

${NAME}_opt.v: ${NAME}_opt.ir
	${XLS_CODEGEN_MAIN} --clock_period_ps=${CLOCK_TARGET_PS} \
		--generator=${GENERATOR_TYPE} --delay_model=unit \
		--use_system_verilog=false --entry=${ENTRY} \
		${NAME}_opt.ir > ${NAME}_opt.v

${NAME}_opt.synth_xilinx.v: ${NAME}_opt.v
	echo 'read_verilog -sv $<' > ${NAME}_synth_xilinx.ys \;
	echo 'synth_xilinx' >> ${NAME}_synth_xilinx.ys \;
	echo 'write_verilog $@' >> ${NAME}_synth_xilinx.ys \;
	yosys -s ${NAME}_synth_xilinx.ys -l ${NAME}_yosys_synth_xilinx.log

clean:
	rm -f *.o ${NAME} clang.args *.ir *.v
