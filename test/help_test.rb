require_relative 'test_helper'

class TestHelp < TestDsl::TestCase
  include Columnize

  let(:available_commands) {
    Byebug::Command.commands.select(&:event).map(&:names).flatten.uniq.sort }

  describe 'when typed alone' do
    temporary_change_hash Byebug::Command.settings, :width, 50

    it 'must show self help when typed alone' do
      enter 'help'
      debug_file 'help'
      check_output_includes \
        'Type "help <command-name>" for help on a specific command',
        'Available commands:', columnize(available_commands, 50)
    end

    it 'must work when shortcut used' do
      enter 'h'
      debug_file 'help'
      check_output_includes \
        'Type "help <command-name>" for help on a specific command'
    end
  end

  describe 'when typed with a command'  do
    it 'must show an error if an undefined command is specified' do
      enter 'help foobar'
      debug_file 'help'
      check_output_includes \
        'Undefined command: "foobar".  Try "help".', interface.error_queue
    end

    it "must show a command's help" do
      enter 'help break'
      debug_file 'help'
      check_output_includes \
        "b[reak] file:line [if expr]\n" \
        "b[reak] class(.|#)method [if expr]\n\n" \
        "Set breakpoint to some position, (optionally) if expr == true\n"
    end
  end

  describe 'when typed with command and subcommand' do
    it "must show subcommand's long help" do
      enter 'help info breakpoints'
      debug_file 'help'
      check_output_includes \
        "Status of user-settable breakpoints.\n" \
        "Without argument, list info about all breakpoints. " \
        "With an integer argument, list info on that breakpoint."
    end
  end

  describe 'Post Mortem' do
    it 'must work in post-mortem mode' do
      enter 'cont', 'help'
      debug_file 'post_mortem'
      check_output_includes 'Available commands:'
    end
  end

end
