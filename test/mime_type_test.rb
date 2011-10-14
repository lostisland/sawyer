require File.expand_path('../helper', __FILE__)

module Sawyer
  class MimeTypeTest < TestCase
    def test_parses_simple_type
      mime = MimeType.new('text/plain')
      assert_equal 'text',  mime.media_type
      assert_equal 'plain', mime.sub_type
      assert_equal '',      mime.suffix
      assert_equal({},      mime.options)
    end

    def test_parses_simple_type_with_options
      mime = MimeType.new('text/plain; charset=utf-8')
      assert_equal 'text',  mime.media_type
      assert_equal 'plain', mime.sub_type
      assert_equal '',      mime.suffix
      assert_equal 'utf-8', mime.options['charset']
      assert !mime.vendor?
    end

    def test_parses_vendor_type
      mime = MimeType.new('application/vnd.abc+json; charset=utf-8')
      assert_equal 'application', mime.media_type
      assert_equal 'vnd.abc',     mime.sub_type
      assert_equal 'json',        mime.suffix
      assert_equal 'utf-8',       mime.options['charset']
      assert_equal 'abc',         mime.vendor
      assert mime.vendor?
    end
  end
end
