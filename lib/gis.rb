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
end

if $0 == __FILE__
    Gis.new(ARGV).run
end
