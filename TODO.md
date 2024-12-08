# To do

## Phase 1 - Advent of code problem only
* Something is off wich changing pages. Race condition? Wrong pages input is shown and local storage gets reset
* Leading zeros issue
* Reset button for initial data 1h
* tab component 3h
* string output to enable copy paste (maybe) 1h using string will help with string parsing below. 1h
* Show code 1h
* Add pages with command line 3h

## Phase 2
* Multiple outputs 1h
* Multiple inputs combined into one 2h
* Implement as command line tool    

* Make renderer interactive
* Make input fields conditional on previous answers


* Use of string parse functions, e.g. camelCase  2h
* Object parser
* Loop parser 4h on list fields of the above.
* Integration with Node to handle file IO

* Sort out icons
* Keyboard accessibility of accordion
* Use Vite asset handling to import file

* Make a component library with Storybook

## Additions for Advent of Code
* Menu
* Remove Html imports


## Things learnt
* chompWhile always succeeds, but chompIf doesn't. This was important when parsing endOfLine
* When parsing oneOf endOfLine and end, it was necessary to do end first so that you got a good error message.
This was because of the way I had to use `backtrackable`. The one without `backtrackable` is the one who's error is returned.