
# The purpose of this script is to produce and save (as RDS) a complete ed dataset
# This way, we can be very explicit about any filters etc by including them in each individual script
# Aim is to be as transparent and explicit as possible at all times

library(iml)
library(xgboost)
library(caret)
library(dplyr)
library(readr)
library(lubridate)
library(prophet)
library(forecast)
library(bsts)
library(plotly)
library(readxl)
library(tidyr)
library(dplyr)
library(purrr)
library(writexl)
library(htmlwidgets)
library(htmltools)
library(DT)
library(odbc)
library(lubridate)
library(ggplot2)
library(ggridges)
library(forecast)
library(ggplot2)
library(dplyr)


source("./config/connections.R")

con <- dbConnect(odbc(), 
                 Driver = "SQLServer", 
                 Server = server_sql,
                 Database = db_other,
                 UID = uid,
                 PWD = pwd,
                 Trusted_Connection = "True",
                 applicationIntent = "readonly")

sql_query <- paste("

SELECT [HospitalLocation]
      ,[AppointmentTime]
      ,[ArrivalTime]
      ,[MainSpecialtyName]
      ,[CRN]
      ,[AdministrativeEndDate]
      ,[AdministrativeEndTime]
      ,[Outcome]
      ,[RegisteredGPPractice]
      ,[TreatmentDate]
      ,[TreatmentTime]
      ,[TreatmentTypeCode]
      ,[NHSNumber]
      ,[ArrivalDate]
      ,[BReqDate]
      ,[BReqTime]
      ,[BReqMainSpecialtyName]
      ,[BreachReasonCode]
      ,[BreachReason]
      ,[ExcludeBreachFlag]
      ,[ArrivedBy]
      ,[Disposal]
      ,[SentBy]
      ,[PatientType]
      ,[TreatmentStartDate]
      ,[TreatmentStartTime]
      ,[TreatmentEndDate]
      ,[TreatmentEndTime]
      ,[TriageDate]
      ,[TriageTime]
      ,[NewOrReturn]
      ,[AdminArrival]
      ,[TreatmentStart]
      ,[TreatmentEnd]
      ,[AdminEnd]
      ,[BreachEnd]
      ,[TIDSeconds]
      ,[DecisionToAdmitDate]
      ,[DecisionToAdmitTime]

  FROM [Analyst_Reporting].[dbo].[AE]
                   
                   ",
                   sep="")

sql_extract <- dbGetQuery(con, sql_query)

ed_data_all <- sql_extract %>% arrange(ArrivalDate)

dbDisconnect(con)

rm(sql_extract, api_key, db_dev, db_live, db_other, pwd, server_rsconnect, server_sql, sql_query, uid, user, con)

data <- ed_data_all

saveRDS(data, file = "./front-door/ed_data_all.rds")
saveRDS(data, file = "./back-door/ed_data_all.rds")

