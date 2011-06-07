name "test"
description "A test role that includes multiple recipes"
run_list "recipe[getting-started]", "recipe[imagemagick]" , "recipe[perf-test]",
         "recipe[ssmtp]"