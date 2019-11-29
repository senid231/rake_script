require 'test_helper'

class TestRakeScript < Minitest::Test
  def setup
    @base = BaseTestObject.new
  end

  def test_cmd
    assert_nil @base.cmd('echo qwe')
  end

  def test_cmd_with_stdout_and_stderr
    out = []
    err = []
    @base.cmd 'echo "qwe"; 1>&2 echo "asd"', stdout: proc { |l| out << l }, stderr: proc { |l| err << l }
    assert_equal ["qwe\n"], out
    assert_equal ["asd\n"], err
  end

  def test_cmd_with_env
    out = []
    env_var = 'qwe'
    @base.cmd "bash -c 'echo $QWE_ASD'", stdout: proc { |l| out << l }, env: { QWE_ASD: env_var }
    assert_equal ["qwe\n"], out
  end

  def test_cmd_failed
    assert_raises(RuntimeError) { @base.cmd('exit 1') }
  end
end
