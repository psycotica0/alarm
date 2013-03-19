module Main (main) where

import qualified Network.MPD as MPD
import qualified Data.ByteString.Char8 as BS
import System.Random (randomRs, getStdGen)

interrupt :: MPD.PlaylistName -> MPD.MPD MPD.Status
interrupt nonce = do
	st <- MPD.status
	MPD.save nonce
	MPD.clear
	MPD.load $ MPD.PlaylistName $ BS.pack "alarm"
	MPD.repeat True
	MPD.random False
	MPD.play $ Just 0
	return st

reset :: MPD.PlaylistName -> MPD.Status -> MPD.MPD ()
reset nonce orig_status = do
	MPD.stop
	MPD.clear
	MPD.load nonce
	MPD.rm nonce
	return_to_status orig_status

return_to_status :: MPD.Status -> MPD.MPD ()
return_to_status state = do
	MPD.random $ MPD.stRandom state
	MPD.repeat $ MPD.stRepeat state
	reset_position (MPD.stSongPos state, MPD.stTime state)
	resume $ MPD.stState state
	where
	reset_position (Just track, (pos, _)) = MPD.seek track $ floor pos
	reset_position (Nothing, _) = MPD.seek 0 0
	resume MPD.Playing = MPD.play Nothing
	resume MPD.Stopped = MPD.stop
	resume MPD.Paused = MPD.pause True

main = do
	nonce <- fmap ((MPD.PlaylistName).(BS.pack).(take 6).randomRs ('a', 'z')) getStdGen
	(Right st) <- MPD.withMPD $ interrupt nonce
	getLine
	MPD.withMPD $ reset nonce st
