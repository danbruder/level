module Data.Post exposing (Post, PostConnection, PostEdge, postDecoder, postConnectionDecoder, add)

import Date exposing (Date)
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Data.Group exposing (Group, groupDecoder)
import Data.PageInfo exposing (PageInfo, pageInfoDecoder)
import Data.SpaceUser exposing (SpaceUser, spaceUserDecoder)
import Util exposing (dateDecoder)


-- TYPES


type alias Post =
    { id : String
    , body : String
    , bodyHtml : String
    , author : SpaceUser
    , groups : List Group
    , postedAt : Date
    }


type alias PostEdge =
    { node : Post
    }


type alias PostConnection =
    { edges : List PostEdge
    , pageInfo : PageInfo
    }



-- DECODERS


postDecoder : Decode.Decoder Post
postDecoder =
    Pipeline.decode Post
        |> Pipeline.required "id" Decode.string
        |> Pipeline.required "body" Decode.string
        |> Pipeline.required "bodyHtml" Decode.string
        |> Pipeline.required "author" spaceUserDecoder
        |> Pipeline.required "groups" (Decode.list groupDecoder)
        |> Pipeline.required "postedAt" dateDecoder


postConnectionDecoder : Decode.Decoder PostConnection
postConnectionDecoder =
    Pipeline.decode PostConnection
        |> Pipeline.custom (Decode.at [ "edges" ] (Decode.list postEdgeDecoder))
        |> Pipeline.custom (Decode.at [ "pageInfo" ] pageInfoDecoder)


postEdgeDecoder : Decode.Decoder PostEdge
postEdgeDecoder =
    Pipeline.decode PostEdge
        |> Pipeline.custom (Decode.at [ "node" ] postDecoder)



-- MUTATIONS


add : Post -> PostConnection -> PostConnection
add post connection =
    let
        edges =
            connection.edges
    in
        if List.any (\{ node } -> node.id == post.id) edges then
            connection
        else
            { connection | edges = (PostEdge post) :: edges }
