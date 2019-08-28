-- Clear Graphs
SPARQL CLEAR GRAPH <spin:rule:inference:cl-draw>;
SPARQL DROP SPIN LIBRARY <spin:rule:inference:cl-draw> ;
SPARQL ALTER QUAD STORAGE virtrdf:DefaultQuadStorage { DETACH MACRO LIBRARY <spin:rule:inference:cl-draw> };


--Test Query

SPARQL
DEFINE get:soft "replace"
DEFINE input:grab-var "?s"
DEFINE input:grab-depth 1

SELECT DISTINCT 
?s 


FROM <https://github.com/danielhmills/champions-league-rdf/raw/master/cl-2019-draw.ttl>
{
    ?s 
    a <https://github.com/danielhmills/champions-league-rdf/raw/master/cl-2019-draw.ttl#ChampionsLeague2019Team>; 
    <https://github.com/danielhmills/champions-league-rdf/raw/master/cl-2019-draw.ttl#hasGroup> ?group.


};




--Create Rule

SPARQL
PREFIX : <#>
PREFIX spin:  <http://spinrdf.org/spin#>
PREFIX sp: <http://spinrdf.org/sp#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>

WITH <spin:rule:inference:cl-draw>
INSERT{
        <https://github.com/danielhmills/champions-league-rdf/raw/master/cl-2019-draw.ttl#ChampionsLeague2019Team> a owl:Class;
        rdfs:label "Champions League 2019 Team";
        rdfs:comment """This Rule ensures that teams identified""";

        spin:rule[
                    a sp:Construct;
                    sp:text """
                                PREFIX dbo: <http://live.dbpedia.org/ontology/> 
                                PREFIX : <#>

                                CONSTRUCT {?team1 :canPlay ?team2}
                                WHERE
                                    {
                                        ?team1 
                                        a <https://github.com/danielhmills/champions-league-rdf/raw/master/cl-2019-draw.ttl#ChampionsLeague2019Team>;
                                        <https://github.com/danielhmills/champions-league-rdf/raw/master/cl-2019-draw.ttl#hasGroup> ?groupA;
                                        dbo:league ?league.
										
                                        ?team2 
                                        a <https://github.com/danielhmills/champions-league-rdf/raw/master/cl-2019-draw.ttl#ChampionsLeague2019Team>;
                                        <https://github.com/danielhmills/champions-league-rdf/raw/master/cl-2019-draw.ttl#hasGroup> ?groupB;
                                        dbo:league ?league2.

                                        FILTER NOT EXISTS
                                            {
                                                ?team2 dbo:league ?league.
                                            }

                                        FILTER NOT EXISTS
                                            {
                                                ?team2 <https://github.com/danielhmills/champions-league-rdf/raw/master/cl-2019-draw.ttl#hasGroup> ?groupA.
                                            }
                                    }
 
                            """
                     
                ]
};

EXEC ('SPARQL ' || SPARQL_SPIN_GRAPH_TO_DEFSPIN('spin:rule:inference:cl-draw'));


--Test 01: With Rule
SPARQL
DEFINE input:macro-lib 'spin:rule:inference:cl-draw'
PREFIX : <#>
SELECT DISTINCT ?team
#FROM <demo:inference:aggregates>
WHERE 
{
<http://live.dbpedia.org/resource/Liverpool_F.C.> a <https://github.com/danielhmills/champions-league-rdf/raw/master/cl-2019-draw.ttl#ChampionsLeague2019Team>; :canPlay ?team.
};


--Test 02: Without Rule
SPARQL
PREFIX : <#>
SELECT ?team
#FROM <demo:inference:aggregates>
WHERE 
{
<http://live.dbpedia.org/resource/Liverpool_F.C.> :canPlay ?team.
};

