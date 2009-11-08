require 'tempfile'
require 'digest/md5'
require 'fileutils'

class Gis
    module Cmd
        class Add
            def initialize app, args, options
                @app = app
                @branch = args.shift or 
                    raise "branch is missing"
            end

            def run
                @app.move_branch(@branch) do
                    t = Tempfile.new('gis' + @app.git_repos.to_s)
                    editor = ENV['EDITOR']
                    system(editor, t.path)
                    digest = nil
                    content = nil
                    File.open(t.path) do |file|
                        content = file.read
                        digest = Digest::MD5.hexdigest(content)
                    end

                    if content
                        first_line = nil
                        content.each_line do |line|
                            first_line = line
                            break
                        end
                        FileUtils.cp(t.path, digest)
                        @app.run_git(:add, digest)
                        @app.run_git(:commit, %{--message "add #{digest}: #{first_line}"}, digest)
                    end
                end
            end
        end
    end
end
