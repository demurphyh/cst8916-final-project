# CST8916 Final Project - Real-time Monitoring System for Rideau Canal Skateway

## 1. Brief Description

## 2. Student Information

- Desmond Murphy - 040946131

- [CST8916 Final Project](https://github.com/demurphyh/cst8916-final-project)
- [Rideau Canal Sensor Simulator](https://github.com/demurphyh/rideau-canal-sensor-simulation)
- [Rideau Canal Dashboard](https://github.com/demurphyh/rideau-canal-dashboard)

## 3. Scenario Overview

### Problem Statement

- The NCC requires a real-time data streaming and visualization system to be built in order to provide constant monitoring of the rideau canal ice surface to ensure skater safety.

### System Objectives

The system must:

- Simulate IoT sensors at Dow's Lake, Fifth Avenue, NAC to monitor:

  - Ice Thickness (cm)
  - Surface Temperature (°C)
  - Snow Accumulation (cm)
  - External Temperature (°C)

- Process data in real-time using Azure Stream Analytics with 5-minute aggregation windows

- Store procesed data in Azure Cosmos DB for fast access

- Archive Historical data in Azure Blob Storage

- Display live data through a web dashboard on Azure App Service

## 4. System Architecture

### Architecture diagram (in architecture/ folder)

![System Architecture Diagram](./architecture/architecture.png)

### Data flow explanation

1. Data flows from the simulated sensor devices into the IoT hub
2. Data goes from the IoT hub to Azure Stream Analytics to be analysed
3. Data is transferred to Cosmos DB
4. Data flows to Blob storage and is stored for historical data archives
5. Data in Cosmos is then displayed on the dashboard

### Azure services used

- IoT Hub with three IoT devices

- Azure Stream Analytics

- Azure Cosmos DB

- Azure Blob Storage

- Azure App Service

- IoT Sensor Simulator

  - Python script simulated the data we would receive from three real IoT devices located at Dow's Lake, Fifth Avenue and the NAC that sent data every 10 seconds to the Azure IoT hub relating to the ice status.
  [Sensor Simulator Repo](https://github.com/demurphyh/rideau-canal-sensor-simulation)

- Azure IoT Hub - Data ingestion from sensors

  - Azure IoT hub receives data from the three simulated IoT devices and acts as the input for Azure Stream Analytics job.

- Azure Stream Analytics - Real-time data processing

  - Input: IoT Hub
  
  - Output: Cosmos DB and Blob Storage

  - Tumbling Window: 5 Minutes

  - Query:

```SQL
 WITH AggregatedData AS (
    SELECT
        location,
        System.Timestamp AS windowEnd,

        AVG(iceThickness) AS avgIceThickness,
        MAX(iceThickness) AS maxIceThickness,
        MIN(iceThickness) AS minIceThickness,

        AVG(surfaceTemp) AS avgSurfaceTemp,
        MAX(surfaceTemp) AS maxSurfaceTemp,
        MIN(surfaceTemp) AS minSurfaceTemp,

        AVG(snowAccumulation) AS avgSnow,
        MAX(snowAccumulation) AS maxSnow,
        MIN(snowAccumulation) AS minSnow,

        AVG(externalTemp) AS avgExternalTemp,
        MAX(externalTemp) AS maxExternalTemp,
        MIN(externalTemp) AS minExternalTemp

    FROM icesensors
    GROUP BY
        location,
        TumblingWindow(minute, 5)
)


SELECT
    location,
    windowEnd AS timestamp,

    avgIceThickness,
    maxIceThickness,
    minIceThickness,

    avgSurfaceTemp,
    maxSurfaceTemp,
    minSurfaceTemp,

    avgSnow,
    maxSnow,
    minSnow,

    avgExternalTemp,
    maxExternalTemp,
    minExternalTemp
INTO outputcosmos
FROM AggregatedData;

SELECT *
INTO outputblob
FROM icesensors;
```

- Azure Cosmos DB - NoSQL database for dashboard queries

  - Database: `RideauCanalDB`

  - Container: `SensorAggregations`

  - Partition Key: `/location`

  - Cosmos DB store the aggregated 5 minute data received from the Azure Stream Job.

- Azure Blob Storage - Historical data archival

  - Container: `historical-data`

  - Path Pattern: `aggregations/{date}/{time}`

  - Format: JSON

  - Azure Blob Storage is used to store all of the historical data received from the simulated IoT devices.

- Azure App Service - Web dashboard hosting

  - Backend:

## 5. Implementation Overview

- IoT Sensor Simulator

  - Python script simulated the data we would receive from three real IoT devices located at Dow's Lake, Fifth Avenue and the NAC that sent data every 10 seconds to the Azure IoT hub relating to the ice status.
  [Sensor Simulator Repo](https://github.com/demurphyh/rideau-canal-sensor-simulation)

- Azure IoT Hub - Data ingestion from sensors

  - Azure IoT hub receives data from the three simulated IoT devices and acts as the input for Azure Stream Analytics job.

- Azure Stream Analytics - Real-time data processing

  - Input: IoT Hub
  
  - Output: Cosmos DB and Blob Storage

  - Tumbling Window: 5 Minutes

  - Query:

```SQL
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
    SensorAggregations
FROM
    icesensors TIMESTAMP BY timestamp
GROUP BY
    TUMBLINGWINDOW(minute, 1),
    location;

SELECT *
INTO outputblob
FROM icesensors;
```

- Azure Cosmos DB - NoSQL database for dashboard queries

  - Database: `RideauCanalDB`

  - Container: `SensorAggregations`

  - Partition Key: `/location`

  - Cosmos DB store the aggregated 5 minute data received from the Azure Stream Job.

- Azure Blob Storage - Historical data archival

  - Container: `historical-data`

  - Path Pattern: `aggregations/{date}/{time}`

  - Format: JSON

  - Azure Blob Storage is used to store all of the historical data received from the simulated IoT devices.

- Web Dashboard - Data Visualization

  - Backend: Node.js with Express

  - Database SDK: `@azure/cosmos`

  - HTML/CSS/JavaScript with Chart.js

  - Features:
  
    - Real-time data display across three locations (Dow's Lake, Fifth Avenue, NAC)
    - Safety Status Badges
    - Auto-refresh capability
    - Historical trends
    - Overall System Status through API
    - [Dashboard Repo](https://github.com/demurphyh/rideau-canal-dashboard)

- Azure App Service - Web dashboard hosting

  - Ice status dashboard is deployed to Azure App Services as a Node.js application
  - Azure App Service automatically creates a publicly accesible URL
  - Azure Cosmos DB are entered into settings instead of using .env file like local deployment

## 6. Repository Links

- [CST8916 Final Project](https://github.com/demurphyh/cst8916-final-project)
- [Rideau Canal Sensor Simulator](https://github.com/demurphyh/rideau-canal-sensor-simulation)
- [Rideau Canal Dashboard](https://github.com/demurphyh/rideau-canal-dashboard)

### 7. Video Demonstration

### 8. Setup Instructions

### 9. Results and Analysis

### 10. Challenges and Solutions

### 11. AI Tools Disclosure (if used)

### 12. References
