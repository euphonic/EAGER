import re
test_str = "GE has 100,000 employees, 400 lamas. 62.42 millions, 802,723 dogs, 1 thousand monkeys, and 1,000,005 eggs"
test_str = re.sub("[,.]", "", test_str)
print (test_str)
p = re.compile(r'\b\d+\b')
print(re.findall(p, test_str))
