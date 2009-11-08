require 'tempfile'
require 'digest/md5'

class Gis
    module Cmd
        class Edit
            def initialize app, args, options
                @app = app
                @branch = args.shift or
                    raise ArgumentError
                @key = args.shift or
                    raise ArgumentError

            end

            def run
                @app.move_branch @branch do
                    editor = ENV['EDITOR']
                    unless File.exist?(@key)
                        raise "no such content: #@key"
                    end
                    system(editor, @key)
                    content = nil
                    File.open(@key) do |file|
                        content = file.read
                    end

                    if content
                        first_line = nil
                        content.each_line do |line|
                            first_line = line
                            break
                        end
                        @app.run_git(:commit, %{--message "edit #{@key}: #{first_line}"}, @key)
                    end
                end
            end
        end
    end
end
