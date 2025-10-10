-- Prescribers Database
-- For this exericse, you'll be working with a database derived from the Medicare Part D Prescriber Public Use File. More information about the data is contained in the Methodology PDF file. See also the included entity-relationship diagram.

-- 1.
	-- a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
	
	SELECT 
		npi, 
		SUM(total_claim_count) AS total_claim FROM prescription
	GROUP BY npi
	ORDER BY total_claim DESC

	
	-- b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  
	--specialty_description, and the total number of claims.
	
	SELECT 
		nppes_provider_first_name AS first_name,
		nppes_provider_last_org_name AS last_name,
		specialty_description,
		SUM(total_claim_count) AS total_claim_count
	FROM prescriber AS pr
	LEFT JOIN prescription AS pn
	ON pr.npi=pn.npi
	GROUP BY first_name,last_name,specialty_description
	HAVING SUM(total_claim_count) IS NOT NULL
	ORDER BY total_claim_count DESC;

-- 2.	
	-- a. Which specialty had the most total number of claims (totaled over all drugs)?
	SELECT 
		specialty_description, 
		SUM(total_claim_count) AS total_claim
	FROM prescriber AS pr
	LEFT JOIN prescription AS pn
	ON pr.npi=pn.npi
	GROUP BY specialty_description
	HAVING SUM(total_claim_count) IS NOT NULL
	ORDER BY total_claim DESC
	LIMIT 10;

	Select count(*) from prescription
	Select count(*) from prescriber
	
	
	-- b. Which specialty had the most total number of claims for opioids?

	SELECT 
		specialty_description,
		SUM(total_claim_count) AS total_claim
		FROM prescriber AS pr
	LEFT JOIN prescription AS pn
	ON pr.npi=pn.npi
	LEFT JOIN drug AS d
	ON d.drug_name = pn.drug_name
	WHERE d.opioid_drug_flag ='Y'
	GROUP BY specialty_description
	ORDER BY total_claim DESC;
	
	
	-- c. Challenge Question: Are there any specialties that appear in the prescriber table 
	--that have no associated prescriptions in the prescription table?
	SELECT 
		pr.specialty_description, 
		COUNT(pr.specialty_description) AS count_not_associated
	FROM prescriber AS pr
	LEFT JOIN prescription AS pn
	USING(npi)
	WHERE pr.specialty_description IS NOT NULL 
		AND pn.total_claim_count IS NULL
	GROUP BY pr.specialty_description

	select 
		pr.specialty_description,
		count(pr.npi) 
	from prescriber as pr
	left join prescription as pn 
	using(npi)
	WHERE pn.npi is null
	GROUP BY pr.specialty_description

	SELECT 
		pr.specialty_description, 
		COUNT(pr.specialty_description) AS count_not_associated
	FROM prescriber AS pr
	LEFT JOIN prescription AS pn
	USING(npi)
	WHERE 
		 pn.total_claim_count IS NULL
	GROUP BY pr.specialty_description
	
	-- d. Difficult Bonus: Do not attempt until you have solved all other problems! 
	--For each specialty, report the percentage of total claims by that specialty which are for opioids. 
	--Which specialties have a high percentage of opioids?
	
	SELECT 
		subq.specialty_description, 
		SUM(subq.total_claim_count)/SUM(total_claim_count)
	FROM
		(
		SELECT specialty_description, SUM(total_claim_count) AS total_count FROM prescription AS pn
		LEFT JOIN prescriber AS pr
		USING(npi)
		GROUP BY specialty_description
		) AS subq
	LEFT JOIN prescriber AS pre
	ON subq.specialty_description=pre.specialty_description
	LEFT JOIN prescription AS prs
	ON prs.npi=pre.npi
	GROUP BY subq.specialty_description


	SELECT 
		specialty_description,
		(SUM(total_claim_count)/(select SUM(total_claim_count) from prescription)) *100
	FROM prescriber AS pr
	LEFT JOIN prescription AS pn
	USING(npi)
	LEFT JOIN drug AS d
	ON d.drug_name = pn.drug_name
	WHERE opioid_drug_flag='Y'
	GROUP BY specialty_description

	
