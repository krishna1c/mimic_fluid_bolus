-- Visualization and potential categories of ethnicity distribution
-- MIMIC-III v1.4

SELECT ethnicity, COUNT(ethnicity)
FROM icustay_detail
GROUP BY ethnicity
ORDER BY ethnicity;

/* Output:
                        ethnicity                         | count
----------------------------------------------------------+-------
 AMERICAN INDIAN/ALASKA NATIVE                            |    54
 AMERICAN INDIAN/ALASKA NATIVE FEDERALLY RECOGNIZED TRIBE |     3
 ASIAN                                                    |  1510
 ASIAN - ASIAN INDIAN                                     |    93
 ASIAN - CAMBODIAN                                        |    22
 ASIAN - CHINESE                                          |   278
 ASIAN - FILIPINO                                         |    27
 ASIAN - JAPANESE                                         |     7
 ASIAN - KOREAN                                           |    12
 ASIAN - OTHER                                            |    18
 ASIAN - THAI                                             |     4
 ASIAN - VIETNAMESE                                       |    53
 BLACK/AFRICAN                                            |    44
 BLACK/AFRICAN AMERICAN                                   |  5591
 BLACK/CAPE VERDEAN                                       |   206
 BLACK/HAITIAN                                            |   105
 CARIBBEAN ISLAND                                         |     9
 HISPANIC/LATINO - CENTRAL AMERICAN (OTHER)               |    13
 HISPANIC/LATINO - COLOMBIAN                              |    10
 HISPANIC/LATINO - CUBAN                                  |    24
 HISPANIC/LATINO - DOMINICAN                              |    83
 HISPANIC/LATINO - GUATEMALAN                             |    39
 HISPANIC/LATINO - HONDURAN                               |     4
 HISPANIC/LATINO - MEXICAN                                |    12
 HISPANIC/LATINO - PUERTO RICAN                           |   237
 HISPANIC/LATINO - SALVADORAN                             |    18
 HISPANIC OR LATINO                                       |  1742
 MIDDLE EASTERN                                           |    44
 MULTI RACE ETHNICITY                                     |   137
 NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER                |    18
 OTHER                                                    |  1549
 PATIENT DECLINED TO ANSWER                               |   567
 PORTUGUESE                                               |    70
 SOUTH AMERICAN                                           |     9
 UNABLE TO OBTAIN                                         |   882
 UNKNOWN/NOT SPECIFIED                                    |  4724
 WHITE                                                    | 42488
 WHITE - BRAZILIAN                                        |    64
 WHITE - EASTERN EUROPEAN                                 |    28
 WHITE - OTHER EUROPEAN                                   |    85
 WHITE - RUSSIAN                                          |   168
(41 rows)
*/


-- Possible categorical grouping. Considerations were made for both
-- suitability and number.

SELECT
    CASE WHEN ethnicity IN ('ASIAN', 'ASIAN - ASIAN INDIAN',
                            'ASIAN - CAMBODIAN', 'ASIAN - CHINESE',
                            'ASIAN - FILIPINO', 'ASIAN - JAPANESE',
                            'ASIAN - KOREAN', 'ASIAN - OTHER',
                            'ASIAN - THAI', 'ASIAN - VIETNAMESE') THEN 'Asian'

         WHEN ethnicity IN ('BLACK/AFRICAN', 'BLACK/AFRICAN AMERICAN',
                            'BLACK/CAPE VERDEAN', 'BLACK/HAITIAN',
                            'CARIBBEAN ISLAND') THEN 'Black'

         WHEN ethnicity IN ('HISPANIC/LATINO - CENTRAL AMERICAN (OTHER)',
                            'HISPANIC/LATINO - COLOMBIAN',
                            'HISPANIC/LATINO - CUBAN',
                            'HISPANIC/LATINO - DOMINICAN',
                            'HISPANIC/LATINO - GUATEMALAN',
                            'HISPANIC/LATINO - HONDURAN',
                            'HISPANIC/LATINO - MEXICAN',
                            'HISPANIC/LATINO - PUERTO RICAN',
                            'HISPANIC/LATINO - SALVADORAN',
                            'HISPANIC OR LATINO', 'PORTUGUESE',
                            'SOUTH AMERICAN') THEN 'Latino'

         WHEN ethnicity IN ('AMERICAN INDIAN/ALASKA NATIVE',
                            'AMERICAN INDIAN/ALASKA NATIVE FEDERALLY RECOGNIZED TRIBE',
                            'MIDDLE EASTERN', 'MULTI RACE ETHNICITY',
                            'NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER',
                            'OTHER') THEN 'Other'

         WHEN ethnicity IN ('PATIENT DECLINED TO ANSWER', 'UNABLE TO OBTAIN',
                            'UNKNOWN/NOT SPECIFIED') THEN 'Unknown'

         WHEN ethnicity IN ('WHITE', 'WHITE - BRAZILIAN',
                            'WHITE - EASTERN EUROPEAN',
                            'WHITE - OTHER EUROPEAN', 'WHITE - RUSSIAN')
             THEN 'White'
    END AS ethnicity_group
FROM icustay_detail;
