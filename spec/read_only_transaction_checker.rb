# readonly な endpoint or transaction を検出するためのクラス
class ReadOnlyTransactionChecker
  def initialize(queries)
    @queries = queries
    @transactions = []
    @readonly_transactions = []
  end

  def check!
    divide_to_transaction!
    find_readonly_transaction!
  end

  # example 単位で readonly か判定
  def readonly_example?
    transactions.length == readonly_transactions.length
  end

  # transaction 単位で readonly なものがないか判定
  def readonly_transactions
    return @readonly_transactions if @readonly_transactions.present?

    find_readonly_transaction!
  end

  def find_readonly_transaction!
    @readonly_transactions = transactions.filter do |transaction|
      transaction
        .map(&:sql)
        .reject { |sql| sql.include?('SAVEPOINT') || sql.include?('ROLLBACK') } # トランザクション開始・終了のstmtは除外
        .all? { |sql| sql.slice(0..5) == 'SELECT' }
    end
  end

  def transactions
    return @transactions if @transactions.present?

    divide_to_transaction!
  end

  def divide_to_transaction!
    # 先頭と末尾の BEGIN ~ ROLLBACK は spec によって張られたトランザクションなので除外する
    if @queries.first.sql == "BEGIN" && @queries.last.sql == "ROLLBACK"
      @queries.shift
      @queries.pop
    end

    transaction = []
    @queries.each do |query|
      if query.sql.slice(0..8) == "SAVEPOINT"
        # トランザクション開始の stmt 
        transaction << query
      elsif query.sql.slice(0..6) == "RELEASE" || query.sql.slice(0..7) == "ROLLBACK"
        # トランザクション終了の stmt なので、一つのトランザクションとしてまとめる
        transaction << query
        @transactions << transaction
        transaction = []
      elsif !transaction.empty?
        # savepoint によって囲まれたトランザクションの中のクエリ
        transaction << query
      else
        # autocommit によるトランザクションなので、クエリ単体でトランザクションとして扱う
        transaction << query
        @transactions << transaction
        transaction = []
      end
    end
  end
end
