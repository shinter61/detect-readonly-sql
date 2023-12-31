# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
 Rails.root.glob('spec/support/**/*.rb').sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

# app, SQL log を spec でも標準出力に吐き出す
Rails.logger = Logger.new(STDOUT)
ActiveRecord::Base.logger = Logger.new(STDOUT)

$executed_queries = {}

require 'sql_logger'
require 'read_only_transaction_checker'

# 現在実行中の example について実行された SQL の配列を初期化
class ReporterListener
  def example_started(notification)
    $executed_queries[:"#{notification.example.metadata[:full_description]}"] = []
  end
end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = Rails.root.join('spec/fixtures')

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://rspec.info/features/6-0/rspec-rails
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  # readonly なクエリのレポート用
  config.reporter.register_listener(ReporterListener.new, :example_started)

  config.before(:suite) do
    # 冪等性のためにレポート用ファイルを削除
    readonly_query_report_filename = 'readonly_query_report.txt'
    File.delete(readonly_query_report_filename) if File.exists?(readonly_query_report_filename)
  end

  # 全テスト終了時に、readonly なクエリをファイルに書き出す
  config.after(:suite) do
    # レポート用のファイルを作成
    readonly_query_report_filename = 'readonly_query_report.txt'
    readonly_query_report_file = File.new(readonly_query_report_filename, 'w')

    readonly_query_report_file.puts "以下のテストケースが readonly なものです。reader に向けられないか検討してください。<br/>"

    examples = $executed_queries.keys
    examples.each do |example|
      checker = ReadOnlyTransactionChecker.new($executed_queries[example])
      checker.check!
      # その example でのクエリが readonly か判定
      if checker.readonly_example?
        readonly_query_report_file.puts "[All readonly] example: #{example} <br/>"

        $executed_queries[example].each do |executed_sql|
          readonly_query_report_file.puts "- SQL: #{executed_sql.sql} <br/>"
          readonly_query_report_file.puts "- Called from: #{executed_sql.called_from.gsub('\'', '`')} <br/>"
        end

        readonly_query_report_file.puts "<br/>"
      elsif checker.readonly_transactions.present?
        readonly_query_report_file.puts "[Partial readonly] example: #{example} <br/>"

        checker.readonly_transactions.each do |transaction|
          transaction.each do |executed_sql|
            readonly_query_report_file.puts "- SQL: #{executed_sql.sql} <br/>"
            readonly_query_report_file.puts "- Called from: #{executed_sql.called_from.gsub('\'', '`')} <br/>"
          end
        end

        readonly_query_report_file.puts "<br/>"
      end
    end
  end
end
