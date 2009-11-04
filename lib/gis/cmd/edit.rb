require 'rubygems'
require 'git_store'
require 'tempfile'
require 'digest/md5'

class Gis
    module Cmd
        class Edit
            def initialize app, args, options
                @app = app
                @key = args.shift or
                    raise ArgumentError

                @store = GitStore.new(@app.git_repos.to_s)
            end

            def run
                t = Tempfile.new('gis' + @app.git_repos.to_s)
                editor = ENV['EDITOR']
                content = @store[@key] or 
                    raise "no such content: #@key"
                File.open(t.path, 'w') do |file|
                    file.write(content)
                end
                system(editor, t.path)
                digest = nil
                commit = nil
                File.open(t.path) do |file|
                    content = file.read
                    commit = @store[@key] = content
                end

                if commit
                    first_line = nil
                    content.each_line do |line|
                        first_line = line
                        break
                    end
                    @store.commit "edit #{@key}: #{first_line}"
                end
            end
        end
    end
end
