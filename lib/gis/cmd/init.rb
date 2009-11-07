class Gis
    module Cmd
        class Init
            META_FILENAME = "GIS_INFO"
            def initialize app, args, options
                @app = app
                @branch_name = args.shift or
                    raise "no branch name"
            end

            def run
                @app.move_branch @branch_name do
                    if File.exist?(META_FILENAME)
                        raise "branch #{@branch_name} is already managed by gis"
                    else
                        @app.run_git "rm -rf ."
                        system("touch #{META_FILENAME}")
                        @app.run_git(:add, META_FILENAME)
                        @app.run_git :commit, %|--message "gis: initialized #{@branch_name}"|
                    end
                end
            end
        end
    end
end
