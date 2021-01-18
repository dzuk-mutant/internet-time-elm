# Internet Time

A simple module that lets you use Internet Time in Elm.

Find out the Internet Time from a Posix Time:
``` 
    oneTime = Time.millisToPosix 1525244393059
    anotherTime = Time.millisToPosix 1525221281000

    InternetTime.fromPosix oneTime -- 333
    InternetTime.fromPosix anotherTime -- 65

    InternetTime.displayFromPosix oneTime -- "333"
    InternetTime.displayFromPosix anotherTime -- "065"
```

Convert milliseconds into beats:

```
    millisToBeats 1380000 -- 23 minutes = 15.972222 beats

```

Use the cadence of internet time in your application:

```
    subscriptions : Model -> Sub Msg
    subscriptions model =
        Time.every centibeat Tick
```
