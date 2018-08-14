#!/usr/bin/perl 

use strict;
use warnings;
use Text::CSV;

my $filename = 'csv_example.csv';


# open the CSV file for reading
open (my $data, '<', $filename)
    or die "Cannot open file $filename: $!\n";

# read the first line from the file; that line contains the names of the columns
my $firstline = <$data>;
chomp $firstline;
# split the line and save the names of the columns in an array
my @columns = split ";", $firstline;
print "The first line is: \n";
print "@columns\n\n";

# this array will contain multiple anonymous hashes
# the hashes will contain the data from the CSV file
my @rows;

# this array will hold all the rows read from the CSV file as simple strings
# it will be used to create an updated CSV file later on
my @aux_rows;

print "The rest of the lines:\n";

# read the file line by line 
while (my $line = <$data>){

    chomp $line;
    
    # add the line to the auxiliary array
    push @aux_rows, $line;

    # split the line using ";" as a separator
    my @row = split ";", $line;
    print "@row\n\n";

    # create a reference to an anonymous hash
    my $hash_r = {};
    
    foreach my $i (0 .. $#columns){
        # create the key - value pairs and add them to the hash
        $hash_r->{$columns[$i]} = $row[$i];        
    }

    # add the hash to the array of hashes
    push @rows, $hash_r;
}

# create a reference to the array of hashes
my $rows = \@rows;

# print the array of hashes
print_array_of_hashes($rows);

# print the rows that contain '205/70 R 15'
print_wanted_records($rows);

# create a new column called 'IPC Manufacturier clean' and add it to each hash
create_new_column($rows);

# print the array of hashes again to see if the new column was added
# to the hashes correctly
print_array_of_hashes($rows);

# create a new CSV file including the new column called 'IPC Manufacturier clean'
create_new_csv(\@aux_rows, $rows, $#rows);

# close the filehandle
close ($data) or warn "Close failed: $!";

# This subroutine is used to create an updated CSV file 
# using the info from the old one.
# It will have an extra column called 'IPC Manufacturier clean'
sub create_new_csv{
    # retrieve the params that were passed to the sub
    my ($array_of_strings, $array_of_hashes, $no_of_records) = @_;
    
    # create new csv object
    my $csv = Text::CSV->new({binary => 1, 
                              eol => "\n",
                              sep_char => ";"})
        or die "Cannot use CSV: ".Text::CSV->error_diag();

    # create a new file and open it for writing
    my $newfile = 'new_csv.csv';
    open my $out, '>', $newfile
        or die "Cannot open file $newfile: $!\n";

    # firstly, write the line that contains the column names
    push @columns, 'IPC Manufacturier clean';
    $csv->print($out, \@columns);

    # write to the new csv file using the info in the auxiliary array of strings;
    # add corresponding info from the new column 
    for my $i (0 .. $no_of_records){
        my $href = @$array_of_hashes[$i];
        my @row = split ";", @$array_of_strings[$i];
        push @row, $href->{'IPC Manufacturier clean'};
        $csv->print($out, \@row); 
    }

    close ($out) or warn "Close failed: $!";
} 

# This subroutine is used to:
# - extract only digits from column 'IPC Manufacturier'
# - save the digits in a new column 'IPC Manufacturier clean'
# - add the new column to the hashes in the array
sub create_new_column{
    # retrieve the parameter that was passed to the sub
    my ($array_ref) = @_;

    print "IPC Manufacturier - IPC Manufacturier clean:\n\n";
    # extract only digits from column 'IPC Manufacturier'    
    foreach my $href (@$array_ref){
        my $ipc_m_clean = $href->{"IPC Manufacturier"};

        # extract only digits by substituting the non-digits with nothing
        $ipc_m_clean =~ s/\D//g;

        # print the two columns in the console
        print $href->{"IPC Manufacturier"}, " - ", "$ipc_m_clean\n"; 

        # add the new column to the hash
        $href->{"IPC Manufacturier clean"} = $ipc_m_clean;
    }
}

# This subroutine is used to print all rows (hashes) that contain '205/70 R 15'
sub print_wanted_records{
    # retrieve the parameter that was passed to the sub
    my ($array_ref) = @_;

    print "The rows that contain '205/70 R 15':\n\n";

    foreach my $href (@$array_ref){
        if ($href->{"Libelle complet"} =~ '205/70 R 15'){
            print "{";
            for my $key (keys %$href){
                print $key. "=>". $href->{$key}. " | ";     
            }
        print "}\n\n";
        }
    }
}

# This subroutine is used to print all the hashes in the array
sub print_array_of_hashes{
    # retrieve the parameter that was passed to the sub
    my ($array_ref) = @_;

    print "\n\nThe resulting array of hashes:\n\n";

    foreach my $href (@$array_ref){
        print "{";
        for my $key (keys %$href){
            print $key, "=>", $href->{$key}, " | ";     
        }
        print "}\n\n";
    }
}
