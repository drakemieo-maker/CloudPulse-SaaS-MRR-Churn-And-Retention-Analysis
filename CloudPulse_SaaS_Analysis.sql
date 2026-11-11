USE CloudPulse_SaaS;

SELECT 
    Billing_Cycle,
    COUNT(Sub_ID) AS Total_Accounts,
    SUM(CASE WHEN Subscription_Status = 'Active' THEN 1 ELSE 0 END) AS Active_Accounts,
    SUM(CASE WHEN Subscription_Status = 'Churned' THEN 1 ELSE 0 END) AS Churned_Accounts,
    ROUND(SUM(CASE WHEN Subscription_Status = 'Churned' THEN 1 ELSE 0 END) * 100.0 / COUNT(Sub_ID), 2) AS Churn_Rate_Percent,
    SUM(CASE WHEN Subscription_Status = 'Active' THEN Monthly_Fee_USD ELSE 0 END) AS Active_MRR_USD,
    SUM(CASE WHEN Subscription_Status = 'Churned' THEN Monthly_Fee_USD ELSE 0 END) AS Lost_Churned_MRR_USD
FROM Subscription_Logs
GROUP BY Billing_Cycle
ORDER BY Lost_Churned_MRR_USD DESC;

SELECT 
    Subscription_Status,
    Churn_Reason,
    COUNT(Sub_ID) AS Account_Count,
    SUM(Monthly_Fee_USD) AS Total_MRR_Impact_USD,
    ROUND(AVG(Support_Tickets_Opened), 1) AS Avg_Tickets_Opened,
    ROUND(AVG(Avg_Ticket_Resolution_Hours), 1) AS Avg_Support_Wait_Hours
FROM Subscription_Logs
GROUP BY Subscription_Status, Churn_Reason
ORDER BY Total_MRR_Impact_USD DESC;

SELECT 
    c.Account_Manager,
    COUNT(s.Sub_ID) AS Total_Clients_Managed,
    SUM(CASE WHEN s.Subscription_Status = 'Churned' THEN 1 ELSE 0 END) AS Churned_Clients,
    SUM(CASE WHEN s.Subscription_Status = 'Churned' THEN s.Monthly_Fee_USD ELSE 0 END) AS Lost_MRR_USD,
    ROUND(AVG(s.Avg_Ticket_Resolution_Hours), 1) AS Avg_Support_Resolution_Hours
FROM Subscription_Logs s
INNER JOIN Customer_Accounts c ON s.Account_ID = c.Account_ID
GROUP BY c.Account_Manager
ORDER BY Lost_MRR_USD DESC;