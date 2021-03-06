module messages;
import std.concurrency, core.thread;

import proj_data;

import cpt.abs.abs_concept;

/// Common ancestor of all messages.
/// Object must be created in the sender's thread, so that sender's tid was correctly set up. Do not create message objects beforehand!
immutable abstract class Msg {

    /// Constructor. Uses the current Tid as sender's.
    this() {
        // We assume that the object is created in the sender's thread (probably, right in the call of the send() function.
        _senderTid = cast(immutable)thisTid;
    }

    /// Getter
    @property Tid senderTid() immutable {
        return cast()_senderTid;
    }

protected:
    Tid _senderTid;
}

/// Request for termination of application, usually from console_thread, after that from the main thread over all the structure.
immutable class TerminateApp_msg: Msg {
    this() {super();}
}

/// Dispatcher sends this messag to the main thread after fulfilling request for termination
immutable class CirclesAreFinished_msg: Msg {
    this() {super();}
}

/// Caldron thead pool has been asked for a thread and id doesn't have any more. It asks dispatcher to create some.
immutable class CaldronThreadPoolAsksDispatcherForThreadBatch_msg: Msg {
    this() { super(); }
}

/// Caldron thread pool has been given a thread to stash, but it reached the limit and wants to stop the thread. So, it
/// asks the dispatcher to do the join on it, since the dispatcher it its direct parent.
immutable class CaldronThreadPoolAsksDispatcherToJoinThread_msg: Msg {
    Thread thread;

    /**
            Constructor.
        Parameters:
            thread = thread to stop.
    */
    this(Thread thread) {
        super();
        (cast()this.thread) = thread;
    }
}

/// Request for the attention dispatcher start an attention circle thread and send back its Tid. Actually, it is be the
/// circle's branch uline, that will send back its Tid.
immutable class UserRequestsCircleTid_msg: Msg {
    /// Constructor
    this() {super();}
}

/// In response to the client request dispatcher creates an attention circle thread and that thread sends user its tid.
/// Actually, it is be the circle's branch uline, that will send back its Tid.
immutable class CircleProvidesUserWithItsTid_msg: Msg {

    /**
        Constructor.
        Parameters:
            tid - circle's Tid
    */
    this(Tid tid) {
        super();
        tid_ = cast(immutable)tid;
    }

    /// Getter
    @property Tid tid() immutable {
        return cast()tid_;
    }

private:
    Tid tid_;       // circle's Tid
}

/// In response to the client request dispatcher creates an attention circle thread and sends it the client Tid.
immutable class DispatcherProvidesCircleWithUserTid_msg: Msg {

    /**
        Constructor.
        Parameters:
            tid - client's Tid
    */
    this(Tid tid) {
        super();
        tid_ = cast(immutable)tid;
    }

    /// Getter
    @property Tid tid() immutable {
        return cast()tid_;
    }

private:
    Tid tid_;       // circle's Tid
}

/// Message to display on the console_thread, usually by an attention circle.
immutable class CircleTellsUser_msg: Msg {

    /**
        Constructor.
        Parameters:
            line - line of text to send
    */
    this(string line) {
        super();
        line_ = line;
    }

    /// Getter
    @property string line() immutable {
        return line_;
    }

private:
    string line_;   // text to display
}

/// Request for a new line from console_thread, usually by an attention circle.
immutable class CircleListensToUser_msg: Msg {
    /// Constructor
    this() {super();}
}

/// Console sends a line of text to an attention circle
immutable class UserTellsCircle_msg: Msg {

    /**
        Constructor.
        Parameters:
            text - line of text to send
    */
    this(string line) {
        super();
        line_ = line;
    }

    /// Getter
    @property string line() immutable {
        return line_;
    }

private:
    string line_;   // text to send
}

/// Interbranching. Request to caldron to start reasoning. May come from another caldron and sometimes from itself.
immutable class IbrStartReasoning_msg: Msg {
    this() {super();}
}

/// This message is sent to the parent on finishing in order to pass output concepts. Only sender's tid is important
/// and it is always in Msg.
immutable class IbrBranchDevise_msg: Msg {
    import cpt.cpt_premises: Breed;

    /// Bread of the deseased branch
    Cid breedCid;

    this(Cid breed) {
        super();
        this.breedCid = breed;
    }
}

/// Interbranching. Used by a caldron to set an activation value for a concept in given caldron.
immutable class IbrSetActivation_msg: Msg {

    this(Cid destConceptCid, float activation) {
        super();
        destConceptCid_ = destConceptCid;
        activation_ = activation;
    }

    /// Getter.
    @property Cid destConceptCid() {
        return destConceptCid_;
    }

    /// Getter.
    @property float activation() {
        return activation_;
    }

    /// Breed of the destination caldron
    private Cid destConceptCid_;

    /// Activation
    private float activation_;
}

/// Interbranching. Used by caldrons to send live concepts to each other.
immutable class IbrSingleConceptPackage_msg: Msg {

    this(Concept load) {
        super();
        load_ = cast(immutable)load;
    }

    /// Getter.
    @property immutable(Concept) load() {
        return load_;
    }

    private Concept load_;
}
