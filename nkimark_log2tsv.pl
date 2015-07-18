#!/usr/bin/env perl

# nkimark_log2tsv.pl
# see: perldoc -t nkimark_log2tsv.pl

# NetKids iMarkの生ログは次の形をしていると想定:
# | NetKids iMark Log File
# | [2015/06/01 01:00:01] Ping応答時間 192.168.1.1 チェック:OK, 2, 2 msec
# | [2015/06/02 02:00:02] SNMPV2データ取得_1.2.3.4.5.6.78901.2.3.4 192.168.1.1 チェック:OK, 25, 15 msec
# | [2015/06/03 03:00:03] HTTP応答時間_http://www.example.com/test.html 192.168.1.1 チェック:OK, 166, 166 msec
# | [2015/06/04 04:00:04] HTTP応答コード_/test.html 192.168.1.1 チェック:OK, 200, 273 msec
# | [2015/06/05 05:00:05] 通知エラー：ﾃﾝﾌﾟﾚｰﾄ型ﾒｰﾙ送信 が行えません. ファイルが見つかりません

use strict;
use warnings;
use utf8;
use Encode;
binmode STDIN, ':encoding(cp932)'; # for Excel/Windows
binmode STDOUT, ':encoding(cp932)'; # for Excel/Windows
#binmode STDOUT, ':encoding(utf-8)';
binmode STDERR, ':encoding(utf-8)';
use Getopt::Std;

my %separator = ('tsv' => "\t", 'csv' => ',', '' => "\t");
my %options = ();
Getopt::Std::getopts('s:', \%options);
if (exists($options{'s'})) {
	if (!exists($separator{$options{'s'}})) {
		print STDERR sprintf('ERROR: option -s "%s" is not defined.', $options{'s'}) . "\n";
		exit 1;
	}
} else {
	$options{'s'} = 'tsv';
}

my $separator = $separator{$options{'s'}};
my $regex_firstline = 'NetKids iMark Log File';
my $regex_datetime = '\[(\d{4}/\d{2}/\d{2}) (\d{2}:\d{2}:\d{2})\]';
my $regex_ipaddress = '(\d+\.\d+\.\d+\.\d+)';
my $regex_status = '(\S+), (\d+), (\d+) msec';

my $regex_core_ping = 'Ping応答時間';
my $regex_core_snmpv2 = 'SNMPV2データ取得\_(\S+)';
my $regex_core_httptime = 'HTTP応答時間\_(\S+)';
my $regex_core_httpcode = 'HTTP応答コード\_(\S+)';
my $regex_core_noticeerror = '(通知エラー：ﾃﾝﾌﾟﾚｰﾄ型ﾒｰﾙ送信 が行えません. ファイルが見つかりません)';

my $count = 1;
my $error = 0;
my $line_output = join($separator, '#日付', '#時刻', '#項目1', '#項目2', '#IPアドレス', '#状態', '#値1', '#値2(msec)');
print $line_output . "\n";

while(defined(my $line = <STDIN>)) {
	chomp($line);
	if ($line =~ /$regex_firstline/) {
		# 最初の行
		$line_output = '';
	} elsif ($line =~ /$regex_core_ping/) {
		# Ping応答時間
		$line =~ /$regex_datetime $regex_core_ping $regex_ipaddress $regex_status/;
		my($date, $time, $ipaddress, $status_1, $status_2, $status_3) = ($1, $2, $3, $4, $5, $6);
		$line_output = join($separator, $date, $time, 'Ping応答時間', '', $ipaddress, $status_1, $status_2, $status_3);
	} elsif ($line =~ /$regex_core_snmpv2/) {
		# SNMPV2データ取得
		$line =~ /$regex_datetime $regex_core_snmpv2 $regex_ipaddress $regex_status/;
		my($date, $time, $snmpv2, $ipaddress, $status_1, $status_2, $status_3) = ($1, $2, $3, $4, $5, $6, $7);
		$line_output = join($separator, $date, $time, 'SNMPV2データ取得', $snmpv2, $ipaddress, $status_1, $status_2, $status_3);
	} elsif ($line =~ /$regex_core_httptime/) {
		# HTTP応答時間
		$line =~ /$regex_datetime $regex_core_httptime $regex_ipaddress $regex_status/;
		my($date, $time, $httptime, $ipaddress, $status_1, $status_2, $status_3) = ($1, $2, $3, $4, $5, $6, $7);
		$line_output = join($separator, $date, $time, 'HTTP応答時間', $httptime, $ipaddress, $status_1, $status_2, $status_3);
	} elsif ($line =~ /$regex_core_httpcode/) {
		# HTTP応答コード
		$line =~ /$regex_datetime $regex_core_httpcode $regex_ipaddress $regex_status/;
		my($date, $time, $httpcode, $ipaddress, $status_1, $status_2, $status_3) = ($1, $2, $3, $4, $5, $6, $7);
		$line_output = join($separator, $date, $time, 'HTTP応答コード', $httpcode, $ipaddress, $status_1, $status_2, $status_3);
	} elsif ($line =~ /$regex_core_noticeerror/) {
		# 通知エラー
		$line =~ /$regex_datetime $regex_core_noticeerror/;
		my($date, $time, $noticeerror) = ($1, $2, $3);
		$line_output = join($separator, $date, $time, $noticeerror);
	} else {
		# 上記以外の例外
		$error = 1;
		$line_output = sprintf('ERROR [%d]: %s', $count, $line);
	}
	if ($error) {
		print STDERR $line_output . "\n";
	} elsif ($line_output) {
		print $line_output . "\n";
	}
	$count ++;
	$error = 0;
}

exit;

=pod

=encoding utf8

=head1 NAME

nkimark_log2tsv.pl - NetKids iMark Log Converter

=head1 VERSION

ver.20150625

=head1 DESCRIPTION

NetKids iMarkが保存する生ログのファイルを, TSV/CSV形式のファイルに変換します. 標準入力/標準出力のパイプとして動作します.

対応している生ログの形式は, ソースファイルを参照してください.

=head1 USAGE

perl nkimark_log2tsv.pl -s tsv < original.log > original.tsv

=head2 OPTION

=over

=item -s [tsv|csv] (default = tsv)

=back

=head1 AUTHOR

Masahiko OHKUBO <ohkubo.masahiko@icraft.jp> <https://twitter.com/mah_jp>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Masahiko OHKUBO.

This is free software; you can redistribute it and/or modify it under the same terms as the Perl 5 programming language system itself.

=cut
