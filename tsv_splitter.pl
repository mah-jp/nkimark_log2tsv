#!/usr/bin/env perl

# tsv_splitter.pl
# see: perldoc -t tsv_splitter.pl

use strict;
use warnings;
use utf8;
use IO::File;
use Encode;
#binmode STDIN, ':encoding(utf-8)';
#binmode STDOUT, ':encoding(cp932)';
#binmode STDERR, ':encoding(utf-8)';
use Getopt::Std;

my %options = ();
Getopt::Std::getopts('i:h:s:e:d', \%options);
if (exists($options{'h'})) {
	if (!($options{'h'} =~ /^(0|1)$/)) {
		print STDERR sprintf('ERROR: option -h must be "0" or "1"') . "\n";
		exit 1;
	}
} else {
	$options{'h'} = 0;
}
my $flag_header = $options{'h'};
if (exists($options{'i'})) {
		if (!(-T ($options{'i'}))) {
			print STDERR sprintf('ERROR: input file "%s" is not valid.', $options{'i'}) . "\n";
			exit 1;
		}
} else {
	print STDERR sprintf('ERROR: please input filename. (option -i)') . "\n";
	exit 1;
}
my $filename_input = $options{'i'};
if (exists($options{'s'})) {
		if (!($options{'s'} > 0)) {
			print STDERR sprintf('ERROR: option -s "%s" is not valid number.', $options{'s'}) . "\n";
			exit 1;
		}
} else {
	$options{'s'} = 100000;
}
my $line_split = $options{'s'};
if (exists($options{'e'})) {
	if (!($options{'e'} =~ /^(0|1)$/)) {
		print STDERR sprintf('ERROR: option -e must be "0" or "1"') . "\n";
		exit 1;
	}
} else {
	$options{'e'} = 0;
}
my $flag_excel = $options{'e'};
if (exists($options{'d'})) {
	$options{'d'} = 1;
} else {
	$options{'d'} = 0;
}
my $flag_day = $options{'d'};

my $count_part = 1;
my $count_all = 0;
my $count = 0;
my $line_header = '';
my $column1_old = '';
my $column1 = '';
my $filename_output = &filename_output($filename_input, $count_part, $flag_day, $column1);
my $fh_input = IO::File->new('< ' . $filename_input);
my $fh_output;
my $flag_next = 0;
while(defined(my $line = <$fh_input>)) {
	chomp($line);
	if ($count_all == 0) {
		$fh_output = IO::File->new('> ' . $filename_output);
		if ($flag_header == 1) {
			$line_header = $line;
			$count --;
		}
	}
	if ($flag_day == 1) {
		$column1 = &pickup_column1($line);
		if (&diff_column1($column1, $column1_old) == 1) {
			$flag_next = 1;
		}
		$column1_old = $column1;
	} else {
		if ($count >= $line_split) {
			$flag_next = 1;
		}
	}
	if ($flag_next == 1) {
		$count_part ++;
		$count = 0;
		$fh_output->close;
		if ($flag_excel == 1) {
			&convert_tsv2excel($filename_output);
		}
		$filename_output = &filename_output($filename_input, $count_part, $flag_day, $column1);
		$fh_output = IO::File->new('> ' . $filename_output);
		if ($flag_header == 1) {
			print $fh_output $line_header . "\n";
		}
		$flag_next = 0;
	}
	print $fh_output $line . "\n";
	$count_all ++;
	$count ++;
}
$fh_input->close;
$fh_output->close;
if ($flag_excel == 1) {
	&convert_tsv2excel($filename_output);
}

exit;

sub pickup_column1 {
	my($line) = @_;
	my $column1;
	$line =~ /^([^,|\t]+)(,|\t)/;
	$column1 = $1;
	return $column1;
}

sub diff_column1 {
	my($column1, $column1_old) = @_;
	if ($column1_old eq '') {
		return 0;
	} else {
		if ($column1 ne $column1_old) {
			return 1;
		} else {
			return 0;
		}
	}
}

sub filename_output {
	my($filename_input, $count_part, $flag_day, $column1) = @_;
	my $filename_output = $filename_input;
	my $str_part;
	if ($flag_day == 1) {
		my $day = 0;
		if ($column1 =~ /\/(\d+)$/) {;
			$day = $1;
		}
		$str_part = sprintf('%02d', $day);
	} else {
		$str_part = sprintf('%03d', $count_part);
	}
	$filename_output =~ s/([^\.]+)\.(\w+)/$1_$str_part\.$2/;
	return $filename_output;
}

sub convert_tsv2excel {
	my($filename_tsv) = @_;
	my $filename_excel = $filename_tsv . '.xlsx';
	my $script = './tsv2excel_mah.pl';
	my $return = `cat $filename_tsv | $script $filename_excel`;
	return $return;
}

=pod

=encoding utf8

=head1 NAME

tsv_splitter.pl - TSV/CSV File Splitter

=head1 VERSION

ver.20150626

=head1 DESCRIPTION

TSV/CSVファイルを読み込み, 指定の行数毎に, またはTSV/CSV形式の第一カラムを「YYYY/MM/DD」形式とみなした場合の日付毎に, 分割した内容を複数のファイルに保存します. 保存形式として, Excel形式も選択できます.

約100万行を超えるTSV/CSVファイルはExcelで読み込めず, そのような場合に必要なファイル分割を楽に行うためのものです.

オプション指定により,

=over

=item 読み込み元ファイルの冒頭行を, ヘッダ行として, 保存される分割ファイルの各冒頭行に複製できます.

=item 保存形式として, Excel形式 (.xlsx) も選択できます. (要 tsv2excel_mah.pl)

=back

=head1 USAGE

例a) perl tsv_splitter.pl -i filename.tsv -l 100000 -h 0 -e 0

例b) perl tsv_splitter.pl -i filename.tsv -d -h 1 -e 1

分割ファイルが, 読み込みファイルと同じディレクトリに保存されます.

=over

=item 分割ファイル: filename_000.tsv, filename_001.tsv, ... filename_NNN.tsv

=back

=head2 OPTION

=over

=item -i 読み込むファイル

=item -d 読み込むファイルをログファイルとみなし, ファイル分割を日毎に行うか (0 = 行わない (default), 1 = 行う) / -d の存在は -l よりも優先されます

=item -l 分割する行数 (default = 100000)

=item -h [0|1] 読み込み元ファイルの冒頭行を, 分割ファイルに複製するか (0 = 複製しない (default), 1 = 複製する)

=item -e [0|1] 分割ファイルを変換したExcelファイルも保存するか (0 = 保存しない (default), 1 = 保存する)

=back

=head1 AUTHOR

Masahiko OHKUBO <ohkubo.masahiko@icraft.jp> <https://twitter.com/mah_jp>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Masahiko OHKUBO.

This is free software; you can redistribute it and/or modify it under the same terms as the Perl 5 programming language system itself.

=cut
