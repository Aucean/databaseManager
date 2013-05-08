use DBI;
my @cycles = (25, 16, 20, 20, 20);
my $dbh;
sub doexit($)
{
	$dbh->disconnect();
	die $_;
}
sub createStockStateTable()
{
    print "createStockStateTable\n";
    $dbh->do("create table stockstate (servicetype int, name varchar(15), length int, state int, price double(9,4))")
            || doexit("create stockstate table failed");
}
sub initStockStateTable()
{
    print "initStockStateTable\n";
    my $query = $dbh->prepare("select name from stockname");
    $query->execute();
    while(my $ref = $query->fetchrow_hashref())
    {
        foreach my $data_type (0 .. $#cycles)
        {
            $dbh->do("insert into stockstate value($data_type, \"$ref->{'name'}\", 60, 0, 0.0)");
        }
    }
    print "initStockStateTable Exit\n";
}
sub deleteStockStateTable()
{
    print "deleteStockStateTable\n";
    $dbh->do("drop table stockstate");
    print "deleteStockStateTable exit\n";
}
sub createPriceBuffTable()
{
    print "createPriceBuffTable\n";
    my $query = $dbh->prepare("select name from stockname");
    $query->execute();
    while(my $ref = $query->fetchrow_hashref())
    {
        foreach my $datatype (0 .. $#cycles)
        {
            $dbh->do("create table filteredPriceBuffList_$ref->{'name'}_${datatype} (priceID int not null auto_increment \
                     primary key, price double(9,4), timeStamp varchar(20))") 
                || doexit("Can create ilteredPriceBuffList_$ref->{'name'}_${datatype} table");
        }
    }
    print "createPriceBuffTable exit\n";
}
sub deletePriceBuffTable()
{
    print "deletePriceBuffTable\n";
    my $query = $dbh->prepare("select name from stockname");
    $query->execute();
    while(my $ref = $query->fetchrow_hashref())
    {
        foreach my $datatype (0 .. $#cycles)
        {
            $dbh->do("drop table filteredPriceBuffList_$ref->{'name'}_${datatype}") 
                || doexit("Can delete ilteredPriceBuffList_$ref->{'name'}_${datatype} table");
        }
    }
     print "deletePriceBuffTable exit\n";
}
sub createPriceTmpBuffTable()
{
    print "createPriceTmpBuffTable\n";
    foreach my $datatype (0 .. $#cycles)
    {
        my $cycle_length = $cycles[$datatype];
        my $item = "create table filteredPriceTmpBuff_${datatype} (name varchar(15)";
        foreach my $count (0 .. $cycle_length - 1)
        {
            $item .= ",buff${count} double(9,4)";
        }
        $item .= ")";
        $dbh->do($item) || doexit("Can't create filteredPriceTmpBuff_${datatype} table");
    }
    print "createPriceTmpBuffTable exit\n";
}
sub deletePriceTmpBuffTable()
{
    print "deletePriceTmpBuffTable\n";
    foreach my $datatype (0 .. $#cycles)
    {
        $dbh->do("drop table filteredPriceTmpBuff_${datatype}")
            || doexit("Can't create filteredPriceTmpBuff_${datatype} table");
    }
    print "deletePriceTmpBuffTable exit\n";
}
sub initPriceTmpBuffTable()
{
    print "initPriceTmpBuffTable\n";
    my $query = $dbh->prepare("select name from stockname");
    $query->execute();
    while(my $ref = $query->fetchrow_hashref())
    {
        foreach my $data_type (0 .. $#cycles)
        {
            my $buff = ",0.0" x $cycles[$data_type];
            $sSql = "insert into filteredPriceTmpBuff_${data_type} value(\"$ref->{'name'}\" ${buff} )";
            $dbh->do($sSql);      
        }
    }
    print "initPriceTmpBuffTable exit\n";
}
my $db_name = "filteredstockprice";
$dbh = DBI->connect("DBI:mysql:database=${db_name};host=localhost","root","sqrt2=1.414",{'RaiseError' => 1}) 
		|| die("can't open the stockprice database");
deletePriceTmpBuffTable();        
createPriceTmpBuffTable();
initPriceTmpBuffTable();

#deleteStockStateTable;
createStockStateTable();
initStockStateTable();

#deletePriceBuffTable();
createPriceBuffTable();

$dbh->disconnect();

