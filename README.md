# Checkout

Pricing rules have the following structure:

[Description][Items][iQuant][Discounts][dQuant]

Description: a name or description of the offer, for example "2 for 1 on Green Tea!"

Items: An array of item codes. The special code "£" means that the rule is conditional on the total value of the basket rather then on the items in the basket.

iQuant: The second part of the rule condition, this is an array of item quantities. The structure of each element is [comparitor:flag:quantity] where the first part is comparison operator such as ">=" or "==", with an empty comparitor being treated the same as greater than or equal to the quantity specified (The reason this is seperated from the "<=" is that the rules behave differently when excluding items from future rules. For example, in a 2 for 1 deal, you only want to exclude 2 items at a time, whereas with a 'buy 3 or more' deal you will probably want to exclude all of the items. The second part is flag, if this is empty then the condition is based off of item quantities. If the flag is "£" then the condition is based off of the money spent on the associated item. The final part is an integer representing either a quantity or amount of money depending on the flag.

Discounts: This is an array of discounts to be applied. If the discount is an item code then the discount is the price of that item. If the discount is a number then that is the value of the discount.

dQuant: This array specifies how many times each discount is to be applied. These values can also take the form of product codes, in which case the number of times to apply the discount is equal to the quantity of that particular item.
