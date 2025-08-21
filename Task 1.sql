
-- Query 1: The names and the number of messages sent by each user --

SELECT
	U.UserID
	, U.Name
	, COUNT(DISTINCT M.MessageID) AS CNT_MSG
FROM User U
	LEFT JOIN Messages M
		ON U.UserID = M.UserIDSender
GROUP BY U.UserID, U.Name
;

-- Query 2: The total number of messages sent stratified by weekday --

SELECT
	DAYNAME(M.DateSent) AS DOW
	, COUNT(DISTINCT MessageID) AS CNT_MSG
FROM Messages M
GROUP BY M.DateSent
;

-- Query 3: The most recent message from each thread that has no response yet --
/* not sure how to identify if there is a response or not from the schema*/

WITH LASTEST_MSG AS (
SELECT
	ThreadID
	, MAX(DateSent) AS LastMsg
FROM Messages
GROUP BY ThreadID
)

SELECT
	M.ThreadID
	, M.MessageContent
FROM Messages M
	INNER JOIN LASTEST_MSG L
		ON	M.ThreadID = L.ThreadID
		AND M.DateSent = L.LastMsg
;
		
-- Query 4: For the conversation with the most messages: all user data and message contents ordered chronologically so one can follow the whole conversation --

WITH MOST_MSG AS (
SELECT
	ThreadID
	, COUNT(DISTINCT MessageID) AS MSG_COUNT
FROM Messages
ORDER BY 2 DESC
LIMIT 1
)

SELECT
	M.ThreadID
	, M.DateSent
	, SEND.UserID AS SenderID
	, SEND.Name AS SenderName
	, RECIEVE.UserID AS RecipientID
	, RECIEVE.Name AS RecipientName	
	, T.Subject
	, M.MessageContent
FROM Messages M
	INNER JOIN MOST_MSG MM
		ON M.ThreadID = MM.ThreadID
	LEFT JOIN Threads TABLE
		ON M.ThreadID = T.ThreadID
	LEFT JOIN User SEND
		ON SEND.UserID = M.UserIDSender
	LEFT JOIN User RECIEVE
		ON RECIEVE.UserID = M.UserIDRecipient
ORDER BY M.DateSent ASC
;