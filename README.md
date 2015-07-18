nkimark_log2tsv
===============

What is this?
-------------

サーバ監視ツール『[NetKids iMark](http://www.istinc.co.jp/product/net/nki.html)』が保存するログファイル (生ログ) を、TSV/CSV形式のテキストファイル、またはExcel形式のデータファイル (.xlsx) に変換するためのPerlスクリプト一式です。

作者が勤務先での業務の必要に応じて作成し、使用しているツールを公開しています。

USAGE
-----

次のように2ステップで使います。必要となるPerlモジュールは動作環境にインストールしておいてください。

1. 生ログをTSV形式の1ファイルに変換) nkimark_log2tsv.pl -s tsv < NKIMARKyymm.log > NKIMARKyymm.tsv
2. TSVファイルを日付別に分割してExcelファイルに変換) tsv_splitter.pl -i NKIMARKyymm.tsv -d -h 1 -e 1

AUTHOR
------

大久保 正彦 (Masahiko OHKUBO) <[ohkubo.masahiko@icraft.jp](mailto:ohkubo.masahiko@icraft.jp)> <[https://twitter.com/mah_jp](https://twitter.com/mah_jp)>
