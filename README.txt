= ar_extractor
* http://github.com/abikounso/ar_extractor/tree/master


== DESCRIPTION:
テスト用のデータを扱うのに便利なプラグイン。


== FEATURES:
* 同種のプラグイン ar_fixturesと比較して、以下の特徴がある。
  * 内部でto_yamlメソッドを使用していないため、UTF-8の文字列も問題なく扱える。
  * カラムの表示順が、テーブルのカラムの表示順と同じなので、見やすい。
  * RSpecがインストールされている場合は、spec/fixtures/にデータが出力される。（インストールされていない場合は、test/fixtures/に出力）
  * populator用のrakeファイルを自動生成する機能。


== PROBLEMS
* generator
  * HABTM結合用のテーブルはサポートしていない。


== USAGE:
* DB > YAML出力
  * 全てのテーブルのデータをYAMLに出力。
    rake db:fixtures:extract

  * FIXTURESにテーブル名を指定すると、そのテーブルのデータだけが出力される。
    rake db:fixtures:extract FIXTURES=users,cliets

* DBのスキーマを解析して、ダミーデータ自動生成用のrakeファイルをgenerate(populate, faker必須)
  * ruby script/generate ar_extractor
    で、
    lib/tasks/population.rake
    ができる。

    population.rakeの中身は、こんな感じ。
------------------------------------------------------------------------------------------
namespace :db do
  desc "Erase and fill database"
  task :populate => :environment do
    require "populator"
    require "faker"

    [Accounting, Bank, Client, Collateral, Liability, Team, User].each(&:delete_all)
    
    Accounting.populate 20 do |column|
      column.fiscal_year = 1900..Time.now.year
      column.net_operating_profit = 1..10000
      column.depreciation = 1..10000
      column.amount_repaid = 1..10000
      column.client_id = 1..20
    end

    Bank.populate 20 do |column|
      column.name = Faker::Name.name
    end

    Client.populate 20 do |column|
      column.name = Faker::Name.name
      column.user_id = 1..20
    end

    Collateral.populate 20 do |column|
      column.name = Faker::Name.name
      column.appraised_amount = 1..10000
      column.client_id = 1..20
    end

    Liability.populate 20 do |column|
      column.debt = 1..10000
      column.bank_id = 1..20
      column.client_id = 1..20
      column.collateral_id = 1..20
    end

    Team.populate 20 do |column|
      column.name = Faker::Name.name
      column.leader_id = 1..20
      column.upper_team_id = 1..20
    end

    User.populate 20 do |column|
      column.name = Faker::Name.name
    end

  end
end
------------------------------------------------------------------------------------------
  * あとは、
    rake db:populate
    で、ダミー用のデータがDBに生成される。


== REQUIREMENTS:
* Rails 2.1(動作確認は行なっていないが、恐らく他のバージョンでも問題はないと思われる。)
* populator(generatorを使用する場合)
* faker    (generatorを使用する場合)


== INSTALL:
* 事前に、下記のライブラリをインストールしておくこと
  * gem install populator faker
