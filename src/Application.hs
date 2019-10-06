{-# LANGUAGE TemplateHaskell      #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

-- | This is the main module of the library.
-- It implements "Application.App" and holds the functions used by applications.
module Application
    ( getApplicationDev
    , appMain
    , develMain
    , makeFoundation
    -- * for DevelMain
    , getApplicationRepl
    , shutdownApp
    -- * for GHCI
    , handler
    , db
    ) where

import ClassyPrelude
import Yesod

import qualified Control.Monad.Logger as Logger
import           Data.Bimap (Bimap)
import qualified Data.Cache as Cache
import qualified Database.Persist.Postgresql as Sql
import           Database.Persist.Sql (SqlBackend, SqlPersistT)
import qualified Language.Haskell.TH.Syntax as TH
import qualified Network.HTTP.Client.TLS as TLS
import qualified Network.Wai.Handler.Warp as Warp
import qualified System.Log.FastLogger as FastLogger
import qualified Yesod.Auth as Auth
import qualified Yesod.Core.Types as YesodTypes
import qualified Yesod.Default.Config2 as DefaultConfig
import qualified Yesod.Static as Static

import           Application.App (App(..), Handler, Route(..))
import qualified Application.App as App
import qualified Application.Logger as AppLogger
import           Application.Model (CharacterId)
import qualified Application.Model as Model
import           Application.Settings (Settings)
import qualified Application.Settings as Settings
import           Handler.Admin
import           Handler.Client
import           Handler.Embed
import           Handler.Forum
import           Handler.Play
import           Handler.Site
import qualified Mission

mkYesodDispatch "App" App.resourcesApp

initDB :: ∀ m. MonadIO m => SqlPersistT m (Bimap CharacterId Text)
initDB = do
    Sql.runMigration Model.migrateAll
    dbMigrationsSql <- readFile "config/db.sql"
    Sql.rawExecute (decodeUtf8 dbMigrationsSql) []
    Mission.initDB

makeFoundation :: Settings -> IO App
makeFoundation settings = do
    httpManager <- TLS.getGlobalManager
    logger      <- DefaultConfig.makeYesodLogger
                   =<< FastLogger.newStdoutLoggerSet FastLogger.defaultBufSize
    static      <- staticMode $ Settings.staticDir settings
    queue       <- newTChanIO
    practice    <- Cache.newCache . Just . fromInteger $
                   Settings.practiceCacheExpiry settings

    -- We need a log function to create a connection pool. We need a connection
    -- pool to create our foundation. And we need our foundation to get a
    -- logging function. To get out of this loop, we initially create a
    -- temporary foundation without a real connection pool, get a log function
    -- from there, and then create the real foundation.
    let mkFoundation connPool characterIDs = App {..}
        tempFoundation = mkFoundation
            (error "connPool forced in tempFoundation")
            (error "characterIDs forced in tempFoundation")
        logFunc = messageLoggerSource tempFoundation logger

    pool <- flip Logger.runLoggingT logFunc $ Sql.createPostgresqlPool
        (Sql.pgConnStr  $ Settings.databaseConf settings)
        (Sql.pgPoolSize $ Settings.databaseConf settings)

    conn <- Logger.runLoggingT (Sql.runSqlPool initDB pool) logFunc
    return $ mkFoundation pool conn
  where
    staticMode
      | Settings.mutableStatic settings = Static.staticDevel
      | otherwise                          = Static.static

-- | Convert foundation to a WAI Application by calling @toWaiAppPlain@ and
-- applying some additional middlewares.
makeApplication :: App -> IO Application
makeApplication foundation = do
    logWare <- AppLogger.makeLogWare foundation
    appPlain <- toWaiAppPlain foundation
    return $ logWare $ defaultMiddlewaresNoLogging appPlain

warpSettings :: App -> Warp.Settings
warpSettings foundation =
      Warp.setPort (Settings.port $ App.settings foundation)
    $ Warp.setHost (Settings.host $ App.settings foundation)
    $ Warp.setOnException (\_req e ->
        when (Warp.defaultShouldDisplayException e) $ messageLoggerSource
            foundation
            (App.logger foundation)
            $(Logger.liftLoc =<< TH.qLocation)
            "yesod"
            LevelError
            (FastLogger.toLogStr $ "Exception from Warp: " ++ show e))
      Warp.defaultSettings

-- | Warp settings and WAI Application for @yesod devel@.
getApplicationDev :: IO (Warp.Settings, Application)
getApplicationDev = do
    settings <- getAppSettings
    foundation <- makeFoundation settings
    wsettings <- DefaultConfig.getDevSettings $ warpSettings foundation
    app <- makeApplication foundation
    return (wsettings, app)

getAppSettings :: IO Settings
getAppSettings = DefaultConfig.loadYamlSettings
                 [DefaultConfig.configSettingsYml] [] DefaultConfig.useEnv

-- | Main function for use by @yesod devel@.
develMain :: IO ()
develMain = DefaultConfig.develMainHelper getApplicationDev

-- | The @main@ function for an executable running the site.
appMain :: IO ()
appMain = do
    settings <- DefaultConfig.loadYamlSettingsArgs
        -- fall back to compile-time values, set to [] to require values at runtime
        [Settings.configSettingsYmlValue]

        -- allow environment variables to override
        DefaultConfig.useEnv

    foundation <- makeFoundation settings
    app        <- makeApplication foundation
    Warp.runSettings (warpSettings foundation) app

--------------------------------------------------------------
-- Functions for DevelMain.hs (a way to run the app from GHCi)
--------------------------------------------------------------

getApplicationRepl :: IO (Int, App, Application)
getApplicationRepl = do
    settings   <- getAppSettings
    foundation <- makeFoundation settings
    wsettings  <- DefaultConfig.getDevSettings $ warpSettings foundation
    app1       <- makeApplication foundation
    return (Warp.getPort wsettings, foundation, app1)

shutdownApp :: App -> IO ()
shutdownApp _ = return ()

---------------------------------------------
-- Functions for use in development with GHCi
---------------------------------------------

-- | Run a handler
handler :: Handler a -> IO a
handler h = getAppSettings >>= makeFoundation >>= flip App.unsafeHandler h

-- | Run DB queries
db :: ReaderT SqlBackend Handler a -> IO a
db = handler . runDB
