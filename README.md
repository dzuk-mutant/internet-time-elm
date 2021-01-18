# Internet Time

A simple module that lets you use Internet Time in Elm.

Find out the Internet Time from a Posix Time:
```
    InternetTime.fromPosix 1525244393059 -- 333
    InternetTime.fromPosix 1525221281000 -- 65

    InternetTime.displayFromPosix 1525244393059 -- "333"
    InternetTime.displayFromPosix 1525221281000 -- "065"
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
