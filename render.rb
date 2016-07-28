#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'fileutils'
require 'mustache'
require 'yaml'

class MustacheLatex < Mustache
  # Escape LaTeX newlines
  def escapeHTML str
    str.strip.gsub("\n", '\\\\\\\\')
  end
end

base_dir = File.dirname(File.absolute_path(__FILE__))
template = File.read(File.join(base_dir, 'invoice.tex.mustache'))

# Load data
data = {}
ARGV.each do |file|
  raise 'only YAML supported (for now)' unless file =~ /\.ya?ml\Z/i
  data.merge!(YAML.load_file(file))
end

# Compute missing amounts
data['items'].each do |item|
  item['amount'] ||= item['quantity'] * item['unitprice']
end
data['totalamount'] ||= data['items'].map { |item| item['amount'] }.reduce(:+)

# Format currency amounts
data['items'].each do |item|
  unless item['unitprice'].nil?
    item['unitprice'] = format('%.2f', item['unitprice'])
  end
  item['amount'] = format('%.2f', item['amount'])
end
data['totalamount'] = format('%.2f', data['totalamount'])

# Create temporary directory
Dir.mktmpdir('invoice') do |tmp_dir|
  # Render LaTeX
  file_base = File.basename(ARGV.last).sub(/\.[^.]*\Z/, '')
  latex_file = File.join(tmp_dir, file_base + '.tex')
  File.write(latex_file, MustacheLatex.render(template, data))

  # Render PDF
  %x(
    cd #{tmp_dir} && \
    TEXINPUTS="#{base_dir}:$TEXINPUTS" \
    latexmk -halt-on-error -lualatex #{latex_file} 1>&2
  )
  exit $?.exitstatus unless $?.success?

  # Move PDF to working directory
  pdf_file = File.join(tmp_dir, file_base + '.pdf')
  FileUtils.mv(pdf_file, File.basename(pdf_file))
end
