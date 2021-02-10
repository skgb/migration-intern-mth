#!/usr/bin/env perl
use v5.24;
use warnings;
use utf8;

binmode STDOUT, ":utf8";
use Encode;
use XXX;

use Neo4j::Driver;
use Neo4j_Auth;
my %neo4j_auth = neo4j_auth;
my %config = (cypher_filter => 'params');
my $uri = 'bolt:';

my $session = Neo4j::Driver->new($uri)->basic_auth(%neo4j_auth)->config(%config)->session;


my @MTH = (
	"Mitgliedsnummer",
	"Organisation",
	"Anrede",
	"Titel",
	"Vorname",
	"Nachname",
	"Strasse",
	"PLZ",
	"Ort",
	"E-Mail",
	"Telefon privat",
	"Telefon geschäftlich",
	"Telefon mobil",
	"Fax",
	"Geburtsdatum",
	"Adresszusatz",
	"frei definierbar 1",
	"Brief Anrede",
	"Adresse in Serienbrief verwenden",
	"Eintrittsdatum",
	"aktives Mitglied",
	"passives Mitglied",
	"kein Mitglied",
	"Ehrenmitglied",
	"Sportart 1 (Meldung)",
	"Sportart 2 (Meldung)",
	"Sportart 3 (Meldung)",
	"Sportart 4 (Meldung)",
	"Gruppe 1",
	"Gruppe 2",
	"Gruppe 3",
	"Gruppe 4",
	"Gruppe 5",
	"Gruppe 6",
	"Gruppe 7",
	"Funktion 1",
	"Anfangsdatum 1",
	"Enddatum 1",
	"Funktion 2",
	"Anfangsdatum 2",
	"Enddatum 2",
	"Funktion 3",
	"Anfangsdatum 3",
	"Enddatum 3",
	"Funktion 4",
	"Anfangsdatum 4",
	"Enddatum 4",
	"Info zu Funktionen",
	"Besonderheiten",
	"Anmerkung 1",
	"Anmerkung 2",
	"Mandatsstatus",
	"Mandatsreferenz",
	"Datum SEPA Mandat",
	"IBAN",
	"Kontoinhaber",
	"Verwendungszweck",
	"frei definierbar 7",
	"Zahlungsart",
	"Zahlungsperiode",
	"individueller Beitrag",
	"Beitragsart 1",
	"Beitragsart 2",
	"Beitragsart 3",
	"Beitragsart 4",
	"Beitragsart 5",
	"Beitragsart 6",
	"frei definierbar 17",
	"Sonstiges",
	"frei definierbar 16",
	"frei definierbar 18",
	"Ehrungen",
	"Info zu Ehrungen",
	"frei definierbar 12",
	"Aktiv seit",
	"frei definierbar 9",
	"in Ausbildung",
	"verheiratet",
	"frei definierbar 14",
	"frei definierbar 13",
	"Lehrgänge",
	"Anmerkungen zu Lehrgänge",
	"frei definierbar 15",
	"Größe Trikot",
	"frei definierbar 8",
	"frei definierbar 10",
	"frei definierbar 11",
	"frei definierbar 19",
	"Löschfeld 1",
	"Löschfeld 2",
	"Löschfeld 3",
	"Löschfeld 4",
	"Löschfeld 5",
	"Ausscheidedatum",
);

my %MTH = (
	name => 5,
	street_extra => 15,
	street => 6,
	postcode => 7,
	place => 8,
	email => 9,
	joined => 19,
	left => 93,
);



sub primary_private_addr {
	my ($name, $context, @addr) = @_;
	no warnings 'uninitialized';
	my @addr_p = grep { $_->get('f')->get('primary') } @addr;
	@addr = @addr_p if @addr_p;
	@addr_p = grep { $_->get('f')->get('kind') eq 'privat' } @addr;
	@addr = @addr_p if @addr_p;
	warn "$context address ambiguous for $name" if @addr > 1;
	return @addr;
}

sub iso2din {
	my $iso = shift;
	return unless $iso;
	my ($y, $m, $d) = $iso =~ m/^([0-9]{4})-([0-9]{2})-([0-9]{2})$/;
	return "$d.$m.$y";
}



