XLS_HOME ?= ~/sw/xls
XLSCC=${XLS_HOME}/bazel-bin/xls/contrib/xlscc/xlscc
XLS_OPT_MAIN=${XLS_HOME}/bazel-bin/xls/tools/opt_main
XLS_CODEGEN_MAIN=${XLS_HOME}/bazel-bin/xls/tools/codegen_main
CLANG_HOME=/usr/include/clang/10.0.0/include

${NAME}: ${SRCS} ${HDRS}
	${CXX} ${CPPFLAGS} ${CXXFLAGS} ${SRCS} -o ${NAME}

run: ${NAME}
	./${NAME} ${EXEC_ARGS}

clang_args:
	echo '-D__SYNTHESIS__ \
-I${XLS_HOME} \
-I${CLANG_HOME}' > clang.args

${NAME}.ir: ${SRCS} ${HDRS} clang_args ${NAME}
	${XLSCC} --clang_args_file clang.args ${SRCS} > ${NAME}.ir

${NAME}_opt.ir: ${NAME}.ir
	${XLS_OPT_MAIN} ${NAME}.ir > ${NAME}_opt.ir

${NAME}_opt.v: ${NAME}_opt.ir
	${XLS_CODEGEN_MAIN} --clock_period_ps=${CLOCK_TARGET_PS} \
		--generator=${GENERATOR_TYPE} --delay_model=unit \
		${NAME}_opt.ir > ${NAME}_opt.v



clean:
	rm -f *.o ${NAME} clang.args *.ir
