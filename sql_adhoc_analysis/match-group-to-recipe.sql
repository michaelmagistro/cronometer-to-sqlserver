-- working on getting a match between the servings and custom_recipes tables
-- need to add a count in the recipe and how many hits match in the servings.group
-- if all match, then the recipe is a match... amounts are a different story and perhaps not possible as portion sizes at time of consumption differs
-- unless, that is, you do some math of the recipe itself.. and if the ratio of all of the ingredients are consistent, then, perhaps it can be done...
	-- namely, to be able to confidently match up a servings group to the originating recipe
select top 100000
	s.*
	, cr.*
from Custom_Recipes cr
cross apply (
	select [day], [group], food_name from servings 
) s
where cr.ingredient = s.food_name