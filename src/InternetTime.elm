module InternetTime exposing ( fromPosix
                             , stringFromPosix

                             , fromPosixCustom
                             , stringFromPosixCustom

                             , beat
                             , centibeat
                             , millisToBeats
                             )

{-| A module for converting Posix Time into
Internet Time for that particular day, as well as converting
lengths of time into beats.


# Daily time

These functions convert a Posix Time (which is UTC) to
a displayable Internet Time for that particular day.

(This also includes the static Internet Time timezone, which is UTC+1.)

@docs fromPosix, stringFromPosix



# Lenghts of time
Using and creating lengths of time (measured in milliseconds)
to Internet Time beats.

@docs beat, centibeat, millisToBeats


# Custom daily time

Just in case you need something extra, but `fromPosix` and
`stringFromPosix` should probably cover all of your needs.

@docs fromPosixCustom, stringFromPosixCustom

-}


import Time
import String exposing (dropRight, padLeft, right)




----------------------------- DAILY TIME ------------------------------

{-| Convert a `Time.Posix` to Internet Time for that
particular day as a raw Int.

    InternetTime.fromPosix 1525244393059 -- 333
    InternetTime.fromPosix 1525221281000 -- 65
-}

fromPosix : Time.Posix -> Int
fromPosix = fromPosixCustom 0


{-| Convert a `Time.Posix` to Internet Time for
that particular day.

The output is a `String` with padded 0s so it's
always three digits.

    InternetTime.stringFromPosix 1525244393059 -- "333"
    InternetTime.stringFromPosix 1525221281000 -- "065"
-}

stringFromPosix : Time.Posix -> String
stringFromPosix = stringFromPosixCustom 0







----------------------------- LENGTHS OF TIME ------------------------------



{-| One Internet Time beat in milliseconds.

This is the largest possible measurement of time in Internet Time.

1 beat = 86400 milliseconds. (86.4 seconds)

    subscriptions : Model -> Sub Msg
    subscriptions model =
        Time.every beat Tick

-}
beat : Float -- Int == milliseconds in Time
beat =
    86400


{-| One Internet Time centibeat in milliseconds.

Centibeats are quite rarely used in internet time,
but if you want to use them, it's here.

- 1 centibeat = 864 milliseconds.
- 1 centibeat = 1/100 beats.

-}
centibeat : Float -- Int == milliseconds in Time
centibeat =
    864


{-| Convert an Int representing milliseconds to raw beats
 (1/1,000th of a day).
    
    millisToBeats 1380000 -- 23 minutes = 15.972222 beats
-}
millisToBeats : Int -> Float
millisToBeats t =
    toFloat t / beat






----------------------------- CUSTOM STUFF ------------------------------



{-| Convert a `Time` to the Internet Time for that particular day.

This calculation also converts the time to Internet Time's timezone (UTC+01:00).

The first argument is for how much detail (extra decimal points)
you want - beats (0) are the largest form of measurement possible.

    convert 0 1525244393059 -- 333 (beats)
    convert 2 1525244393059 -- 33325 (centibeats)
    convert 0 1525221281000 -- 65 (beats)
    convert 2 1525221281000 -- 6575 (centibeats)

This returns an `Int` no matter how much detail because it's more accurate to use `Int` than `Float` for this type of context.
(Floating point accuracy can waver and create artefacts when displaying or computing.)
-}

fromPosixCustom : Int -> Time.Posix -> Int
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
        |> (\x -> modBy x (1000 * thousands)) -- remove the digits at that represent more than a day's worth of beats



{-| Convert a `Time` to a Internet Time for that particular day in the form of a display-ready `String`.
This calculation also converts the time to Internet Time's timezone (UTC+01:00).
The first argument is for how much detail (extra digits) you want - beats are the largest form of measurement possible.

    display 0 1525244393059 -- "333"
    display 2 1525244393059 -- "333.25" (centibeat display)
    display 0 1525294572000 -- "914"
    display 2 1525294572000 -- "914.37" (centibeat display)

This time is padded with zeroes so you get the proper 3-number display for beats.

    display 0 1525221281000 -- "065"
    display 2 1525221281000 -- "065.75" (centibeat display)

-}

stringFromPosixCustom : Int -> Time.Posix -> String
stringFromPosixCustom decimalPlaces time =
    let
        displayTime =
            time
            |> fromPosixCustom decimalPlaces
            |> String.fromInt
            |> padLeft (3 + decimalPlaces) '0' -- pad with 0s

    in
        if decimalPlaces <= 0 then displayTime -- if there's no extra detail, don't add a period.

        else
            dropRight decimalPlaces displayTime ++ "." ++ right decimalPlaces displayTime