-- 3.	
	-- a. Which drug (generic_name) had the highest total drug cost?
	SELECT 
		d.generic_name,
		--d.drug_name,
		SUM(total_drug_cost) AS total_cost
	FROM prescription AS pn
	LEFT JOIN drug AS d
	ON d.drug_name = pn.drug_name
	GROUP BY  d.generic_name
	ORDER BY total_cost DESC
	LIMIT 10;
	
	-- b. Which drug (generic_name) has the hightest total cost per day? 
	SELECT 
		generic_name,
		--d.drug_name,
		ROUND(SUM(total_drug_cost)/SUM(total_day_supply),2) AS total_cost_perday
	FROM prescription AS pn
	LEFT JOIN drug AS d
	ON d.drug_name = pn.drug_name
	GROUP BY generic_name
	ORDER BY total_cost_perday DESC
	LIMIT 5;
select * from prescription
	
	--Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.
	
-- 4.	
	-- a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' 
	--for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y',
	-- and says 'neither' for all other drugs. Hint: You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/
	
	SELECT 
		drug_name,
		CASE
			WHEN opioid_drug_flag ='Y' THEN 'opioid'
			WHEN antibiotic_drug_flag ='Y' THEN 'antibiotic'
			ELSE 'neither'
		END AS drug_type
	FROM drug 
	ORDER BY drug_type
	
	
	-- b. Building off of the query you wrote for part a, 
	-- determine whether more was spent (total_drug_cost) on opioids or on antibiotics. 
	-- Hint: Format the total costs as MONEY for easier comparision.
	
	SELECT 
		CASE
			WHEN opioid_drug_flag ='Y' THEN 'opioid'
			WHEN antibiotic_drug_flag ='Y' THEN 'antibiotic'
		END AS drug_type,
		TO_CHAR(SUM(total_drug_cost), '$999,999,999.00') AS total_drug_cost
	FROM drug AS d
	LEFT JOIN prescription AS pn
	ON d.drug_name = pn.drug_name
	WHERE opioid_drug_flag ='Y' OR antibiotic_drug_flag ='Y'
	GROUP BY drug_type;

select * from cbsa
select * from population
-- 5.	
	-- a. How many CBSAs are in Tennessee? Warning: The cbsa table contains information for all states, not just Tennessee.
	
	select cbsa,count(*) from cbsa
	where cbsaname like '%TN%'
	group by cbsa,cbsaname
	
	-- b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

SELECT 
        c.cbsaname,
        SUM(p.population) AS total_population
FROM population AS p
LEFT JOIN cbsa AS c
USING(fipscounty)
GROUP BY c.cbsaname
ORDER BY total_population DESC
		
	-- c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

SELECT county, SUM(population) AS total_population
FROM population AS p
LEFT JOIN fips_county AS f
USING(fipscounty)
GROUP BY county
ORDER BY total_population DESC

	
-- 6.	
	-- a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
	SELECT 
		drug_name,
		SUM(total_claim_count) AS total_claim_count
	FROM prescription
	GROUP BY drug_name
	HAVING SUM(total_claim_count)>=3000
	
	-- b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

	SELECT 
		p.drug_name,
		CASE
			WHEN opioid_drug_flag ='Y' THEN 'opioid'
			WHEN opioid_drug_flag ='N' THEN 'not opioid'
		END AS opioid_status,
		SUM(total_claim_count) AS total_claim_count
	FROM prescription AS p
	LEFT JOIN drug AS d
	USING(drug_name)
	GROUP BY p.drug_name, opioid_status
	HAVING SUM(total_claim_count)>=3000
	
	-- c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
	
	SELECT 
		p.drug_name,
		nppes_provider_first_name AS prescriber_first_name,
		nppes_provider_last_org_name AS prescriber_last_name,
		CASE
			WHEN opioid_drug_flag ='Y' THEN 'opioid'
			WHEN opioid_drug_flag ='N' THEN 'not opioid'
		END AS opioid_status,
		SUM(total_claim_count) AS total_claim_count
	FROM prescription AS p
	LEFT JOIN drug AS d
	USING(drug_name)
	LEFT JOIN prescriber AS pr
	ON pr.npi =p.npi
	GROUP BY 
		p.drug_name, 
		opioid_status, 
		prescriber_first_name,
		prescriber_last_name
	HAVING SUM(total_claim_count)>=3000
	
-- 7.	
	-- The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. Hint: The results from all 3 parts will have 637 rows.
	
	-- a. First, create a list of all npi/drug_name combinations for pain management specialists 
	-- (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'),
	-- where the drug is an opioid (opiod_drug_flag = 'Y'). Warning: Double-check your query before running it. 
	-- You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

	
	-- b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations,
	-- whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
	
	
	-- c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. 
	--Hint - Google the COALESCE function.

		


	