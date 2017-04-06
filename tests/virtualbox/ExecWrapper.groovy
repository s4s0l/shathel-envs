import org.slf4j.Logger

/**
 * @author Marcin Wielgus
 */
class ExecWrapper {
    final Logger LOGGER;
    final String command;
    final Map<String, String> environment;

    ExecWrapper(Logger LOGGER, String command, Map<String, String> environment = [:]) {
        this.LOGGER = LOGGER
        this.command = command
        this.environment = environment;
    }

    int executeForExitValue(File dir = new File("."), Map<String, String> env = [:], boolean logOutput = false, String args) {
        executeForExitValue(dir, env, logOutput, args.split('\\s+'))
    }

    int executeForExitValue(File dir = new File("."), Map<String, String> env = [:], boolean logOutput = false, String... args) {
        StringBuilder sb = new StringBuilder()
        List<?> flatten = fix(args)
        LOGGER.debug("Running ${flatten.join(",")}")
        Process process = createProcess(flatten, dir, env)
        process.inputStream.eachLine {
            LOGGER.debug("output:  [$it]")
            sb.append(it).append("\n")
        }
        process.waitFor();
        if (process.exitValue() != 0 && logOutput) {
            LOGGER.error("Command [${flatten.join(",")}] failed with output:\n" + sb.toString().trim())
            throw new ExecWrapperException("[${flatten.join(",")}] Failed", sb.toString().trim())
        }
        return process.exitValue()
    }


    String executeForOutput(File dir, String args) {
        executeForOutput(null, dir, [:], args.split('\\s+'))
    }

    String executeForOutput(byte[] input = null, File dir = new File("."), Map<String, String> env = [:], String args) {
        executeForOutput(input, dir, env, args.split('\\s+'))
    }

    String executeForOutput(byte[] input = null, File dir = new File("."), Map<String, String> env = [:], GString args) {
        executeForOutput(input, dir, env, args.split('\\s+'))
    }

    String executeForOutput(byte[] input = null, File dir = new File("."), Map<String, String> env = [:], String... args) {
        StringBuilder sb = new StringBuilder()
        List<?> flatten = fix(args)
        LOGGER.debug("Running ${flatten.join(",")}")
        Process process = createProcess(flatten, dir, env)
        if (input != null) {
            process.outputStream.write(input)
            process.outputStream.flush()
            process.outputStream.close()
        }
        process.inputStream.eachLine {
            LOGGER.debug("output:  [$it]")
            sb.append(it).append("\n")
        }
        process.waitFor();
        if (process.exitValue() == 0) {
            return sb.toString().trim();
        } else {
            LOGGER.error("Command [${flatten.join(",")}] failed with output:\n" + sb.toString().trim())
            throw new ExecWrapperException("[${flatten.join(",")}] Failed", sb.toString().trim())
        }
    }

    private List<?> fix(String... args) {
        ([] << command.split("\\s") << args).flatten()
    }

    private Process createProcess(List<String> command, File dir, Map<String, String> env = [:]) {
        ProcessBuilder builder = new ProcessBuilder(command)
                .directory(dir)
                .redirectErrorStream(true)
        builder.environment() << (environment << env).collectEntries {
            [(it.key.toString()): it.value.toString()]
        }
        return builder.start()
    }

    static class ExecWrapperException extends RuntimeException {
        private final String output;

        String getOutput() {
            return output
        }

        ExecWrapperException(String output) {
            this.output = output
        }

        ExecWrapperException(String var1, String output) {
            super(var1)
            this.output = output
        }

        ExecWrapperException(String var1, Throwable var2, String output) {
            super(var1, var2)
            this.output = output
        }

        ExecWrapperException(Throwable var1, String output) {
            super(var1)
            this.output = output
        }

        ExecWrapperException(String var1, Throwable var2, boolean var3, boolean var4, String output) {
            super(var1, var2, var3, var4)
            this.output = output
        }
    }
}