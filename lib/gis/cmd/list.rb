require 'git_store'

class Gis
    module Cmd
        class List
            def initialize app, args, options
                @app = app
                @store = GitStore.new(@app.git_repos.to_s)
            end
        end
    end
end
