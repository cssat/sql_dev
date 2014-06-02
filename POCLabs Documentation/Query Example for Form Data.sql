/* This query finds all the Housing Survey forms for each Case and returns the County, Number of People in Household, Monthly Income, and Service Date question responses. */
/* The keys for forms and questions in this query do not correspond to actual data records. This query was written before the database existed and is to be used as an example only. */
SELECT 
	AI.CaseKey
	,FS.FormSubmissionKey
	/* We need to use the MAX() function because the table structure will return one row for each of the questions, 
	which must be reduced to eliminate NULL values and give us one row per form with the responses for the questions that were answered. 
	If we want to supply a default, it should come in an ISNULL() function outside the MAX() function, not inside the MAX() function, 
	otherwise the MAX() function will use the default we've suppied and possibly eliminate good data. */
	,ISNULL(MAX(IIF(FD.QuestionKey = 8582, DI1.DataItemValue, NULL)), 'None Entered') [County]
	/* Multiple Choice and Multiple Answer questions must be handled differently. Multiple Choice questions will have one answer, 
	but Multiple Answer questions need to account for every option that could be chosen, so they must all be considered as possible answer columns. */
	,IIF(MAX(IIF(FD.QuestionKey = 5028, DI1.DataItemKey, NULL)) IS NULL, 'Not Answered', ISNULL(MAX(IIF(FD.QuestionKey = 5028 AND DI1.DataItemKey = 118, 'Yes', NULL)), 'No')) [RemovedAbuse]
	,IIF(MAX(IIF(FD.QuestionKey = 5028, DI1.DataItemKey, NULL)) IS NULL, 'Not Answered', ISNULL(MAX(IIF(FD.QuestionKey = 5028 AND DI1.DataItemKey = 119, 'Yes', NULL)), 'No')) [RemovedNeglect]
	,IIF(MAX(IIF(FD.QuestionKey = 5028, DI1.DataItemKey, NULL)) IS NULL, 'Not Answered', ISNULL(MAX(IIF(FD.QuestionKey = 5028 AND DI1.DataItemKey = 203, 'Yes', NULL)), 'No')) [RemovedDrugs]
	,MAX(IIF(FD.QuestionKey = 3352, DI2.DataIntValue, NULL)) [NumberOfPeopleInHousehold]
	,MAX(IIF(FD.QuestionKey = 3353, DI3.DataMoneyValue, NULL)) [MonthlyIncome]
	,MAX(IIF(FD.QuestionKey = 4152, DI8.DataDate, NULL)) [ServiceDate]
FROM dbo.FormSubmission FS
INNER JOIN dbo.Form F ON
	F.FormKey = FS.FormKey
		/* We need to make sure we are pulling data for the right form regardless of the version of the form used. */
		AND F.FormNameKey = 9253 -- Housing Survey
INNER JOIN dbo.ActivityInstanceFormSubmitted AIFS ON
	AIFS.FormSubmittedKey = FS.FormSubmittedKey
INNER JOIN dbo.ActivityInstance AI ON
	AI.ActivityInstanceKey = AIFS.ActivityInstanceKey
		/* We don't want forms that may still be around from instances of activities that were, for one reason or another, deleted after they were created. */
		AND AI.DeletedDate IS NULL
INNER JOIN dbo.Activity A ON
	A.ActivityKey = AI.ActivityKey
/* We want to ensure at least one of the questions were answered, so we INNER JOIN. 
If we wanted all forms regardless of the number of questions answered, we would LEFT JOIN to the FormData table. */
INNER JOIN dbo.FormData FD ON
	FD.FormSubmissionKey = FS.FormSubmissionKey
		AND FD.QuestionKey IN (
			8582 -- County -- Multiple Choice
			,5028 -- Removal Reasons -- Multiple Answer
			,3352 -- Number of people in household -- Integer
			,3353 -- Monthly Income -- Money
			,4152 -- Service Date -- Date
		)
/* Each data table will likely have records with the same key value as in the other tables, 
so we need to filter to the correct DataTypeKey supplied in FormData for the table we are joining to. */
LEFT JOIN dbo.DataItem DI1 ON
	DI1.DataItemKey = FD.DataValueKey
		AND FD.DataTypeKey = 1 -- Multiple Choice/Answer Data
LEFT JOIN dbo.DataInt DI2 ON
	DI2.DataIntKey = FD.DataValueKey
		AND FD.DataTypeKey = 2 -- Integer Data
LEFT JOIN dbo.DataMoney DM3 ON
	DM3.DataMoneyKey = FD.DataValueKey
		AND FD.DataTypeKey = 3 -- Money Data
LEFT JOIN dbo.DataDate DD8 ON
	DD8.DataDateKey = FD.DataValueKey
		AND FD.DataTypeKey = 8 -- Date Data
/* We don't want forms that were deleted after they were created. */
WHERE FS.DeletedDate IS NULL
GROUP BY
	AI.CaseKey
	,FS.FormSubmittedKey
			