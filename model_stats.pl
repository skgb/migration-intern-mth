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


my $node_labels = $session->run('CALL db.labels() YIELD label RETURN collect(label)')->single->get;
my $rel_types = $session->run('CALL db.relationshipTypes() YIELD relationshipType RETURN collect(relationshipType)')->single->get;

my $node_count;
my $node_prop_count;
my $node_props;
for my $label (@$node_labels) {
	next if $label eq 'Paradox';
	
	my @q0 = ('MATCH (n) WHERE {label} IN labels(n) RETURN count(n)', label => $label);
	$node_count->{$label} = $session->run(@q0)->single->get;
	
	my @q1 = ('MATCH (n) WHERE {label} IN labels(n) WITH keys(n) AS keys RETURN keys', label => $label);
	$node_prop_count->{$label}{$_}++ for map { @{$_->get} } $session->run(@q1)->list;
	
	my @keys = keys $node_prop_count->{$label}->%*;
	for my $key (@keys) {
		my @q2 = ('MATCH (n) WHERE {label} IN labels(n) AND exists(n[{key}]) RETURN n[{key}]', label => $label, key => $key);
		my $values;
		$values->{$_}++ for map { $_->get } $session->run(@q2)->list;
		$node_props->{$label}{$key} = [sort keys %$values];
	}
}

my $rel_count;
my $rel_prop_count;
my $rel_props;
for my $type (@$rel_types) {
	
	my @q0 = ('MATCH ()-[e]-() WHERE {type} = type(e) RETURN count(e)', type => $type);
	$rel_count->{$type} = $session->run(@q0)->single->get >> 1;
	
	my @q1 = ('MATCH ()-[e]-() WHERE {type} = type(e) WITH keys(e) AS keys RETURN keys', type => $type);
	$rel_prop_count->{$type}{$_}++ for map { @{$_->get} } $session->run(@q1)->list;
	$rel_prop_count->{$type}{$_} >>= 1 for keys $rel_prop_count->{$type}->%*;
	
	my @keys = keys $rel_prop_count->{$type}->%*;
	for my $key (@keys) {
		my @q2 = ('MATCH ()-[e]-() WHERE {type} = type(e) AND exists(e[{key}]) RETURN e[{key}]', type => $type, key => $key);
		my $values;
		for my $value (map { $_->get } $session->run(@q2)->list) {
			if (ref $value eq 'ARRAY') { $values->{$_}++ for @$value; next }  # .courses
			$values->{$value}++;
		}
		$rel_props->{$type}{$key} = [sort keys %$values];
	}
}

YYY {
	node_count      => $node_count,
	node_prop_count => $node_prop_count,
#	node_props      => $node_props,
	rel_count       => $rel_count,
	rel_prop_count  => $rel_prop_count,
#	rel_props       => $rel_props,
};

exit 0;
