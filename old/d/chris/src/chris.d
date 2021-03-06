module chris;
import std.stdio;
import std.format, std.concurrency, core.thread;
import proj_data, proj_funcs;

import stat.stat_registry;
import crank.crank_registry;
import cpt.cpt_stat;
import atn.atn_dispatcher;
import console_thread;
import messages;
import chri_types, chri_data;

void main()
{

	preloadConceptMaps(_sm_, _nm_);

    // Capture Tid of the main thread.
    cast()_mainTid_ = thisTid;

    // Spawn the attention dispatcher thread.
    cast()_attnDispTid_ = spawn(&attention_dispatcher_thread_func);

    // Spawn the console thread thread. We don't need to capture its tid. It will introduce itself to the attention circle
    // thread and that would be enough.
    spawn(&console_thread_func);

    // Wait for messages. Those should be only requests for termination from console or exceptions that should be rethrown.
    while(true) {

        TerminateApp_msg termMsg;
        CirclesAreFinished_msg finMsg;
        Throwable ex;
        Variant var;
        receive(
            (immutable TerminateApp_msg m){termMsg = cast()m;},
            (immutable CirclesAreFinished_msg m){finMsg = cast()m;},
            (shared Throwable e){ex = cast()e;},
            (Variant v) {var = v;}
        );

        if      // TerminateAppMsg message has come?
                (termMsg)
        {   //yes: terminate other subthreads, terminate application
            (cast()_attnDispTid_).send(new immutable TerminateApp_msg());
        }
        else if // are all attention circles finished?
                (finMsg)
        {   //yes: can clear up the thread pool and exit
            goto TERMINATE_APPLICATION;
        }
        else if // has one of the thead thrown an exception?
                (ex)
        {   // rethrow it
            throw ex;
        }
        else if // has come an unexpected message?
                (var.hasValue)
        {   // log it
            logit(format!"Unexpected message to the main thread: %s"(var.toString));
        }
    }

TERMINATE_APPLICATION:
    thread_joinAll;
    writeln("good bye, world!"); stdout.flush;
}

/**
		Load the spirit and name maps with static concepts. Load name map with dynamic concepts names (dynamic concepts
	themselves will be loaded from DB into the spirit maps dynamically, when they are needed).
*/
void preloadConceptMaps(ref shared SpiritMap sm, ref immutable string[Cid] nm) {

    // Create and load spirit and name maps for static concepts.
    sm = new shared SpiritMap;
    foreach(sd; createStatDescriptors) {
        sm.add(new SpStaticConcept(sd.cid, sd.fp, sd.call_type));
        cast()nm[sd.cid] = sd.name;
    }

    // Load the name map
    foreach(dd; createDynDescriptors) {
        cast()nm[dd.cid] = dd.name;
    }
}
