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

{-| Convert a `Time.Posix` to Internet Time for that
particular day as a raw Float.

    InternetTime.fromPosix 1525244393059 -- 333
    InternetTime.fromPosix 1525221281000 -- 65
-}
fromPosix : Time.Posix -> Float
fromPosix = fromPosixCustom 0


{-| Convert a `Time.Posix` to Internet Time for
that particular day.

The output is a `String` with padded 0s so it's
always three digits long.

    InternetTime.displayFromPosix 1525244393059 -- "333"
    InternetTime.displayFromPosix 1525221281000 -- "065"
-}
displayFromPosix : Time.Posix -> String
displayFromPosix = displayFromPosixCustom 0







----------------------------- LENGTHS OF TIME ------------------------------



{-| One Internet Time beat in milliseconds.

This is the largest possible measurement of time in Internet Time.

1 beat = 86400 milliseconds. (86.4 seconds)

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



{-| Convert a `Time` to the Internet Time for that particular day as a Float.

This calculation also converts the time to Internet Time's timezone (UTC+01:00).

The first argument is for how much detail (extra decimal points)
you want - beats (0) are the largest form of measurement possible.

    fromPosixCustom 0 1525244393059 -- 333
    fromPosixCustom 2 1525244393059 -- 333.25 (extra detail w/ centibeats)
    fromPosixCustom 0 1525221281000 -- 65
    fromPosixCustom 2 1525221281000 -- 65.75 (extra detail w/ centibeats)

This returns an `Int` no matter how much detail because it's more accurate to use `Int` than `Float` for this type of context.
(Floating point accuracy can waver and create artefacts when displaying or computing.)
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


{-| Convert a `Time` to a Internet Time for that particular day in the form of a display-ready `String`.
This calculation also converts the time to Internet Time's timezone (UTC+01:00).
The first argument is for how much detail (extra digits) you want - beats are the largest form of measurement possible.

    displayFromPosixCustom 0 1525244393059 -- "333"
    displayFromPosixCustom 2 1525244393059 -- "333.25" (extra detail w/ centibeats)
    displayFromPosixCustom 0 1525294572000 -- "914"
    displayFromPosixCustom 2 1525294572000 -- "914.37" (extra detail w/ centibeats)

This time is padded with zeroes so you get the proper 3-number display for beats.

    displayFromPosixCustom 0 1525221281000 -- "065"
    displayFromPosixCustom 2 1525221281000 -- "065.75" (extra detail w/ centibeats)

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
