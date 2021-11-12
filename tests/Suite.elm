module Suite exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)
import InternetTime
import Time

suite : Test
suite =
    describe "conversion tests"
        [ testFromPosix floatList
        , testDisplay displayList
        , testDisplayTwoDecimals twoDecimalList
        ]

floatList : List ( Int, Float )
floatList =
    [ ( 1163357506000, 827 )
    , ( 1163297059000, 127 )
    , ( 1636721506000, 577 )
    , ( 1163289600000, 41 )
    , ( 1163286000000, 0 )
    , ( 1136098772000, 333 )
    ]

displayList : List ( Int, String )
displayList =
    [ ( 1163357506000, "827" )
    , ( 1163297059000, "127" )
    , ( 1636721506000, "577" )
    , ( 1163289600000, "041" )
    , ( 1163286000000, "000" )
    , ( 1136098772000, "333" )
    ]

twoDecimalList : List ( Int, String )
twoDecimalList =
    [ ( 1525244393059, "333.25" )
    , ( 1525221281000, "065.75" )
    ]



{-| 
-}
testFromPosix : List ( Int, Float ) -> Test
testFromPosix tests =
    let
        fromPosixExpec =
            \i f -> Expect.within (Expect.Absolute 0.000001) f (InternetTime.fromPosix <| Time.millisToPosix i)
    in
    describe "fromPosix" <|
        List.indexedMap (singleConversionTest fromPosixExpec) tests




{-| 
-}
testDisplay : List ( Int, String ) -> Test
testDisplay tests =
    let
        fromPosixExpec =
            \i s -> Expect.equal s (InternetTime.displayFromPosix <| Time.millisToPosix i)
    in
    describe "displayFromPosix" <|
        List.indexedMap (singleConversionTest fromPosixExpec) tests



{-| 
-}
testDisplayTwoDecimals : List ( Int, String ) -> Test
testDisplayTwoDecimals tests =
    let
        fromPosixExpec =
            \i s -> Expect.equal s (InternetTime.displayFromPosixCustom 2 <| Time.millisToPosix i)
    in
    describe "displayFromPosix Two Digits" <|
        List.indexedMap (singleConversionTest fromPosixExpec) tests



{-| Tests a conversion from a pair of two different types.
-}
singleConversionTest : (a -> b -> Expectation) -> Int -> ( a, b ) -> Test
singleConversionTest expectation index inputs =
    let
        int =
            Tuple.first inputs

        float =
            Tuple.second inputs
    in
    test
        ("Test #" ++ String.fromInt (index + 1))
        (\_ -> expectation int float)
