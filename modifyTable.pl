use DBI;
my $dbh;
my $sSql;
$dbh = DBI->connect("DBI:mysql:database=stockprice;host=localhost","root","sqrt2=1.414",{'RaiseError' => 1}) 
		|| die("can't open the stockprice database");
my $query = $dbh->prepare("select name from stockname");
$query->execute();
while(my $ref = $query->fetchrow_hashref())
{
    $dbh->do("alter table $ref->{'name'} add id int not null auto_increment primary key");
}
$dbh->disconnect();