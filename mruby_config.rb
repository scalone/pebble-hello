MRuby::Toolchain.new(:pebble) do |conf|
  ENV["PEBBLE_SDK_COMMON"] = "/usr/local/Cellar/pebble-sdk/3.4/Pebble/common"
  ENV["LIBDIR"] = "/usr/local/lib"

  [conf.cc, conf.objc, conf.asm].each do |cc|
    cc.command = ENV['CC'] || '/usr/local/Cellar/pebble-sdk/3.4/arm-cs-tools/bin/arm-none-eabi-gcc'
    #cc.flags = [ENV['CFLAGS'] || %w(-g -std=gnu99 -O3 -Wall -Werror-implicit-function-declaration -Wdeclaration-after-statement -Wwrite-strings)]
    cc.flags = [ENV['CFLAGS'] || %w(-g -std=c99 -mcpu=cortex-m3 -mthumb -ffunction-sections -fdata-sections -Os -D_TIME_H_ -Wall -Wextra -Werror -Wno-unused-parameter -Wno-error=unused-function -Wno-error=unused-variable -fPIE)]
    cc.defines = %w(DISABLE_GEMS)
    cc.option_include_path = '-I%s'
    cc.option_define = '-D%s'
    cc.include_paths << ['/usr/local/Cellar/pebble-sdk/3.4/Pebble/basalt/include', '/usr/local/Cellar/pebble-sdk//3.4/Pebble/aplite/include']
    cc.compile_options = '%{flags} -o %{outfile} -c %{infile}'
  end

  [conf.cxx].each do |cxx|
    cxx.command = ENV['CXX'] || '/usr/local/Cellar/pebble-sdk/3.4/arm-cs-tools/bin/arm-none-eabi-g++'
    #cxx.flags = [ENV['CXXFLAGS'] || ENV['CFLAGS'] || %w(-g -O3 -Wall -Werror-implicit-function-declaration)]
    cxx.flags = [ENV['CFLAGS'] || %w(-g -std=c99 -mcpu=cortex-m3 -mthumb -ffunction-sections -fdata-sections -Os -D_TIME_H_ -Wall -Wextra -Werror -Wno-unused-parameter -Wno-error=unused-function -Wno-error=unused-variable -fPIE)]
    cxx.defines = %w(DISABLE_GEMS)
    cxx.option_include_path = '-I%s'
    cxx.option_define = '-D%s'
    cxx.include_paths << ['/usr/local/Cellar/pebble-sdk/3.4/Pebble/basalt/include', '/usr/local/Cellar/pebble-sdk//3.4/Pebble/aplite/include']
    cxx.compile_options = '%{flags} -o %{outfile} -c %{infile}'
  end

  conf.linker do |linker|
    linker.command = ENV['LD'] || '/usr/local/Cellar/pebble-sdk/3.4/arm-cs-tools/bin/arm-none-eabi-gcc'
    linker.flags = [ENV['LDFLAGS'] || %w()]
    linker.libraries = %w(m)
    linker.library_paths = []
    linker.option_library = '-l%s'
    linker.option_library_path = '-L%s'
    linker.link_options = '%{flags} -o %{outfile} %{objs} %{flags_before_libraries} %{libs} %{flags_after_libraries}'
  end

  # Archiver settings
  conf.archiver do |archiver|
    archiver.command = ENV['AR'] || '/usr/local/Cellar/pebble-sdk/3.4/arm-cs-tools/bin/arm-none-eabi-ar'
    archiver.archive_options = 'rs %{outfile} %{objs}'
  end

  [[conf.cc, 'c'], [conf.cxx, 'c++']].each do |cc, lang|
    cc.instance_variable_set :@header_search_language, lang
    def cc.header_search_paths
      if @header_search_command != command
        result = `echo | #{build.filename command} -x#{@header_search_language} -Wp,-v - -fsyntax-only 2>&1`
        result = `echo | #{command} -x#{@header_search_language} -Wp,-v - -fsyntax-only 2>&1` if $?.exitstatus != 0
        return include_paths if  $?.exitstatus != 0

        @frameworks = []
        @header_search_paths = result.lines.map { |v|
          framework = v.match(/^ (.*)(?: \(framework directory\))$/)
          if framework
            @frameworks << framework[1]
            next nil
          end

          v.match(/^ (.*)$/)
        }.compact.map { |v| v[1] }.select { |v| File.directory? v }
        @header_search_paths += include_paths
        @header_search_command = command
      end
      @header_search_paths
    end
  end
