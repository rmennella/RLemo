function [reverse] = reverseItemsRandom(nbItems, nbReverse)
%function to reverse randomly a part of items
%   reverse is the list of items to reverse 
%   nbItems is the numbers of items in the Experiment
%   nbReverse is the part of items to reverse (between 0 and 1)
%   
%   example : 
%   To reverse 50% in a experiment with 30 items ==>
%   reverse = directionRandom(30, 0.5)


finalLength = ceil(nbItems*nbReverse); %number of items to reverse

listItems = randperm(nbItems); %list of items with random order
listItemsReverse = listItems([1:finalLength]); %items to reverse
reverse = sort(listItemsReverse); %sort list of items to reverse

end

