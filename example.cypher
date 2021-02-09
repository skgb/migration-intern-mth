:begin
MATCH (n) DETACH DELETE n
;
CREATE (c:Club {name:'Segel- und Kanugemeinschaft Brucher Talsperre', abbr:'SKGB'})
CREATE (p:Person {born:'1964', debitBase:26, debitReason:'Sondervereinbarung, E-Mail 2020-02-20', debitorSerial:'388', gender:'W', gsvereinId:'488', name:'Erika Mustermann', prefix:'Dr.', salutation:'Tachchen Agnes', userId:'erika.mustermann'})
CREATE (p)-[:GUEST {joined:'2019-05-28', leaves:'2020-12-31', courses:['2019'], assemblyFeedback:'Unklarheiten Segelkurs (2019)', regularContributor:false, reducedFee:true, winterStorage:'ja', noDuties:true, noService:false}]->(:Role {name:"Passives Mitglied", role:"passive-member"})-[:ROLE {fee: 36}]->(:Role {name:"Mitglied", role:"member"})
CREATE (p)-[:ROLE]->(:Role {name:"2. Vorsitzender", role:"board-secretary"})-[:ROLE]->(g:Role {name:"geschäftsführender Vorstand", role:"executive-board-member"})-[:ROLE]->(:Role {name:"Vorstand", role:"board-member"})
CREATE (g)-[:ROLE]->(:Role {role:'payment-data', name:'Zahlungsdaten-Bearbeiter'})
CREATE (p)-[:ROLE]->(:Role {name:"User", role:"user"})-[:ROLE]->(:Role {role:'mojo:auth', name:'mojo:auth'})
CREATE (p)<-[:FOR {kind:'privat', primary:'text'}]-(:Address {address:'erika@mustermann.example', type:'email'})
CREATE (p)<-[:FOR {kind:'mobil', wrong:true}]-(:Address {address:'0170 1368746', type:'phone'})
CREATE (p)<-[:FOR {kind:'mobil'}]-(:Address {address:'+31 6 27581476', type:'phone'})
CREATE (p)<-[:FOR {kind:'privat'}]-(:Address {address:'02203 9728564', type:'phone', comment:'Geheimnummer'})
CREATE (p)<-[:FOR {kind:'privat', primary:'street'}]-(:Address {address:'Wahn\nHeidestraße 17\n51147 Köln', type:'street', place:'Köln'})
CREATE (p)<-[:FOR]-(n:Address {address:'Piet Miedemaweg 15\n9264 TJ Earnewald\nDie Niederlande', type:'street', place:'Friesland (NL)'})
CREATE (p)<-[:FOR {kind:'beruflich'}]-(:Address {address:'c/o Flughafen\nPostfach 980120\n51129 Köln', type:'street', place:'Köln'})
CREATE (p)<-[:FOR {kind:'beruflich'}]-(:Address {address:'emustermann@example.com', type:'email'})
CREATE (p)<-[:FOR {kind:'beruflich', primary:'voice'}]-(:Address {address:'02203 40-8713', type:'phone'})
CREATE (p)<-[:FOR {kind:'beruflich'}]-(:Address {address:'02203 40-4044', type:'fax'})
CREATE (p)<-[:HOLDER]-(:Mandate {umr:14005, iban:'DE20', terminated:true, comment:'Missverständnis'})
CREATE (p)<-[:DEBITOR {comment:'Erikas Name ist nicht eingetragen'}]-(:Mandate {umr:14006, iban:'NL34'})-[:HOLDER {comment:'explizit nicht gültig für eigene Zahlungsverpflichtungen'}]->(o:Person {name:'Lieschen von Müller', nameSortable:'Müller, Lieschen'})
CREATE (o)<-[:FOR {primary:'text'}]-(:Address {address:'lvm@example.org', type:'email', comment:'nur für Lastschrift-Ankündigungen'})
CREATE (o)<-[:FOR]-(n)
CREATE (p)-[:PARENT]->(k:Person {name:'Cleopâtre Mustermann'})
CREATE (p)-[:COLLECTOR]->(k)
CREATE (p)-[:OWNS]->(:Boat {mark:'Polaris', name:'Polaris', sailnumber:'GER 2534', registration:'635274-S', class:'Contender', loa:4.88, width:1.44, draught:1.2, minDraught:0.3, canoe:false, engine:false, comment:'wild geflickt, Yardstick +2'})-[:OCCUPIES]->(:Berth {ref:'H4', width:1.9})
CREATE (p)-[:SAILS]->(d:Boat {mark:'Vereins-420er', class:'420er', count:3, comment:'Sammel-Node für vereinseigene 420er der Jugendgruppe'})-[:OCCUPIES]->(:Berth {ref:'W', comment:'Jollenwiese'})
CREATE (c)-[:OWNS]->(d)
CREATE (p)-[:OWNS {since:'2019-04-23', deposit:50, currency:'DM', returned:true, comment:'Schlüssel liegt bei Alex'}]->(:ClubKey {nr:2, make:'CES'})
CREATE (p)-[:OWNS {since:'2020-07-30', deposit:50, currency:'EUR', new:true}]->(:ClubKey {nr:1, make:'SILCA'})
;
:commit
