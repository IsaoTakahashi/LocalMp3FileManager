require 'test/unit'
require_relative '../lib/fileSearch'

class TestFileSearch < Test::Unit::TestCase
  class << self
    # テスト群の実行前に呼ばれる．変な初期化トリックがいらなくなる
    def startup
      p :_startup
    end

    # テスト群の実行後に呼ばれる
    def shutdown
      p :_shutdown
    end
  end

  # 毎回テスト実行前に呼ばれる
  def setup
    p :setup
  end

  # テストがpassedになっている場合に，テスト実行後に呼ばれる．テスト後の状態確認とかに使える
  def cleanup
    p :cleanup
  end

  # 毎回テスト実行後に呼ばれる
  def teardown
    p :treadown
  end

  def test_get_dir_list
  	dirs = FileSearch.get_dir_list("test/assets/dir.lst.test")
  	assert_equal(2,dirs.count)
  end

  def test_search_mp3
  	files = FileSearch.search_mp3("./")
  	assert_equal(0,files.count)
  end
end