end

MRuby::Build.new do |conf|
  # load specific toolchain settings

  # Gets set by the VS command prompts.
  if ENV['VisualStudioVersion'] || ENV['VSINSTALLDIR']
    toolchain :visualcpp
  else
    toolchain :gcc
  end

  enable_debug

  # Use mrbgems
  # conf.gem 'examples/mrbgems/ruby_extension_example'
  # conf.gem 'examples/mrbgems/c_extension_example' do |g|
  #   g.cc.flags << '-g' # append cflags in this gem
  # end
  # conf.gem 'examples/mrbgems/c_and_ruby_extension_example'
  # conf.gem :github => 'masuidrive/mrbgems-example', :checksum_hash => '76518e8aecd131d047378448ac8055fa29d974a9'
  # conf.gem :git => 'git@github.com:masuidrive/mrbgems-example.git', :branch => 'master', :options => '-v'

  # include the default GEMs
  conf.gembox 'default'

  # C compiler settings
  # conf.cc do |cc|
  #   cc.command = ENV['CC'] || 'gcc'
  #   cc.flags = [ENV['CFLAGS'] || %w()]
  #   cc.include_paths = ["#{root}/include"]
  #   cc.defines = %w(DISABLE_GEMS)
  #   cc.option_include_path = '-I%s'
  #   cc.option_define = '-D%s'
  #   cc.compile_options = "%{flags} -MMD -o %{outfile} -c %{infile}"
  # end

  # mrbc settings
  # conf.mrbc do |mrbc|
  #   mrbc.compile_options = "-g -B%{funcname} -o-" # The -g option is required for line numbers
  # end

  # Linker settings
  # conf.linker do |linker|
  #   linker.command = ENV['LD'] || 'gcc'
  #   linker.flags = [ENV['LDFLAGS'] || []]
  #   linker.flags_before_libraries = []
  #   linker.libraries = %w()
  #   linker.flags_after_libraries = []
  #   linker.library_paths = []
  #   linker.option_library = '-l%s'
  #   linker.option_library_path = '-L%s'
  #   linker.link_options = "%{flags} -o %{outfile} %{objs} %{libs}"
  # end

  # Archiver settings
  # conf.archiver do |archiver|
  #   archiver.command = ENV['AR'] || 'ar'
  #   archiver.archive_options = 'rs %{outfile} %{objs}'
  # end

  # Parser generator settings
  # conf.yacc do |yacc|
  #   yacc.command = ENV['YACC'] || 'bison'
  #   yacc.compile_options = '-o %{outfile} %{infile}'
  # end

  # gperf settings
  # conf.gperf do |gperf|
  #   gperf.command = 'gperf'
  #   gperf.compile_options = '-L ANSI-C -C -p -j1 -i 1 -g -o -t -N mrb_reserved_word -k"1,3,$" %{infile} > %{outfile}'
  # end

  # file extensions
  # conf.exts do |exts|
  #   exts.object = '.o'
  #   exts.executable = '' # '.exe' if Windows
  #   exts.library = '.a'
  # end

  # file separetor
  # conf.file_separator = '/'

  # bintest
  # conf.enable_bintest
end

MRuby::Build.new('host-debug') do |conf|
  # load specific toolchain settings

  # Gets set by the VS command prompts.
  if ENV['VisualStudioVersion'] || ENV['VSINSTALLDIR']
    toolchain :visualcpp
  else
    toolchain :gcc
  end

  enable_debug

  # include the default GEMs
  conf.gembox 'default'

  # C compiler settings
  conf.cc.defines = %w(ENABLE_DEBUG)

  # Generate mruby debugger command (require mruby-eval)
  conf.gem :core => "mruby-bin-debugger"

  # bintest
  # conf.enable_bintest
end

MRuby::Build.new('test') do |conf|
  toolchain :gcc

  enable_debug
  conf.enable_bintest
  conf.enable_test

  conf.gembox 'default'
end

#Define cross build settings
MRuby::CrossBuild.new('pebble-time') do |conf|
  toolchain :pebble
  conf.cc.defines = %w(EXIT_FAILURE DISABLE_GEMS)
  conf.bins = []
end
