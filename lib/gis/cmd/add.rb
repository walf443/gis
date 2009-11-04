require 'tempfile'
require 'digest/md5'

class Gis
    module Cmd
        class Add
            def initialize app, args, options
                @app = app
                @store = Gis::Store.new(@app.git_repos.to_s)
            end

            def run
                t = Tempfile.new('gis' + @app.git_repos.to_s)
                editor = ENV['EDITOR']
                system(editor, t.path)
                digest = nil
                commit = nil
                content = nil
                File.open(t.path) do |file|
                    content = file.read
                    digest = Digest::MD5.hexdigest(content)
                    commit = @store[digest] = content
                end

                if commit
                    first_line = nil
                    content.each_line do |line|
                        first_line = line
                        break
                    end
                    @store.commit "add #{digest}: #{first_line}"
                end
            end
        end
    end
end
