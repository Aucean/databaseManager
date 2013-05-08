use DBI;

my ($mday, $mon, $year) = (localtime)[3..5];
$year += 1900;
$mon += 1;
my $timestamp = sprintf("%04d-%02d-%02d", $year, $mon, $mday);

my $file_name = sprintf("E:\\dailyExportData\\%04d%02d%02d", $year, $mon, $mday);
open FD, ">", $file_name || die "Can't open file: $file_name";

my $dbh = DBI->connect("DBI:mysql:database=stockdata;host=localhost","root","sqrt2=1.414",{'RaiseError' => 1}) 
		|| die("can't open the stockprice database");
my $query = $dbh->prepare("select name from stockname");
$query->execute();

my $name;
while(my $ref = $query->fetchrow_hashref())
{
    $name = $ref->{'name'};
    my $sql = "select openPrice,closePrice,maxPrice,minPrice from ${name}daily where tradeDate like '$timestamp'";
    @result = $dbh->selectrow_array($sql);
    my $data = join "\t", @result;
    $name =~ /s[hz](.*)/;
    print FD "$1\t$data\n"; 
}
close FD;