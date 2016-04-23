---
layout: post
title:  "Sorting (Part 1.0)&#58Bubble Sort"
date:   2016-04-22 01:08:11 +0100
categories: who nullbyte
tags:
 - sorting
 - bubble sort
post_author: oaktree
---

Alright, 0x00 community! Here we go... Bubble Sort.

## What Is Bubble Sort?

Bubble Sort is a certain sorting algorithm that is often used as an introduction to sorting. It is not the best sorting algorithm, but it is very easy to implement and works fast with small sample sizes.

Bubble Sort works like this: go through an unsorted array. If one element is bigger than the next element, switch those elements. It does this through the entire array.

But, how do we know the array is sorted after just one run? We don't. We have to go through that array at most N times, where N is the size of the array to sort.

So, we cycle through the array again and swap values when an element is bigger than the one after it, meaning that `a[k] > a[k+1] == true`, where `0 <= k < N-1`.

Follow this link for a visual representation of Bubble Sort.

Let's Implement the Algorithm...

## Ruby

First Up: Ruby, because it's easier.

{% highlight ruby linenos %}
#! /usr/bin/env ruby
 
# get input
puts "give me a string"
str = gets.chomp.split('')
strlen = str.length
# end get input
 
changes_made = false #optimization to reduce time complexity
 
for i in 0..(strlen - 2) # vvv
# 0 thru two less than the length of str, because we never need to see the last element explicitly
# because we reach later on with str[j+1]
 
    for j in 0..(strlen - 2)
 
        if str[j] > str[j+1]
            str[j],str[j+1] = str[j+1],str[j] # Ruby way to swap vars
            changes_made = true # record that a change was made in this runthrough
        end
 
    end
 
    break if !changes_made
    # if there were no changes this run, the list is sorted
    # why continue "sorting" if we've already done the job?
 
    # if there was a change made, set that to false and run through again,
    # unless, of course, we've already gone through
    changes_made = false
end
 
puts str.join('') #print out the result, but first make it a string and not an array
{% endhighlight %}

The first eight lines are just about taking input from the user.

Line 9 declares a boolean called `changes_made`. As said in the comment, it's an optimization and is really not that important.

On Line 11, we start a `for` loop. I know, I know; you're going to say, "But oaktree, we don't use `for` loops in Ruby!" The `for` loop is preferential in this case because it explicitly denotes what we are doing, and helps to translate over to the C++ code I'll show you later.

Inside that for, we have another `for`, but with `j` instead of `i`, because we want to keep the value of `i` as a tracker for how many times we've looped through the array.

So, we continue in that nested for loop to swap the values `if str[j] > str[j+1]`.

After we close out that nested for, we check if any changes were made by reading the value of changes_made. There's no reason to keep going through the array if it's already been sorted and, if the array is already sorted, the next round -- or the just-finished round -- of the nested for wouldn't have changed the array at all.

Then, we print out the result. Tada!

## C++

{% highlight c++ linenos %}
#include <iostream>
#include <string>
#include <vector>
#include <cstdlib>
 
using namespace std;
 
void bubblesort(vector<char>& vec) {
    int n = vec.size();
 
    // nest loops because O(n^2)
    // changes_made is an optimization that can reduce runtime in certain conditions
    bool changes_made = false;
 
    for (int i = 0; i < n - 1; i++) {
 
        for (int j = 0; j < n - 1; j++) {
            if (vec[j] > vec[j+1]) {
 
                // swap them
                char temp = vec[j];
                vec[j] = vec[j+1];
                vec[j+1] = temp;
 
                // tell program to run thru vec at least once more
                changes_made = true;
            }
        }
 
        // optimization to exit loop if no changes made
        if (!changes_made) break;
 
        changes_made = false;
    }
}
 
int main() {
    cout << "give me a string" << endl;
    string s; getline(cin, s);
 
    vector<char> vec(s.begin(), s.end());
 
    if (!vec.empty()) bubblesort(vec);
 
    string str(vec.begin(), vec.end());
 
    cout << str << endl;
    return 0;
}
{% endhighlight %}

Okay, one big different is that I've made a special `bubblesort(...)` function instead of writing it all inline. This is because I wanted to isolate the actual sorting from main().

Note: don't look through `main()` too closely, because that has all the gathering and processing of input.

In `bubblesort(...)`, we have the same two, nested for loops. The notation of the loops changes slightly because C++ and Ruby are very different, syntax-wise. However, the algorithm is fundamentally the same.

Note: one big thing that may throw you off is the vector notation that you see inside `bubblesort(...)`'s parenthesis. `vector<char>& vec` means that our function takes a parameter that is a vector of characters. A vector is essentially an array, but it expandable and easier to manipulate than your typical C array, because it dynamically handles memory in almost all cases.

Anyway, treat the `vector` as an array for our purposes.

## Conclusion
Well, I feel I have sufficiently explained Bubble Sort. Your "homework" is to compile and/or run the programs and test them out. If you stumble upon a bug, please PM me.

I want you guys to think about the complexity of Bubble Sort. Is it an efficient algorithm? Could we make it better? What are its limitations?

I'll be talking about complexity in the near future, but I figure I'd let you guys ponder the subject first.

Thanks 0x00ers,

oaktree
