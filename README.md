nkimark_log2tsv - Log Converter for NetKids iMark
=================================================

What is this?
-------------

サーバ監視ツール『[NetKids iMark](http://www.istinc.co.jp/product/net/nki.html)』が保存するログファイル (生ログ) を、TSV/CSV形式のテキストファイル、またはExcel形式のデータファイル (.xlsx) に変換するためのPerlスクリプト一式です。

作者が勤務先の業務にて作成し、実際に使用しているツールを公開しています。

USAGE
-----

次のように2ステップで使います。必要となるPerlモジュールは、動作環境にインストールしておいてください。

1. NetKids iMarkの生ログをTSV形式の1ファイルに変換:
	- nkimark_log2tsv.pl -s tsv < NKIMARKyymm.log > NKIMARKyymm.tsv
2. 上記のTSVファイルを日付別に分割してExcelファイルに変換:
	- tsv_splitter.pl -i NKIMARKyymm.tsv -d -h 1 -e 1

AUTHOR
------

大久保 正彦 (Masahiko OHKUBO) <[mah@remoteroom.jp](mailto:mah@remoteroom.jp)> <[https://twitter.com/mah_jp](https://twitter.com/mah_jp)>
- 勤務先: アイクラフト株式会社 <[http://www.icraft.jp/](http://www.icraft.jp/)>
