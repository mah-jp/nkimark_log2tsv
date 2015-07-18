#!/usr/bin/env perl

# tsv2excel_mah.pl
# original: https://github.com/smeghead/tsv2excel/blob/master/tsv2excel.pl

use strict;
use warnings;
use utf8;
use Encode;
#use Spreadsheet::WriteExcel;
use Excel::Writer::XLSX;
use Data::Dumper;

sub usage {
    print STDERR "usage: \n";
    print STDERR " cat <csv filename> | $0 <output filename>\n";
    exit -1;
}

my $output_filename = shift;
my $csv_content = do {
    local $/;
    <STDIN>;
};

print Dumper($output_filename);
print Dumper($csv_content);

usage() unless $output_filename;
usage() unless $csv_content;

my $storage_book = {};

#prepare data
my $row_count = 0;
my $rows = {};
for my $line (split /\n/, $csv_content) {
    my $col_count = 0;
#    for my $field (split /,\s*/, $line) {
    for my $field (split /\t/, $line) {
#        $rows->{$row_count}->{$col_count++} = $field;
        $rows->{$row_count}->{$col_count++} = Encode::decode('cp932', $field);
    }
    $row_count++;
}
$storage_book->{click} = $rows;

#my $dest_book  = Spreadsheet::WriteExcel->new("$output_filename")
#    or die "Could not create a new Excel file in $output_filename: $!";
my $dest_book  = Excel::Writer::XLSX->new("$output_filename")
    or die "Could not create a new Excel file in $output_filename: $!";
print "\n\nSaving recognized data in $output_filename...";
foreach my $sheet (keys %$storage_book) {
    my $dest_sheet = $dest_book->add_worksheet($sheet);
    foreach my $row (keys %{$storage_book->{$sheet}}) {
        foreach my $col (keys %{$storage_book->{$sheet}->{$row}}) {
#            $dest_sheet->write($row, $col, Encode::decode('cp932', $storage_book->{$sheet}->{$row}->{$col}));
            $dest_sheet->write($row, $col, $storage_book->{$sheet}->{$row}->{$col});
        }
    }
}
$dest_book->close();
print " done!\n";

exit;

=pod

=encoding utf8

=head1 NAME

tsv2excel_mah.pl - TSV/CSV to Excel Converter

=head1 VERSION

ver.20150719

=head1 DESCRIPTION

TSV/CSV形式のファイルをExcel (.xlsx) 形式に変換します。

次のスクリプトを改造した物です。

https://github.com/smeghead/tsv2excel/blob/master/tsv2excel.pl

=head1 USAGE

cat <csv filename> | tsv2excel_mah.pl <output filename>

=head1 AUTHOR

大久保 正彦 (Masahiko OHKUBO) <ohkubo.masahiko@icraft.jp> <https://twitter.com/mah_jp>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Masahiko OHKUBO.

This is free software; you can redistribute it and/or modify it under the same terms as the Perl 5 programming language system itself.

=cut
