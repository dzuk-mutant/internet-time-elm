# Internet Time

A simple module that lets you use Internet Time in Elm, for both displaying a particular day's time, as well as converting lengths of time into beats.


```
    InternetTime.fromPosix 1525244393059 -- 333
    InternetTime.fromPosix 1525221281000 -- 65

    InternetTime.stringFromPosix 1525244393059 -- "333"
    InternetTime.stringFromPosix 1525221281000 -- "065"

    millisToBeats 1380000 -- 23 minutes = 15.972222 beats
```
