module LogFormatter
    class JSONLogFormatter < Logger::Formatter
        def call(severity, _time, _progname, msg)
            log = {
              time: _time.iso8601(6),
              level: severity,
              progname: _progname,
              msg: msg,
              type: "default",
            }

            log.to_json + "\n"
        end
    end
end
