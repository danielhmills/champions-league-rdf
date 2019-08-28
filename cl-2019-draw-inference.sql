-- Clear Graphs
SPARQL CLEAR GRAPH <spin:rule:inference:cl-draw>;
SPARQL DROP SPIN LIBRARY <spin:rule:inference:cl-draw> ;
SPARQL ALTER QUAD STORAGE virtrdf:DefaultQuadStorage { DETACH MACRO LIBRARY <spin:rule:inference:cl-draw> };


--Test Query

SPARQL
DEFINE get:soft "replace"
DEFINE input:grab-var "?team"
DEFINE input:grab-depth 1

SELECT DISTINCT 
    ?s 
    ?team
{
    ?s 
    a schema:SportsTeam; 
    rdfs:label ?team; 
    <http://purl.org/dc/terms/subject> ?league;
    <http://localhost:8890/DAV/home/danielhm/Public/cl-teams.ttl#hasGroup> ?group.

    FILTER(lang(?team) = "en").

    FILTER NOT EXISTS
    {
        ?s <http://purl.org/dc/terms/subject> <http://dbpedia.org/resource/Category:Premier_League_clubs>
    }
    FILTER NOT EXISTS
    {
        <http://dbpedia.org/resource/Liverpool_F.C.> <http://localhost:8890/DAV/home/danielhm/Public/cl-teams.ttl#hasGroup> ?group.
    }
};




--Create Rule

SPARQL
PREFIX : <#>
PREFIX spin:  <http://spinrdf.org/spin#>
PREFIX sp: <http://spinrdf.org/sp#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>

WITH <spin:rule:inference:cl-draw>
INSERT{
        <http://localhost:8890/DAV/home/danielhm/Public/cl-teams.ttl#ChampionsLeague2019Team> a owl:Class;
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
                                        a <http://localhost:8890/DAV/home/danielhm/Public/cl-teams.ttl#ChampionsLeague2019Team>;
                                        <http://localhost:8890/DAV/home/danielhm/Public/cl-teams.ttl#hasGroup> ?groupA;
                                        dbo:league ?league.

                                        #FILTER(?team1 = <live.http://dbpedia.org/resource/Liverpool_F.C.>)

                                        ?team2 
                                        a <http://localhost:8890/DAV/home/danielhm/Public/cl-teams.ttl#ChampionsLeague2019Team>;
                                        <http://localhost:8890/DAV/home/danielhm/Public/cl-teams.ttl#hasGroup> ?groupB;
                                        dbo:league ?league2.

                                        FILTER NOT EXISTS
                                            {
                                                ?team2 dbo:league ?league.
                                            }

                                        FILTER NOT EXISTS
                                            {
                                                ?team2 <http://localhost:8890/DAV/home/danielhm/Public/cl-teams.ttl#hasGroup> ?groupA.
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
<http://live.dbpedia.org/resource/Liverpool_F.C.> a <http://localhost:8890/DAV/home/danielhm/Public/cl-teams.ttl#ChampionsLeague2019Team>; :canPlay ?team.
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

