
{-# LANGUAGE TemplateHaskell #-}

module AppDefs where

import Control.Lens
import Control.Monad.Reader
import Control.Concurrent.STM
import Data.Word
import qualified Data.HashMap.Strict as HM
import qualified Codec.Picture as JP

import PersistConfig (PersistConfig)
import HueJSON

-- Some definitions for the App module which we split out here

-- Channel with light ID and update pair
type LightUpdateTChan = TChan (String, LightUpdate)

-- Different updates to the displayed light state
data LightUpdate = LU_OnOff        !Bool
                 | LU_Brightness   !Word8
                 | LU_Color        !(Float, Float, Float) -- RGB
                 | LU_GroupLastOff !String
                 | LU_GroupFirstOn !String
                 | LU_LastOff
                 | LU_FirstOn
                   deriving Show

type Lights      = HM.HashMap String Light    -- Light ID to light
type LightGroups = HM.HashMap String [String] -- Group names to lists of light IDs
type Scenes      = HM.HashMap String Scene    -- Scene ID to scene

-- Application state
data AppEnv = AppEnv
    { _aePC             :: !PersistConfig
    , _aeBC             :: !BridgeConfig
    , _aeLights         :: !(TVar Lights)
    , _aeLightGroups    :: !(TVar LightGroups)
    , _aeScenes         :: !Scenes
    , _aeBroadcast      :: !LightUpdateTChan
    , _aeColorPickerImg :: !(JP.Image JP.PixelRGBA8)
    }

makeLenses ''AppEnv

-- Our main application monad
type AppT m = ReaderT AppEnv m
type AppIO = AppT IO

