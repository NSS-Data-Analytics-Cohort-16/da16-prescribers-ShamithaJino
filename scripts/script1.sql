-- Prescribers Database
select * from cbsa
select * from drug
select * from fips_county
select * from overdose_deaths
select * from population
select * from prescriber
select * from prescription
select * from zip_fips

-- For this exericse, you'll be working with a database derived from the Medicare Part D Prescriber Public Use File. More information about the data is contained in the Methodology PDF file. See also the included entity-relationship diagram.

-- 1.
	-- a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
	SELECT 
		pr.npi, 
		SUM(pn.total_claim_count) AS total_claims
	FROM  prescription AS pn
	LEFT JOIN prescriber AS pr
	ON pr.npi = pn.npi
	GROUP BY pr.npi
	ORDER BY total_claims DESC

	SELECT npi, sum(total_claim_count) as total_claim from prescription
	group by npi
	order by total_claim desc

	
	-- b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  
	--specialty_description, and the total number of claims.
	
	SELECT 
		nppes_provider_first_name AS first_name,
		nppes_provider_last_org_name AS last_name,
		specialty_description,
		total_claim_count
	FROM prescriber AS pr
	LEFT JOIN prescription AS pn
	ON pr.npi=pn.npi;

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
	
	
	-- c. Challenge Question: Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?
	-- d. Difficult Bonus: Do not attempt until you have solved all other problems! For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?
-- 3.	
	-- a. Which drug (generic_name) had the highest total drug cost?
	SELECT 
		generic_name,
		d.drug_name,
		SUM(total_drug_cost) AS highest_total_cost
	FROM prescription AS pn
	LEFT JOIN drug AS d
	ON d.drug_name = pn.drug_name
	GROUP BY generic_name, d.drug_name
	ORDER BY highest_total_cost DESC
	LIMIT 10;
	
	-- b. Which drug (generic_name) has the hightest total cost per day? 
	SELECT 
		generic_name,
		d.drug_name,
		SUM(total_day_supply) AS highest_total_cost_perday
	FROM prescription AS pn
	LEFT JOIN drug AS d
	ON d.drug_name = pn.drug_name
	GROUP BY generic_name, d.drug_name
	HAVING SUM(total_day_supply) IS NOT NULL
	ORDER BY highest_total_cost_perday DESC
	
	select SUM(total_day_supply) from drug as d
	left join prescription as p
	on d.drug_name=p.drug_name
	WHERE generic_name='LEVOTHYROXINE SODIUM'
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
		END AS drug_type
	FROM drug 
	WHERE opioid_drug_flag ='Y' OR antibiotic_drug_flag ='Y';
	
	-- b. Building off of the query you wrote for part a, 
	-- determine whether more was spent (total_drug_cost) on opioids or on antibiotics. 
	-- Hint: Format the total costs as MONEY for easier comparision.
	
	SELECT 
		CASE
			WHEN opioid_drug_flag ='Y' THEN 'opioid'
			WHEN antibiotic_drug_flag ='Y' THEN 'antibiotic'
		END AS drug_type,
		SUM(total_drug_cost) AS total_drug_cost
	FROM drug AS d
	LEFT JOIN prescription AS pn
	ON d.drug_name = pn.drug_name
	WHERE opioid_drug_flag ='Y' OR antibiotic_drug_flag ='Y'
	GROUP BY drug_type;


-- 5.	
	-- a. How many CBSAs are in Tennessee? Warning: The cbsa table contains information for all states, not just Tennessee.
	-- b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
	-- c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
-- 6.	
	-- a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
	-- b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
	-- c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
-- 7.	
	-- The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. Hint: The results from all 3 parts will have 637 rows.
	-- a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). Warning: Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.
	-- b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
	-- c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.