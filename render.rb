#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'fileutils'
require 'mustache'
require 'yaml'

base_dir = File.dirname(File.absolute_path(__FILE__))
template = File.read(File.join(base_dir, 'invoice.tex.mustache'))

# Load data
data_file = ARGV[0]
data = if data_file =~ /\.ya?ml\Z/i
  YAML.load_file(data_file)
else
  raise 'only YAML supported (for now)'
end

# Create temporary directory
Dir.mktmpdir 'invoice' do |tmp_dir|
  # Render LaTeX
  latex_file = File.join(
    tmp_dir,
    File.basename(data_file).sub(/\.[^.]*\Z/, '') + '.tex'
  )
  File.write(latex_file, Mustache.render(template, data))

  # Render PDF
  %x(
    cd #{tmp_dir} && \
    TEXINPUTS="#{base_dir}:$TEXINPUTS" \
    latexmk -lualatex #{latex_file}
  )

  # Move PDF to working directory
  pdf_file = latex_file.sub(/\.tex\Z/, '.pdf')
  FileUtils.mv(pdf_file, File.basename(pdf_file))
end
