module Model.Channel
  ( Channel(..)
  , interruptible
  , Channeling(..)
  , ignoreStun
  , turnDur
  ) where

import ClassyPrelude.Yesod

import Model.Internal (Channel(..), Channeling(..))
import Model.Duration (Duration)

interruptible :: Channel -> Bool
interruptible Channel {dur = Control{}} = True
interruptible Channel {dur = Action{}}  = True
interruptible _                         = False

ignoreStun :: Channeling -> Bool
ignoreStun Passive   = True
ignoreStun Ongoing{} = True
ignoreStun _         = False

turnDur :: Channeling -> Duration
turnDur (Action d)  = d
turnDur (Control d) = d
turnDur (Ongoing d) = d
turnDur _           = 0
