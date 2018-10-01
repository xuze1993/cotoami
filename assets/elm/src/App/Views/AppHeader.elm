module App.Views.AppHeader exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onFocus, onBlur, onSubmit)
import Html.Keyed
import Utils.UpdateUtil exposing (..)
import Utils.EventUtil exposing (onLinkButtonClick)
import Utils.HtmlUtil exposing (materialIcon)
import App.Types.SearchResults exposing (SearchResults)
import App.Model exposing (Model)
import App.Messages as AppMsg
    exposing
        ( Msg
            ( MoveToHome
            , NavigationToggle
            , SearchInputFocusChanged
            , ClearQuickSearchInput
            , QuickSearchInput
            , Search
            )
        )
import App.Views.AppHeaderMsg as AppHeaderMsg exposing (Msg(..))
import App.Submodels.Context exposing (Context)
import App.Submodels.LocalCotos
import App.Submodels.Modals exposing (Modals, Modal(SigninModal, ProfileModal))
import App.Messages
import App.Modals.SigninModal


type alias UpdateModel model =
    Modals { model | signinModal : App.Modals.SigninModal.Model }


update : Context context -> AppHeaderMsg.Msg -> UpdateModel model -> ( UpdateModel model, Cmd AppMsg.Msg )
update context msg model =
    case msg of
        OpenSigninModal ->
            { model
                | signinModal =
                    App.Modals.SigninModal.initModel
                        model.signinModal.authSettings
            }
                |> App.Submodels.Modals.openModal SigninModal
                |> withoutCmd

        OpenProfileModal ->
            App.Submodels.Modals.openModal ProfileModal model |> withoutCmd


view : Model -> Html AppMsg.Msg
view model =
    div [ id "app-header" ]
        [ div [ class "location" ]
            (model.cotonoma
                |> Maybe.map
                    (\cotonoma ->
                        [ a [ class "to-home", onLinkButtonClick MoveToHome, href "/" ]
                            [ materialIcon "home" Nothing ]
                        , materialIcon "navigate_next" (Just "arrow")
                        , span [ class "cotonoma-name" ] [ text cotonoma.name ]
                        , if cotonoma.shared then
                            span [ class "shared", title "Shared" ]
                                [ materialIcon "people" Nothing ]
                          else
                            Utils.HtmlUtil.none
                        , navigationToggle model
                        ]
                    )
                |> Maybe.withDefault
                    [ materialIcon "home" (Just "in-home")
                    , navigationToggle model
                    ]
            )
        , div [ class "user" ]
            (model.session
                |> Maybe.map
                    (\session ->
                        [ quickSearchForm model.searchResults
                        , a
                            [ title "Profile"
                            , onClick (AppMsg.AppHeaderMsg OpenProfileModal)
                            ]
                            [ img [ class "avatar", src session.amishi.avatarUrl ] [] ]
                        ]
                    )
                |> Maybe.withDefault
                    [ a
                        [ class "tool-button"
                        , title "Sign in"
                        , onClick (AppMsg.AppHeaderMsg OpenSigninModal)
                        ]
                        [ materialIcon "perm_identity" Nothing ]
                    ]
            )
        ]


quickSearchForm : SearchResults -> Html AppMsg.Msg
quickSearchForm searchResults =
    Html.form
        [ class "quick-search"
        , onSubmit Search
        ]
        [ Html.Keyed.node
            "span"
            []
            [ ( toString searchResults.inputResetKey
              , input
                    [ type_ "text"
                    , class "search-input"
                    , defaultValue searchResults.query
                    , onFocus (SearchInputFocusChanged True)
                    , onBlur (SearchInputFocusChanged False)
                    , onInput QuickSearchInput
                    ]
                    []
              )
            ]
        , materialIcon "search" (Just "search")
        , if App.Types.SearchResults.hasQuery searchResults then
            a
                [ class "tool-button clear-query"
                , onLinkButtonClick ClearQuickSearchInput
                ]
                [ materialIcon "close" Nothing ]
          else
            span [] []
        ]


navigationToggle : Model -> Html AppMsg.Msg
navigationToggle model =
    a
        [ classList
            [ ( "tool-button", True )
            , ( "toggle-navigation", True )
            , ( "hidden", App.Submodels.LocalCotos.isNavigationEmpty model )
            ]
        , onClick NavigationToggle
        ]
        [ materialIcon
            (if model.navigationOpen then
                "arrow_drop_up"
             else
                "arrow_drop_down"
            )
            Nothing
        ]
