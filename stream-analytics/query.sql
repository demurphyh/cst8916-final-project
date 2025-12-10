SELECT
    System.Timestamp AS windowEnd,
    location,
    
    AVG(iceThickness) AS avgIceThickness,
    MIN(iceThickness) AS minIceThickness,
    MAX(IceThickness) AS maxIceThickness,

    AVG(surfaceTemperature) AS avgSurfaceTemp,
    MIN(surfaceTemperature) AS minSurfaceTemp,
    MAX(surfaceTemperature) AS maxSurfaceTemp,

    MAX(SnowAccumulation) AS maxSnowAccumulation,
    AVG(externalTemp) AS avgExternalTemp,

    COUNT(*) AS readingCount,

    CASE 
        WHEN AVG(iceThickness) >= 30 THEN 'Safe'
        WHEN AVG(iceThickness) >= 20 THEN 'Caution'
        ELSE 'Unsafe'
    END AS safetyStatus
INTO
    [SensorAggregations]
FROM
    [icesensors] TIMESTAMP BY timestamp
GROUP BY
    TUMBLINGWINDOW(minute, 5),
    location;

SELECT *
INTO [outputblob]
FROM [iceSensors] TIMESTAMP BY timestamp;