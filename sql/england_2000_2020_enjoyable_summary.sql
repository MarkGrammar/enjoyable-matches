{\rtf1\ansi\ansicpg1252\cocoartf2822
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 CREATE OR REPLACE VIEW match_fun AS\
SELECT\
    Team1,\
    Team2,\
    Year,\
    Country,\
    (FT_Team1 + FT_Team2) AS total_goals,\
    CASE\
        WHEN (FT_Team1 + FT_Team2) = 0 THEN 'Not Enjoyable'\
        WHEN (FT_Team1 + FT_Team2) BETWEEN 1 AND 2 THEN 'A Little Enjoyable'\
        WHEN (FT_Team1 + FT_Team2) BETWEEN 3 AND 4 THEN 'Enjoyable'\
        ELSE 'Very Enjoyable\
    END AS enjoyment\
FROM big_matches;\
\
\
WITH all_matches AS (\
    SELECT Team1 AS team, Year, Country, enjoyment FROM match_fun\
    UNION ALL\
    SELECT Team2 AS team, Year, Country, enjoyment FROM match_fun\
),\
filtered AS (\
    SELECT * \
    FROM all_matches\
    WHERE Country = 'ENG' \
      AND Year BETWEEN 2000 AND 2020\
),\
team_dist AS (\
    SELECT \
        team,\
        enjoyment,\
        COUNT(*) AS match_count\
    FROM filtered\
    GROUP BY team, enjoyment\
),\
team_total AS (\
    SELECT \
        team,\
        SUM(match_count) AS total_match_count\
    FROM team_dist\
    GROUP BY team\
)\
SELECT \
    tt.team,\
    tt.total_match_count,\
    SUM(CASE WHEN td.enjoyment = 'Not Enjoyable' THEN td.match_count ELSE 0 END) AS not_enjoyable_matches,\
    SUM(CASE WHEN td.enjoyment = 'A Little Enjoyable' THEN td.match_count ELSE 0 END) AS a_little_enjoyable_matches,\
    SUM(CASE WHEN td.enjoyment = 'Enjoyable' THEN td.match_count ELSE 0 END) AS enjoyable_matches,\
    SUM(CASE WHEN td.enjoyment = 'Very Enjoyable' THEN td.match_count ELSE 0 END) AS very_enjoyable_matches,\
    ROUND(100.0 * SUM(CASE WHEN td.enjoyment = 'Not Enjoyable' THEN td.match_count ELSE 0 END) / tt.total_match_count, 2) AS not_enjoyable_percent,\
    ROUND(100.0 * SUM(CASE WHEN td.enjoyment = 'A Little Enjoyable' THEN td.match_count ELSE 0 END) / tt.total_match_count, 2) AS a_little_enjoyable_percent,\
    ROUND(100.0 * SUM(CASE WHEN td.enjoyment = 'Enjoyable' THEN td.match_count ELSE 0 END) / tt.total_match_count, 2) AS enjoyable_percent,\
    ROUND(100.0 * SUM(CASE WHEN td.enjoyment = 'Very Enjoyable' THEN td.match_count ELSE 0 END) / tt.total_match_count, 2) AS very_enjoyable_percent\
FROM team_total tt\
JOIN team_dist td USING (team)\
GROUP BY tt.team, tt.total_match_count\
ORDER BY enjoyable_percent + very_enjoyable_percent DESC, tt.total_match_count DESC;\
}