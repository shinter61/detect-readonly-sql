# SQL custom logger
class SQLLogger < ActiveSupport::LogSubscriber

  ExecutedSQL = Struct.new(:sql, :called_from, keyword_init: true)

  def sql(event)
    # トランザクション開始・終了クエリは readonly なので外す
    # SHOW から始まるクエリは readonly なので外す
    # return if event.payload[:sql] =~ /\A\s*(BEGIN|COMMIT|ROLLBACK|SHOW)/

    # ActiveRecord による information_schema への schema 問い合わせクエリも readonly なので外す
    return if event.payload[:sql].include? 'information_schema'

    # app 側で意図的に発行したクエリのコード上のクエリ実行位置を出力
    # spec のファイル名からそのコントローラーだけの stacktrace を出せるとより良いかも
    app_called_lines = caller.select { |called_line| called_line.include? "app/controllers" }

    # request spec でテストデータを用意するために発行したクエリを特定
    sped_called_lines = caller.select { |called_line| called_line.include? "spec/requests" }

    # spec から発行されたクエリはログに含めない
    return if sped_called_lines.present? && app_called_lines.empty?

    # 実行された SQL を context と共に配列に入れる
    current_example = $executed_queries.keys.last

    $executed_queries[current_example] << ExecutedSQL.new(
      sql: event.payload[:sql],
      called_from: app_called_lines.join("\n")
    )
  end
end

# SQL(Active Record) の実行に合わせて hook
SQLLogger.attach_to :active_record

