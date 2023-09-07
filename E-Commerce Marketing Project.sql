USE mavenfuzzyfactory;

/*Analyzing Traffic Sources & Paid Marketing Campaigns
Traffic Source Analysis is all about understanding where your customers are coming from and which channels are driving the highest quality traffic, how much we are spending and how well 
traffic is being converted to sales etc.

Paid Traffic is generally tagged with tracking parameters (UTM) that are appended to URLs and allow us to tie website activity back to specific traffic sources and campaigns.

This analysis has some important use cases such as:
1. Analyzing search data and shifting budget towards engines, campaigns that are driving strongest conversion rates.
2. Comparing user behavior patterns across multiple sources to have a strategy for future.
3. Identify opportunities to eliminate wastes spend i.e, we can scale up or down to different sources accordingly.*/

-- We have website sessions data that can be linked to the orders table to understand how much revenue our paid campaigns are making.
-- (Clearly, with the result we can say that "gsearch"is giving us a lot orders and definitely, we can spend more money on that)

SELECT
	utm_source,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
GROUP BY
	utm_source;
    
--  On April 12, it has been a month to our e-commerce business and now, I would like to understand where the bulk of our website sessions are coming from.
-- ("gsearch nonbrand" has a big number of website sessions, so we need to drill down a little more before making any move)

SELECT
	utm_source,
    utm_campaign,
	COUNT(website_session_id) AS sessions
FROM website_sessions
WHERE created_at < '2012-04-12'
GROUP BY
	utm_source,
    utm_campaign
ORDER BY
	sessions DESC;
    
/*From the above query we know that gsearch nonbrand is our major traffic source, but we need to know whether these sessions are driving sales.
We need atleast Conversion Rate Percentage (pct_CVR) to be 4%, if we are much lower, then we'll reduce the bids or vice versa.*/

SELECT
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    (COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id)) * 100 AS pct_CVR
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-04-14'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand';
    
/*With the above conversion rate percentage analysis, we have come to another important business concept called "Bid Optimization". 
Analyzing for bid optimization is about understanding the value of various segments of paid traffic, so that we can optimize our marketing budgets.

It has some important impacts such as- 1. helps to figure out how much one should spend per click to acquire customers.
2. to understand how the website and products perform for various subsegments i.e., mobile vs desktop to optimize within channels.*/


-- Since the conversion rate percentage was lower than 4%, so we bid down for the gsearch nonbrand. Now we need to see the volume/trend, whether it has gone down or not.
SELECT
	MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at < '2012-05-10'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY
	YEARWEEK(created_at);
-- (According to the analysis, it does look like gsearch nonbrand is fairly sensitive to bid changes, and the volume has gone down)


-- I would like to know the conversion rates from session to order by device type, because I was trying to use our website on my mobile the other day, and the experience was not great.

SELECT
	website_sessions.device_type,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    (COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id)) * 100 AS pct
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-05-11'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY 1;
-- (We now know that the CVR percentage of mobile device type is less than 1% which means we can incraese the bids on desktop that should lead to a sales boost.)

