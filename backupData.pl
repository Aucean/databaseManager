
use DBI;
my $dbh;
my $sSql;
$dbh = DBI->connect("DBI:mysql:database=stockdata;host=localhost","root","sqrt2=1.414",{'RaiseError' => 1}) 
		|| die("can't open the stockprice database");
$dbh_price = DBI->connect("DBI:mysql:database=stockprice;host=localhost","root","sqrt2=1.414",{'RaiseError' => 1}) 
		|| die("can't open the stockprice database");
my $query = $dbh->prepare("select name from stockname where id < 100");
$query->execute();
my $i = 1;
while(my $ref = $query->fetchrow_hashref())
{
   `mysqldump -h localhost -u root --password=sqrt2=1.414 stockdata $ref->{'name'} > sqlbackup`;
   `mysql -u root -psqrt2=1.414 stockprice < sqlbackup`;
    $dbh_price->do("insert into stockname value($i, \"$ref->{'name'}\")");
    $dbh_price->do("alter table $ref->{'name'} add id int not null auto_increment primary key");
    $i += 1;
}
$dbh->disconnect();
$dbh->disconnect();