my @persons;
for my $node ( map { $_->get } $session->run('MATCH (p:Person) RETURN p')->list ) {
	my @id = (id => $node->id);
	my $name = $node->get('name');
	my $q;
	
	no warnings 'uninitialized';
	
	# vom Vorstand angeforderte Kategorien (Mail 28. Dez.):
	# - Name
	# - Straße / Ort
	$q = 'MATCH (p)<-[f:FOR]-(a:Address) WHERE id(p) = {id} RETURN f, a';
	my @addr = eval { $session->run($q, @id)->list };
	my @street = grep { $_->get('a')->get('type') eq 'street' } @addr;
	@street = primary_private_addr $name, 'street', @street;
	my ($street_extra, $street, $postcode, $place);
	if (@street) {
		@street = split m/\n/, $street[0]->get('a')->get('address');
		$street_extra = shift @street if @street > 2 && $street[2] =~ m/^\d+/;
		$street_extra = pop @street if @street > 2 && $street[1] =~ m/^\d+/;
		($street, $place) = @street;
		($postcode, $place) = ($1, $2) if $place =~ m/(\d+(?: [A-Z]{2})?) (.*)/;
	}
	
	# - E-Mail
	my @email = grep { $_->get('a')->get('type') eq 'email' } @addr;
	@email = primary_private_addr $name, 'email', @email;
	my $email = $email[0]->get('a')->get('address') if @email;
	
	# - Telefon / Fax
	# - Alter
	# - Erziehungsberechtigte
	# - Anrede in Brief oder Mail
	# - Eintritt / Austritt
	$q = 'MATCH (p)-[r:ROLE|GUEST]->()-[:ROLE*]->(:Role{role:"member"}) WHERE id(p) = {id} RETURN r.joined';
	my $joined = iso2din eval { $session->run($q, @id)->single->get };
	$q = 'MATCH (p)-[r:ROLE|GUEST]->()-[:ROLE*]->(:Role{role:"member"}) WHERE id(p) = {id} RETURN r.leaves';
	my $left = iso2din eval { $session->run($q, @id)->single->get };
	
	# - Mitgliedsstatus
	# - Mandatsreferenz
	# - Bankverbindung
	# - Jahreslastschrifthöhe
	# - Beitragsarten
	
	push @persons, {
		name => $name,
		street_extra => $street_extra,
		street => $street,
		postcode => $postcode,
		place => $place,
		email => $email,
		joined => $joined,
		left => $left,
	};
}



my @data;
for my $person (@persons) {
	my @row;
	$row[$MTH{$_}] = $person->{$_} for keys %$person;
	push @data, \@row;
}
my @table = (\@MTH, @data);

my $filename = 'example';
my ($write_csv, $write_odf, $write_txt, $write_demo);
use Getopt::Long 2.33 qw( :config posix_default gnu_getopt auto_version auto_help );
GetOptions 'demo|d' => \$write_demo,
           'csv|c' => \$write_csv, 'odf|o' => \$write_odf, 'txt|t' => \$write_txt;

if ($write_odf) {
	use OpenOffice::OODoc;
	my $doc = odfDocument(create => 'spreadsheet', file => "$filename.ods");
	my $sheet = $doc->expandTable(0, scalar(@table), scalar(@MTH));
	my @rows = $doc->getTableRows($sheet);
	for my $i (0 .. $#rows) {
		my @cells = $doc->getRowCells($rows[$i]);
		$doc->cellValue($cells[$_], encode 'UTF-8', $table[$i][$_]) for 0 .. @MTH;
	}
	$doc->renameTable($sheet, 'MTH');
	$doc->save;
	eval { system "open $filename.ods" };
}

if ($write_csv) {
	use Text::CSV qw(csv);
	csv in => \@table, out => "$filename.csv", sep_char=> ",", encoding => "UTF-8";
}

if ($write_txt || ! $write_odf && ! $write_csv) {
	use File::Slurp qw(write_file);
	use List::Util qw(head);
	@data = head 8, @data if $write_demo;  # MTH demo limit: 10
	no warnings 'uninitialized';
	my @lines = map { join "\t", head scalar(@MTH), @$_ } @data;
	write_file "$filename.txt", {binmode => ':utf8'}, map "$_\n", @lines;
	eval { system "open $filename.txt" };
}

exit 0;
