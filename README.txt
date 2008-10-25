= ar_extractor
* http://github.com/abikounso/ar_extractor/tree/master


== DESCRIPTION:
テスト用のデータを扱うのに便利なプラグイン。


== FEATURES:
* DBのデータをYAMLに変換して、出力。
  * 同種のプラグイン ar_fixturesと比較した場合の特徴
    * 内部でto_yamlメソッドを使用していないため、UTF-8の文字列も問題なく扱える。
    * カラムの表示順が、テーブルのカラムの表示順と同じなので、見やすい。
    * RSpecがインストールされている場合は、spec/fixtures/にデータが出力される。（インストールされていない場合は、test/fixtures/に出力）

* テスト用のダミーデータを自動生成。


== PROBLEMS
  * HABTM結合用テーブルのダミーデータ生成はサポートしていない。


== USAGE:
* DB > YAML出力
  * 全てのテーブルのデータをYAMLに出力。
    rake db:fixtures:extract

  * FIXTURESにテーブル名を指定すると、そのテーブルのデータだけが出力される。
    rake db:fixtures:extract FIXTURES=users,cliets

* DBのスキーマを解析して、ダミーデータを自動生成。
  * 事前に、populatorとfakerをインストールしておく。
    gem install populator faker
    
  * ruby script/generate ar_extractor
    で、
    lib/tasks/population.rake
    が生成される。

    population.rakeの中身は、こんな感じ。
------------------------------------------------------------------------------------------
namespace :db do
  desc "Erase and fill database"
  task :populate => :environment do
    require "populator"
    require "faker"

    [Accounting, Bank].each(&:delete_all)
    
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

  end
end
------------------------------------------------------------------------------------------
  * あとは、
    rake db:populate
    で、ダミー用のデータがDBに格納される。


== REQUIREMENTS:
* Rails 2.1(動作確認は行なっていないが、恐らく他のバージョンでも問題はないと思われる。)
* populator(generatorを使用する場合)
* faker    (generatorを使用する場合)


== INSTALL:
* 下記のライブラリは必須
  * populator
  * faker
