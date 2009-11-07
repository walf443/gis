require 'pathname'

class Gis
    def initialize args=[]
        @subcmd = args.shift or 
            raise ArgumentError, "please subcommand"
        @args = args

        @git_repos = Pathname.pwd
    end

    attr_reader :git_repos

    def run
        subcmd = dispatch(@subcmd, @args, {})
        subcmd.run
    end

    def dispatch name, args, options
        lib = "gis/cmd/#{name}"
        require lib
        klass = eval "#{self.class}::Cmd::#{name.capitalize}" # FIXME
        klass.new self, args, options
    end

    def git_cmd
        "git --git-dir=#{@git_repos.to_s}/.git"
    end

    def run_git *args
        cmd = [ self.git_cmd, *args ].map {|i| i.to_s }.join(' ')
        system(cmd)
    end

    def move_branch name, &block
        self.run_git :stash, :save
        self.run_git(:branch, name, "2>/dev/null")
        self.run_git :checkout, name
        block.call(name)
        # TODO: is there better way to know before branch( or commit ) name.
        reflog = "#{self.git_cmd} reflog"
        before_branch = nil
        %x{#{reflog}}.each_line do |line|
            if line =~ /checkout: moving from (.+) to (.+)/
                if $2 == name
                    before_branch = $1
                    break
                end
            end
        end
        if before_branch
            self.run_git :checkout, before_branch
        end
        self.run_git :stash, :pop
    end
end

require 'gis/store'

if $0 == __FILE__
    Gis.new(ARGV).run
end
