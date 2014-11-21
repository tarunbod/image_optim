require 'image_optim/worker'

class ImageOptim
  class Worker
    # http://pmt.sourceforge.net/pngcrush/
    class Pngcrush < Worker
      CHUNKS_OPTION =
      option(:chunks, :alla, Array, 'List of chunks to remove or '\
          '`:alla` - all except tRNS/transparency or '\
          '`:allb` - all except tRNS and gAMA/gamma') do |v|
        Array(v).map(&:to_s)
      end

      FIX_OPTION =
      option(:fix, false, 'Fix otherwise fatal conditions '\
          'such as bad CRCs'){ |v| !!v }

      BRUTE_OPTION =
      option(:brute, false, 'Brute force try all methods, '\
          'very time-consuming and generally not worthwhile'){ |v| !!v }

      # Always run first [-1]
      def run_order
        -1
      end

      def optimize(src, dst)
        flags = %w[
          -reduce
          -cc
          -q
        ]
        chunks.each do |chunk|
          flags.push '-rem', chunk
        end
        flags.push '-fix' if fix
        flags.push '-brute' if brute
        if resolve_bin!(:pngcrush).version >= '1.7.80'
          flags.push '-noreduce_palette'
        end

        args = flags + %W[
          --
          #{src}
          #{dst}
        ]

        execute(:pngcrush, *args) && optimized?(src, dst)
      end
    end
  end
end
