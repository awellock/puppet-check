require_relative 'spec_helper'
require_relative '../lib/puppet-check'

describe PuppetCheck do
  context 'self' do
    it 'settings can be altered' do
      PuppetCheck.settings[:future_parser] = true
      expect(PuppetCheck.settings[:future_parser]).to eql(true)
      PuppetCheck.settings[:fail_on_warnings] = true
      expect(PuppetCheck.settings[:fail_on_warnings]).to eql(true)
      PuppetCheck.settings[:style_check] = true
      expect(PuppetCheck.settings[:style_check]).to eql(true)
      PuppetCheck.settings[:smoke_check] = true
      expect(PuppetCheck.settings[:smoke_check]).to eql(true)
      PuppetCheck.settings[:regression_check] = true
      expect(PuppetCheck.settings[:regression_check]).to eql(true)
      PuppetCheck.settings[:output_format] = 'text'
      expect(PuppetCheck.settings[:output_format]).to eql('text')
      PuppetCheck.settings[:octoconfig] = '.octocatalog-diff.cfg.rb'
      expect(PuppetCheck.settings[:octoconfig]).to eql('.octocatalog-diff.cfg.rb')
      PuppetCheck.settings[:octonodes] = %w[localhost.localdomain]
      expect(PuppetCheck.settings[:octonodes]).to eql(%w[localhost.localdomain])
      PuppetCheck.settings[:puppetlint_args] = ['--puppetlint-arg-one', '--puppetlint-arg-two']
      expect(PuppetCheck.settings[:puppetlint_args]).to eql(['--puppetlint-arg-one', '--puppetlint-arg-two'])
      PuppetCheck.settings[:rubocop_args] = ['--rubocop-arg-one', '--rubocop-arg-two']
      expect(PuppetCheck.settings[:rubocop_args]).to eql(['--rubocop-arg-one', '--rubocop-arg-two'])
    end
  end

  context '.parse_paths' do
    before(:each) { Dir.chdir(fixtures_dir) }

    let(:no_files) { PuppetCheck.parse_paths(%w[foo bar baz]) }
    let(:file) { PuppetCheck.parse_paths(['lib/good.rb']) }
    let(:dir) { PuppetCheck.parse_paths(['.']) }
    let(:multi_dir) { PuppetCheck.parse_paths(%w[hieradata lib manifests]) }
    let(:repeats) { PuppetCheck.parse_paths(['hieradata', 'hieradata', 'lib', 'hieradata/good.json', 'manifests/good.pp', 'manifests/good.pp']) }

    it 'raises an error if no files were found' do
      expect { no_files }.to raise_error(RuntimeError, 'puppet-check: no files found in supplied paths foo, bar, baz.')
    end

    it 'correctly parses one file and returns it' do
      expect(file[0]).to eql('lib/good.rb')
    end

    it 'correctly parses one directory and returns all of its files' do
      dir.each { |file| expect(File.file?(file)).to be true }
      expect(dir.length).to eql(29)
    end

    it 'correctly parses multiple directories and returns all of their files' do
      multi_dir.each { |file| expect(File.file?(file)).to be true }
      expect(multi_dir.length).to eql(13)
    end

    it 'correctly parses three directories (one repeated) and three files (one repeated from directories and another repeated from files) and returns the unique files' do
      repeats.each { |file| expect(File.file?(file)).to be true }
      expect(repeats.length).to eql(10)
    end
  end

  context '.execute_parsers' do
    it 'correctly organizes a set of files and invokes the correct parsers' do
      # parser_output = instance_double('execute_parsers', files: %w[puppet.pp puppet_template.epp ruby.rb ruby_template.erb yaml.yaml yaml.yml json.json Puppetfile Modulefile foobarbaz], future: false, style: false, pl_args: [], rc_args: [])
      # expect(parser_output).to receive(:manifest).with(%w[puppet.pp])
      # expect(parser_output).to receive(:template).with(%w[puppet_template.epp])
      # expect(parser_output).to receive(:ruby).with(%w[ruby.rb])
      # expect(parser_output).to receive(:template).with(%w[ruby_template.erb])
      # expect(parser_output).to receive(:yaml).with(%w[yaml.yaml yaml.yml])
      # expect(parser_output).to receive(:json).with(%w[json.json])
      # expect(parser_output).to receive(:librarian).with(%w[Puppetfile Modulefile])
      # expect(PuppetCheck.settings[:ignored_files]).to eql(%w[foobarbaz])
    end
  end
end
