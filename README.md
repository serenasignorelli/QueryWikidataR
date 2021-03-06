
QueryWikidataR: a package to use the Query Wikidata service in R
----------------------------------------------------------------

This package includes a series of functions that give R users access to the Query Wikidata, as well as tools that transforms the list of items into R data frames and then gets from them the Wikipedia related articles with languages.

The query functions built concern location queries, so that it is possible to ask for a list of items that have geo-coordinates.

There are three different ways to query for geo-located items:

1.  Using the administrative entity of a city; in this case you have to specify the code of the item (you'll find the code of the city searching it on the top right side on <https://www.wikidata.org/wiki/Wikidata:Main_Page>) and wikidata will return all items that have the city you choose as 'location' (not the coordinates). Using this method will return you fewer articles than using the following two methods.

2.  Using the radius around the location; in this case you have to specify the item of the location and a radius in km. Wikidata will return all items that fall into the circle with center the coordinates of the chosen location.

3.  Using a box around the city. In this case you don't have to specify the item that you are analyzing but you have to choose two items that are placed at two opposite corners with respect to your target location. Then you'll have to specify at which corner they are placed, in the format: SouthWest, SouthEast, NorthWest, NorthEast.

Note that this package will work with two local folders that operate as caches. Once you load the package, this four folders will be created in your environment: *wikidata\_lists*, *wikidata\_items*, *wikidata\_properties* and *wikidata\_classes*.

Installation
------------

QueryWikidataR can be installed from GitHub.

``` r
library(devtools)
install_github("serenasignorelli/QueryWikidataR") 
```

query\_location functions
-------------------------

These three functions will allow you to query for geo-located items in Wikidata. Each of the functions require a different set of parameters.

`query_location_1` allows you to perform the first type of query. The only parameter required here is the location Wikidata identifier. You can put it in an object or simply put it in quotes and put it in the function.

`query_location_2` perform the second type of query. It requires the location code and the length of the radius that you want to virtually draw around the location. The radius has to be in kilometers, and also here you can put it in an object or just specify the number as the second parameter of the function.

`query_location_3` returns the results of the third query. Here you need more parameters, in addition to the location code. You have to choose two locations that will represent two opposite corners of the box that you want to virtually draw around the location. Then, just put in two objects or simply in quotes in the function the two Wikidata identifiers. After each corner identifier, you need to specify which corner they represent, in the format: `'NorthEast'` `'NorthWest'` `'SouthEast'` `'SouthWest'`.

The results of these queries will be stored in the folder *wikidata\_lists*.

query\_location\_property functions
-----------------------------------

These three functions will allow you to get the properties of the geo-located items in Wikidata that you have downloaded with previous functions.

In particular, you will get a list of items with the property, which comes from the Wikidata property *Instance of* (P31).

Each of the functions require the same set of parameters as the previous paragraph functions.

`query_location_property_1` allows you to get the properties from the first type of query. The only parameter required here is the location Wikidata identifier. You can put it in an object or simply put it in quotes and put it in the function.

`query_location_property_2` gets the properties from the second type of query. It requires the location code and the length of the radius that you want to virtually draw around the location. The radius has to be in kilometers, and also here you can put it in an object or just specify the number as the second parameter of the function.

`query_location_property_3` returns the properties from the third query. Here you need more parameters, in addition to the location code. You have to choose two locations that will represent two opposite corners of the box that you want to virtually draw around the location. Then, just put in two objects or simply in quotes in the function the two Wikidata identifiers. After each corner identifier, you need to specify which corner they represent, in the format: `'NorthEast'` `'NorthWest'` `'SouthEast'` `'SouthWest'`.

The results of these queries will be stored in the folder *wikidata\_properties*.

Note that not all the items that resulted from the `query_location` functions have a property. Also some of them could have multiple properties.

That's why this query is performed separately, so that you have as an output a dataframe with the identifier and the property. You will be able to join this dataframe to the items dataframe in a subsequent step of your analysis.

read\_list functions
--------------------

These two functions have been built to read the downloaded text files with items and properties.

They only need one parameter, which is the location Wikidata identifier.

`read_items_list`reads the .txt file as a JSON file from the folder *wikidata\_items* and creates a dataframe that will have four variables (item identifier, name of the item, latitude and longitude)

`read_property_list` reads the .txt file as a JSON file from the folder *wikidata\_properties* and creates a dataframe with only two variables (item identifier and property)

get\_wikidata
-------------

This function simply downloads into the folder *wikidata\_items* all the items in the Wikidata list that came out from the query.

You don't need to run it, it is already called from the function `get_wikipedia_articles`.

get\_wikipedia\_articles
------------------------

This function reads the elements that have been queried and resulted in the Wikidata list. It then downloads all the items that are not already in the folder *wikidata\_items* (through the previous function). It then reads one by one all the items files and extract from them the list of Wikipedia articles with languages for each item. It finally stores the result in a dataframe with three variables (item identifier, title of article and language).

get\_projects\_articles
-----------------------

This function reads the elements that have been queried and resulted in the Wikidata list. It then downloads all the items that are not already in the folder *wikidata\_items* (through the get\_wikidata function). It then reads one by one all the items files and extract from them the list of all the articles in all Wikimedia Foundation projects, with languages and the project the article belongs to for each item. It finally stores the result in a dataframe with four variables (item identifier, project the article belongs to, language and title of article).

Class related functions
-----------------------

A new group of functions has been added to the package. These allow you to get also the class to which a Wikidata item belongs to. Remember that you will have to perform the `query_location_property` procedure **before** running this group of functions.

The procedure to get this output ges through four functions:

1.  `read_property_identifier`. This function reads the output from the `query_location_property` function and gives you as output a dataframe with the Wikidata identifier of the property and the property itself. It requires as a parameter the location Wikidata identifier.

2.  `query_property_class` simply performs the query to Wikidata in order to get the class to which the property belongs to. The parameter to pass is the output of function at point 1. The files downloaded will be saved into *wikidata\_classes* folder.

3.  `read_property_class` reads the results of the query and creates a dataframe with the property name and the related class(es) it belongs to. Also in this case the parameter has to be the output from function at point 1.

4.  `link_property_class` is the most important function of the section. It links the list of Wikidata items that has been queries in the beginning with properties and classes. In this case we have three parameters:
    -   The list of properties obtained from `read_property_identifier`
    -   The list of classes obtained from `read_property_class`
    -   The list of classes obtained from `read_property_list`
    
Finding an item associated with a property
-----------------------

New functions have been added to the package. These allow you to set a property and a value of this property and get the related Wikidata item. These two functions are particularly useful if you need to set a value of a property related to an ID (i.e. Vote Smart ID). 

The parameters that are needed are the property code (i.e. P3344) and set a value of this parameter (i.e. 558). 

You will get a dataframe with the Wikidata identifier of the item (i.e. Q432431), the name of the item and the code that you set. 

The functions are the following:

1.  `query_item_from_property_code`. It simply performs the query to Wikidata in order to get the item related to that particular property code. The parameters to pass are the property code (P____) and the code you decided to set. 

2.  `read_item_from_property_code` This function reads the output from the `query_item_from_property_code` function and gives you as output a dataframe with the Wikidata identifier of the item, the name of the item and the code that you set. The parameters to pass are again the property code (P____) and the code you decided to set. 

NB. These functions work using one property and one single value at a time. In the future I'll evaluate the possibility to vectorize them. 
Don't forget to put the property in quotes(i.e. 'P3344').
