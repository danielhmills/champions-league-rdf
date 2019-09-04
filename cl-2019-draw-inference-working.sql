-- Clear Graphs
SPARQL CLEAR GRAPH <spin:rule:inference:cl-draw>;
SPARQL DROP SPIN LIBRARY <spin:rule:inference:cl-draw> ;
SPARQL ALTER QUAD STORAGE virtrdf:DefaultQuadStorage { DETACH MACRO LIBRARY <spin:rule:inference:cl-draw> };


--Test Query

SPARQL
prefix cl: <https://raw.githubusercontent.com/danielhmills/champions-league-rdf/master/cl-ontology.ttl#>
prefix dbo: <http://live.dbpedia.org/ontology/>

SELECT DISTINCT ?team1 ?team2

WHERE

{
?team1 a schema:SportsTeam;
cl:hasGroup ?group1;
cl:inPot ?pot1;
^owl:sameAs ?dbpTeam1.

?dbpTeam1 dbo:league ?league1.

?team2 a schema:SportsTeam;
cl:hasGroup ?group2;
cl:inPot ?pot2;
^owl:sameAs ?dbpTeam2.

?dbpTeam2 dbo:league ?league2

FILTER(?group1 != ?group2 && ?pot1 != ?pot2 && ?league1 != ?league2)
};



--Create Rule

SPARQL
PREFIX : <#>
PREFIX spin:  <http://spinrdf.org/spin#>
PREFIX sp: <http://spinrdf.org/sp#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>

WITH <spin:rule:inference:cl-draw>
INSERT{
        schema:SportsTeam a owl:Class;
        rdfs:label "Champions League 2019 Team";
        rdfs:comment """This Rule ensures that teams identified""";

        spin:rule[
                    a sp:Construct;
                    sp:text """
                                prefix cl: <https://raw.githubusercontent.com/danielhmills/champions-league-rdf/master/cl-ontology.ttl#>
                                prefix dbo: <http://live.dbpedia.org/ontology/>

                                CONSTRUCT {
                                            ?team1 cl:canPlay ?team2
                                           }

                                WHERE

                                    {
                                        ?team1 a schema:SportsTeam;
                                        cl:hasGroup ?group1;
                                        cl:inPot ?pot1;
                                        ^owl:sameAs ?dbpTeam1.

                                        ?dbpTeam1 dbo:league ?league1.

                                        ?team2 a schema:SportsTeam;
                                        cl:hasGroup ?group2;
                                        cl:inPot ?pot2;
                                        ^owl:sameAs ?dbpTeam2.

                                        ?dbpTeam2 dbo:league ?league2.

                                        FILTER(?group1 != ?group2 && ?pot1 != ?pot2 && ?league1 != ?league2).
                                    }

                            """
                     
                ]
};

EXEC ('SPARQL ' || SPARQL_SPIN_GRAPH_TO_DEFSPIN('spin:rule:inference:cl-draw'));


--Test 01: With Rule
SPARQL
DEFINE input:macro-lib 'spin:rule:inference:cl-draw'
PREFIX cl: <https://raw.githubusercontent.com/danielhmills/champions-league-rdf/master/cl-ontology.ttl#>

SELECT DISTINCT ?team2
#FROM <demo:inference:aggregates>
WHERE 
{
?team1 a schema:SportsTeam; cl:canPlay ?team2.
};


--Test 02: Without Rule
SPARQL
#DEFINE input:macro-lib 'spin:rule:inference:cl-draw'
PREFIX : <#>
PREFIX cl: <https://raw.githubusercontent.com/danielhmills/champions-league-rdf/master/cl-ontology.ttl#>

SELECT DISTINCT ?team
#FROM <demo:inference:aggregates>
WHERE 
{
<https://www.uefa.com/uefachampionsleague/season=2020/clubs/club=52816/#team> a schema:SportsTeam; cl:canPlay ?team.
};