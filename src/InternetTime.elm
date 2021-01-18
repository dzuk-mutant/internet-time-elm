module InternetTime exposing ( fromPosix
                             , displayFromPosix

                             , fromPosixCustom
                             , displayFromPosixCustom

                             , beat
                             , centibeat
                             , millisToBeats
                             )

{-| A module for using Internet Time.


# Daily time

These functions convert a Posix Time to
a displayable Internet Time) for that particular day.

(This also includes moving from the Posix timezone (UTC) to
Internet Time's timezone (UTC+1).)

Traditionally, Internet Time is displayed with a @ beforehand (ie. @333)
but for the sake of simplicity, that kind of decoration is left up to
you to put into your interfaces in whatever way you prefer.

@docs fromPosix, displayFromPosix



# Lenghts of time
Converting milliseconds into beats,
and using the cadence of Internet Time in your application.

@docs beat, centibeat, millisToBeats


# Custom daily time

Just in case you need something with extra detail like
counting time with centibeats as well.

In regular cases, `fromPosix` and `displayFromPosix` should
probably cover all of your needs.

@docs fromPosixCustom, displayFromPosixCustom

-}


import Time
import String exposing (padLeft)




----------------------------- DAILY TIME ------------------------------

{-| Converts a `Time.Posix` to Internet Time for that
particular day as a raw Float.

    oneTime = Time.millisToPosix 1525244393059
    anotherTime = Time.millisToPosix 1525221281000

    InternetTime.fromPosix oneTime -- 333
    InternetTime.fromPosix anotherTime -- 65
-}
fromPosix : Time.Posix -> Float
fromPosix = fromPosixCustom 0


{-| Converts a `Time.Posix` to Internet Time for
that particular day. The output is a `String`
with padded 0s if necessary so it displays
as a traditionally correct 3 digit number.

    oneTime = Time.millisToPosix 1525244393059
    anotherTime = Time.millisToPosix 1525221281000
    
    InternetTime.displayFromPosix oneTime -- "333"
    InternetTime.displayFromPosix anotherTime -- "065"
-}
displayFromPosix : Time.Posix -> String
displayFromPosix = displayFromPosixCustom 0







----------------------------- LENGTHS OF TIME ------------------------------



{-| One Internet Time beat in milliseconds.

This is the largest possible measurement of time in Internet Time.

- 1 beat = 86400 milliseconds. (86.4 seconds)

-}
beat : Int -- Int == milliseconds in Time
beat =
    86400


{-| One Internet Time centibeat in milliseconds.

- 1 centibeat = 864 milliseconds.
- 1 centibeat = 1/100 beats.

Centibeats are quite rarely used in Internet Time,
but it would be quite useful if you want to update your
time subscription in something that matches the
timing of beats exactly, but with something much
more precise.


    subscriptions : Model -> Sub Msg
    subscriptions model =
        Time.every centibeat Tick

-}
centibeat : Int -- Int == milliseconds in Time
centibeat =
    864


{-| Convert an Int representing milliseconds to raw beats
 (1/1,000th of a day).
    
    millisToBeats 1380000 -- 23min = 15.972222 beats
-}
millisToBeats : Int -> Float
millisToBeats t =
    toFloat t / toFloat beat






----------------------------- CUSTOM STUFF ------------------------------



{-| Converts a `Time.Posix` to the Internet Time for that particular day as a `Float`.

The first argument is for how much detail (extra decimal points)
you want - beats (0) are the largest form of measurement possible.

    oneTime = Time.millisToPosix 1525244393059
    anotherTime = Time.millisToPosix 1525221281000

    fromPosixCustom 0 oneTime -- 333
    fromPosixCustom 2 oneTime -- 333.25 (extra detail w/ centibeats)
    fromPosixCustom 0 anotherTime -- 65
    fromPosixCustom 2 anotherTime -- 65.75 (extra detail w/ centibeats)
-}
fromPosixCustom : Int -> Time.Posix -> Float
fromPosixCustom decimalPlaces time =
    let
        thousands = 10^decimalPlaces
    in
        time
        |> Time.posixToMillis
        |> (+) 3600000 -- add an hour to get the right timezone (UTC+01:00)
        |> millisToBeats -- convert to beats
        |> (*) (toFloat thousands) -- shift the decimal place depending on how much detail
        |> floor
        |> modBy (1000 * thousands) -- remove the digits at that represent more than a day's worth of beats
        |> (\t -> toFloat t / toFloat thousands) -- put the decimals back in to bring back decimal points


{-| Converts a `Time.Posix` to a Internet Time for that particular day
in the form of a display-ready `String`.

The first argument is for how much detail (extra digits) you want -
beats are the largest form of measurement possible.

    oneTime = Time.millisToPosix 1525244393059
    anotherTime = Time.millisToPosix 1525294572000

    displayFromPosixCustom 0 oneTime -- "333"
    displayFromPosixCustom 2 oneTime -- "333.25" (extra detail w/ centibeats)
    displayFromPosixCustom 0 anotherTime -- "914"
    displayFromPosixCustom 2 anotherTime -- "914.37" (extra detail w/ centibeats)

This time is padded with zeroes so you get the traditionally
correct 3-digit display for beats.

    thirdTime = Time.millisToPosix 1525221281000

    displayFromPosixCustom 0 thirdTime -- "065"
    displayFromPosixCustom 2 thirdTime -- "065.75" (extra detail w/ centibeats)

-}
displayFromPosixCustom : Int -> Time.Posix -> String
displayFromPosixCustom decimalPlaces time =
    let
        -- a decimal place counts as an extra character,
        -- so we need to account for it when padding.
        padding =
            if decimalPlaces == 0 then 3
            else 4 + decimalPlaces
    in
        time
        |> fromPosixCustom decimalPlaces
        |> String.fromFloat
        |> padLeft padding '0' -- pad with 0s
