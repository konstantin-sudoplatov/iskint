package libmain

import atn.AttentionDispatcher
import atn.Podpool
import basemain.CONFIG_FILE
import basemain.Cid
import basemain.GDEBUG_LV
import cpt.ClassRegistry

/** Configuration parameters from the yaml config. */
//var _conf_: Conf = parseConfigWithClassLoader(CONFIG_FILE)

/** Configuration parameters from the yaml config. */
var _conf_: Conf = parseConfigWithFile(CONFIG_FILE)

/** The database manager. */
val _dm_ = DbManager(_conf_)

/** Class registry. */
val _cr_ = ClassRegistry()

/** Shered spirit map object */
val _sm_ = SpiritMap(_dm_)

/** If the DEBUG_ON flag is on, this map is created and filled up. */
val _nm_: HashMap<Cid, String>? = if(GDEBUG_LV >= 0) HashMap() else null

/** Shared attention dispatcher object */
val _atnDispatcher_ = AttentionDispatcher()

/** Shared console thread object */
val _console_ = ConsoleThread()

/** Pool of pods. */
val _pp_ = Podpool()
