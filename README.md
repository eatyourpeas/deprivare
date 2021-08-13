# deprivare

[![Scc Count Badge](https://sloc.xyz/github/wardle/deprivare)](https://github.com/wardle/deprivare/)
[![Scc Cocomo Badge](https://sloc.xyz/github/wardle/deprivare?category=cocomo&avg-wage=100000)](https://github.com/wardle/deprivare/)

This provides code and data for indices of deprivation, initially supporting the UK.

We know socio-economic deprivation has a significant effect on health outcomes.

This repository provides a simple microservice, embeddable library and 
command-line tools to allow other software to make use of deprivation indices in the UK.

I use such data in operational electronic health record systems and analytics. 

You can use the NHS Postcode Database to lookup a UK postal code and find out
the LSOA code for that area. My microservice and library [nhspd](https://github.com/wardle/nhspd)
provides a simple lightweight wrapper around that data product. 

I combine medical records with [nhspd](https://github.com/wardle/nhspd) and the
data made available via this repository so I can include deprivation as a 
factor in analysis using a graph-like API as part of my PatientCare EPR. 

# Deprivation indices


| Name                         | Supported?  |
| ---------------------------- | -------------------- |
| Composite UK index, 2016 using the resources generated by [Gary Abel, Rupert Payne, Matt Barclay (2016): UK Deprivation Indices.](https://doi.org/10.5523/bris.1ef3q32gybk001v77c1ifmty7x) | Pending |
| [MySociety adjusted UK indices of deprivation 2020](https://github.com/mysociety/composite_uk_imd) using the same approach as per Abel, Payne and Barclay but for 2020 | Yes |
| [Welsh Index of Deprivation](https://gov.wales/welsh-index-multiple-deprivation) | Yes |
| [English Index of Deprivation](https://www.gov.uk/government/collections/english-indices-of-deprivation) | Pending |
| [Indices of Deprivation for income and employment domains combined for England and Wales (since 2019)](https://www.gov.uk/government/statistics/indices-of-deprivation-2019-income-and-employment-domains-combined-for-england-and-wales) | Pending |

Unfortunately, the "Welsh Index of Multiple Deprivation" and the "English Index of Multiple Deprivation" are not easily
comparable. Each generates a rank based on a geographical region called an LSOA (Lower Layer Super Output Area) but the
top rank in Wales is not equivalent to the top rank in England.

# Which dataset should I use?

Individual indices for a geographic region, such as England or for Wales, are available. If you are studying a
population from a single region, you can use the index for that region. Indices are available are available for
a range of domains, and usually include a composite index providing a view across multiple domains.

However, if your study population is from multiple areas, you cannot use disparate indices and assume rank 1 in, for example
England, is the same as rank 1 in Wales. Likewise, you cannot assume the upper quartile in England is equivalent
to the upper quartile in Wales.

The work by Abel, Payne and Barclay provides a way to harmonise across England and Wales, but there is also indices
based on income and employment, published for England and Wales. Abel, Payne and Barclay published a composite UK
index for 2016, and [MySociety have used the same approach](https://github.com/mysociety/composite_uk_imd) for 2020.

In practical terms, whichever index used, most studies will not want to use ranks directly, but instead use quartiles
or quintiles.

# What is this repository?

This repository provides a way to automatically download and make those data available in computing systems. 
It is designed to be composable with other data and computing services including but not limited to use in a graph-like API. 

In essence, it provides a simple way to lookup a deprivation index based on LSOA, in the UK. 
A LSOA is a small defined geographical area of the UK containing about 1500 people designed to help report small
area statistics. You can use [nhspd](https://github.com/wardle/nhspd) to map from a UK postal code to an LSOA.

# Getting started

This description assumes you want to run using source code directly. 
If there is interest, I can provide pre-built executable files as an alternative.

1. Download and [install clojure](https://clojure.org/guides/getting_started).

e.g. on mac os x with homebrew:

```shell
brew install clojure/tools/clojure
```

2. Clone this repository

```shell
git clone https://github.com/wardle/deprivare
cd deprivare
```

3. List available datasets

This will simply list the currently supported datasets. If you need a specific dataset
that isn't currently supported, let me know via raising an issue and I'll try to
add it for you.

```shell
clj -X:available
```

Result:  

```
|                                                        :name |                         :id |
|--------------------------------------------------------------+-----------------------------|
|                 Welsh Index of Deprivation - quantiles, 2019 |    wales-imd-2019-quantiles |
|                     Welsh Index of Deprivation - ranks, 2019 |        wales-imd-2019-ranks |
| UK composite index of multiple deprivation, 2020 (MySociety) | uk-composite-imd-2020-mysoc |
```

4. Get information about a dataset

Specify a key value pair, :dataset and the 'id' of the dataset in which you are interested.

e.g.
```shell
clj -X:info :dataset uk-composite-imd-2020-mysoc
```

Result:

```
UK composite index of multiple deprivation, 2020 (MySociety)
------------------------------------------------------------
A composite UK score for deprivation indices for 2020 - based on England
with adjusted scores for the other nations as per Abel, Payne and Barclay but
calculated by Alex Parsons on behalf of MySociety.
```

5. Install dataset(s) into a file-based database.

```shell
clj -X:install :db depriv.db :dataset uk-composite-imd-2020-mysoc
clj -X:install :db depriv.db :dataset wales-imd-2019-quantiles
clj -X:install :db depriv.db :dataset wales-imd-2019-ranks
```

Each dataset will be downloaded and then imported.
Each will take a few seconds only.

6. List installed datasets in a database:

```shell
clj -X:installed :db depriv.db
```

7. Run a web service (optional) on port 8080:

> This is currently in development and subject to change.

```shell
clj -X:server :db depriv.db
```

You can specify a port to use, if you need different to the default:

```shell
clj -X:server :db depriv.db :port 8081
```

You can then request deprivation data by LSOA:

```shell
➜  deprivare git:(main) ✗ http -j 127.0.0.1:8080/v1/uk/lsoa/W01001552
```

The results will vary depending on what datasets are installed, but will be
of the form `dataset/key`.

The keys are a close reproduction of the original source data. 

```json
{
  "uk-composite-imd-2020-mysoc/E_expanded_decile": "9.0",
  "uk-composite-imd-2020-mysoc/UK_IMD_E_pop_decile": "9",
  "uk-composite-imd-2020-mysoc/UK_IMD_E_pop_quintile": "5",
  "uk-composite-imd-2020-mysoc/UK_IMD_E_rank": "35619.0",
  "uk-composite-imd-2020-mysoc/UK_IMD_E_score": "7.774724171895473",
  "uk-composite-imd-2020-mysoc/employment_score": "2.0",
  "uk-composite-imd-2020-mysoc/income_score": "2.0",
  "uk-composite-imd-2020-mysoc/nation": "W",
  "uk-composite-imd-2020-mysoc/original_decile": "10",
  "uk-composite-imd-2020-mysoc/overall_local_score": "3.7",
  "uk.gov.ons/lsoa": "W01001552",
  "wales-imd-2019/access_to_services": "868",
  "wales-imd-2019/authority-name": "Monmouthshire",
  "wales-imd-2019/community_safety": "1894",
  "wales-imd-2019/education": "1894",
  "wales-imd-2019/employment": "1867",
  "wales-imd-2019/health": "1882",
  "wales-imd-2019/housing": "1845",
  "wales-imd-2019/income": "1905",
  "wales-imd-2019/lsoa-name": "Dixton with Osbaston",
  "wales-imd-2019/physical_environment": "442",
  "wales-imd-2019/wimd_2019": "1817",
  "wales-imd-2019/wimd_2019_decile": "10",
  "wales-imd-2019/wimd_2019_quartile": "4",
  "wales-imd-2019/wimd_2019_quintile": "5"
}
```


```
