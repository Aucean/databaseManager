use DBI;
my $dbh = DBI->connect("DBI:mysql:database=stockprice;host=localhost","root","sqrt2=1.414",{'RaiseError' => 1}) 
		|| die("can't open the stockprice database");
my $query = $dbh->prepare("select name from stockname where name like 'sh60001%'");
$query->execute();
my $name;
while(my $ref = $query->fetchrow_hashref())
{
    $name = $ref->{'name'};
    $file_name = "E:\\testData\\"; 
    $file_name .= $name ;
    $file_name .= "_filtered.data";
    open FD, ">", $file_name ;#|| dir "Can't open file: $file_name";
    my $sql = "select price from filteredPriceBuffList_${name}_0";
    @result = @{$dbh->selectall_arrayref($sql, { Slice => {}})};
    #$result[0] = $result[1];
    my $data = "";
    foreach my $iter (@result)
    {
        $data .= "$iter->{price}\n";
    }
    print FD "$data";
    $sql = "select * from filteredPriceTmpBuff_0 where name=\"${name}\"";
    @result = $dbh->selectrow_array($sql);
    shift @result;
    $data = join "\n", @result;
    print FD "$data\n";
    close FD;
}
    