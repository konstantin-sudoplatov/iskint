/// Shared memory, global_data parameters.
module global_data;
import std.concurrency;
import std.traits;
import std.format;
import std.conv;

import common_tools;

import stat_registry, stat_main;
import crank_registry;
import attn_dispatcher_thread, attn_circle_thread;
import cpt_abstract, cpt_stat, cpt_neurons, cpt_premises, cpt_actions;

/// Concept identifier
alias Cid = uint;

/// Static cid range is from 1 to MAX_STATIC_CID;
enum MIN_STATIC_CID = Cid(1);
enum MAX_STATIC_CID = Cid(1_000_000);
enum MIN_DYNAMIC_CID = Cid(2_000_000);
enum MAX_DINAMIC_CID = Cid.max;
static assert(MIN_DYNAMIC_CID > MAX_STATIC_CID);
enum MIN_TEMP_CID = MAX_STATIC_CID + 1;
enum MAX_TEMP_CID = MIN_DYNAMIC_CID - 1;
static assert(MAX_TEMP_CID >= MIN_TEMP_CID);

/// Call types of the static concept (static concept is a function).
enum StatCallType: string {
    p0Cal = "void function(Caldron)",                              // void function(Caldron nameSpace)
    p0Calp1Cid = "void function(Caldron, Cid)",                         // void function(Caldron nameSpace, Cid operandCid)
    p0Calp1Cidp2Cid = "void function(Caldron, Cid, Cid)",                    // void function(Caldron nameSpace, Cid firstoperandCid, Cid secondOperandCid)
    p0Calp1Cidp2Int = "void function(Caldron, Cid, int)",                    // void function(Caldron nameSpace, Cid conceptCid, int intValue)
    p0Calp1Cidp2Float = "void function(Caldron, Cid, float)",                  // void function(Caldron nameSpace, Cid conceptCid, float floatValue)
    p0Calp1Cidp2Cidp3Float = "void function(Caldron, Cid, Cid, float)",             // void function(Caldron nameSpace, Cid branchBreedCid, Cid conceptCid, float floatValue)
}

/// Structure of the crank enums.
struct CptDescriptor {
    string className;      // named concept's class
    Cid cid;                // named concept's cid
}

//---***---***---***---***---***--- types ---***---***---***---***---***---***

/**
        Convert name of type represented as a string to real type. Don't forget, the type you a trying to instantiate must
    exist, i.e. be imported or be a basic type.
    Parameters:
        typeName = name of type
*/
template type(string typeName) {
    mixin("alias type = " ~ typeName ~ ";");
}

//---***---***---***---***---***--- data ---***---***---***---***---***--

//      Key threads of the project. The console thead will be spawned, but we don't need to remember its Tid. The circle
// knows it, it's enough.
const shared Tid _mainTid_;         /// Tid of the main thread
const shared Tid _attnDispTid_;     /// Attention dispatcher thread Tid

// Key shared data structures
shared string[Cid] _nm_;        /// name/seed map
shared SpiritMap _sm_;        /// The map of holy(stable and storrable and shared) concepts.
debug {
    // set to true after the maps are filled in with names,cids and references to the concept objects
    immutable bool _maps_filled_;

    // set to true after the cranking is finished and the maps rehashed
    immutable bool _cranked_;
}

/**
    Spawn the key threads (console_thread, attention dispatcher), capture their Tids.
*/
shared static this() {
    // Initialize random generator
    rnd_ = Random(unpredictableSeed);

    // Create and initialize the key shared structures
    _sm_ = new shared SpiritMap;
    fillInConceptMaps_(_sm_, _nm_);     // static concepts from the stat modules, dynamic concept names from the crank modules
    debug
        _maps_filled_ = true;

    // Crank the system. System must be cranked befor spawning any circle threads since they use the chat_seed concept to start.
    runCranks;     // create and setup manually programed dynamic concepts
    import std.stdio: writefln;
    writefln("Some free dynamic cids: %s", _sm_.generate_some_cids(5));

    // Remove from the name map entries not related to the concepts.
    cleanupNotUsedNames;
    _sm_.rehash;
    _nm_.rehash;
    debug
        _cranked_ = true;
}

//---***---***---***---***---***--- functions ---***---***---***---***---***--

/// Enum template for declaring named dynamic concepts. Used in the crank modules.
enum cd(T : SpiritDynamicConcept, Cid cid)  = CptDescriptor(T.stringof, cid);

/**
        Get cid by static concept (it' a function, remember!) name.
    Parameters:
        cptName = name of the static concept function
    Returns: its cid (from the annotation) as int enum.
*/
template statCid(alias cptName)
    if      // annotation consists of two elements and their types are int and StatCallType?
            (__traits(getAttributes, cptName).length == 2 &&
            is(typeof(__traits(getAttributes, cptName)[0]) == int) &&
            is(typeof(__traits(getAttributes, cptName)[1]) == StatCallType))
{   // extract the first element of annotation, which is cid
    enum Cid statCid = __traits(getAttributes, cptName)[0];
}

///
unittest {
    @(1, StatCallType.p0Calp1Cid) static void fun(Caldron spaceName, Cid cid) {}

    const Cid cid = __traits(getAttributes, fun)[0];      // its cid
    assert(statCid!fun == cid);    // check cid
}

/**
            Check up availability and type of a concept by its cid.
    Parameters:
        T = type to check against
        cid = cid of a concept, that is checked
*/
void checkCid(T: SpiritConcept)(Cid cid) {
    debug if(_maps_filled_) {
        assert(cid in _sm_, format!"Cid: %s(%s) do not exist in the holy map."(cid, _nm_[cid]));
        assert(cast(T)_sm_[cid],
                format!"Cid: %s, must be of type %s and it is of type %s."(cid, T.stringof, typeid(_sm_[cid])));
    }
}

///         Adapter for live concepts.
void checkCid(T)(Caldron caldron, Cid cid)
    if(is(T: Concept) || is(T == interface))
{
    debug if(_cranked_)
        assert((cast(T)caldron[cid]),
                format!"Cid: %s, must be of type %s and it is of type %s."
                        (cid, T.stringof, typeid(caldron[cid])));
}

/**
        Retrieve a concept from the holy map by its enum constant and cast it from the HolyConcept to its original type,
    which is gotten from the enum constant (the CptDescriptor type). The scast template serves as a guard against silent
    casting an object to null, if the cast happens to be illegal.
    Parameters:
        cd = constant descriptor of the enum, describing the concept
    Returns: the wanted concept casted to its original type.
*/
auto cpt(alias cd)() {
    return scast!(type!("shared " ~ cd.className))(_sm_[cd.cid]);
}

///
unittest {
    import std.stdio: writeln;
    import crank_main: CommonConcepts, Chat;
    mixin(dequalify_enums!(CommonConcepts, Chat));

    assert(cpt!(chat_seed) is cast(shared SpSeed)_sm_[chat_seed.cid]);
}

//---%%%---%%%---%%%---%%%---%%% types ---%%%---%%%---%%%---%%%---%%%---%%%--

/**
            Holy concepts map. It is a wrapper for actual associative array.
        Map of all static and dynamic shared storrable (holy) concepts. This map will be used concurrently by all caldrons,
    so it must be synchronized. At the moment, it is usual syncronization on the class object. In the future it can possibly
    be changed to atomic, because the concurrent asccess might be intensive. To that end acsses via the class methods would
    help, because this way we could get away with changes to only interface methods for the real map.
*/
import std.random;
shared synchronized final pure nothrow class SpiritMap {

    //---***---***---***---***---***--- types ---***---***---***---***---***---***

    //---***---***---***---***---***--- data ---***---***---***---***---***--

    /**
        Constructor
    */
    this(){}

    //---***---***---***---***---***--- functions ---***---***---***---***---***--

    /**
                Length of the map.
        Returns: the length of the map as in an AA.
    */
    auto length() {
        return holyMap_.length;
    }

    /**
                Assign/construct-assign new holy map entry. If cid had not been assigned to the cpt yet, it is generated.
        Parameters:
            cpt = shared concept to assign
    */
    shared(SpiritConcept) add(shared SpiritConcept cpt)
    in {
        assert(cpt !in this, "Cid " ~ to!string(cpt.cid) ~ " - this cid already exists in the holy map.");
        if      // dynamic?
                (cast(shared SpiritDynamicConcept)cpt)
            if      // with preset cid?
                    (cpt.cid != 0)
                assert(cpt.cid >= MIN_DYNAMIC_CID && cpt.cid <= MAX_DINAMIC_CID,
                        "Cid: " ~ to!string(cpt.cid) ~ ", cids for dynamic concepts must lie in the range of " ~
                        to!string(MIN_DYNAMIC_CID) ~ ".." ~ to!string(MAX_DINAMIC_CID));
            else {} //no: dynamic concepts without cid are allowed, cid will be generated
        else if // static?
                (cast(shared SpStaticConcept)cpt)
        {
            assert(cpt.cid != 0, "Static concepts can't have zero cid. Their cids are initialized at construction.");
            assert(cpt.cid >= MIN_STATIC_CID && cpt.cid <= MAX_STATIC_CID,
                    "Cid: " ~ to!string(cpt.cid) ~ ", cids for static concepts must lie in the range of " ~
                    to!string(MIN_STATIC_CID) ~ ".." ~ to!string(MAX_STATIC_CID));
        }
        else    // neither dynamic and nor static?
            assert(false, to!string(cpt) ~ " - not expected type here.");
    }
    do {
        // generate cid and use it
        if      // is not cid set yet?
                (cpt.cid == 0)
            //no: generate and set it
            cast()cpt.cid = generateDynamicCid_;

        // put the pair in the map
        holyMap_[cpt.cid] = cpt;

        return cpt;
    }

    /**
            Remove key from map. Analogously to the AAs.
        Parameters:
            cid = key
        Returns: true if existed, else false
    */
    bool remove(Cid cid) {
        return holyMap_.remove(cid);
    }

    /**
                Get concept by cid, an overload for the index operation.
        Parameters:
            cid = key
        Returns: shared concept
    */
    shared(SpiritConcept) opIndex(Cid cid) {
        return holyMap_[cid];
    }

    /**
                Add concept to the map, an overload for the index assignment operation.
            Example of usage:
        ---
            _hm_[] = cpt;
        ---
        Parameters:
            cpt = concept to add
        Returns: assigned concept
    */
    shared(SpiritConcept) opIndexAssign(shared SpiritConcept cpt) {
        return add(cpt);
    }

    /**
                Overload for "in".
        Parameters:
            cid = cid of the concept.
        Returns: pointer to the concept or null
    */
    shared(SpiritConcept*) opBinaryRight(string op)(Cid cid) {
        return cid in holyMap_;
    }

    /// Ditto.
    shared(SpiritConcept*) opBinaryRight(string op)(shared SpiritConcept cpt) {
        return cpt.cid in holyMap_;
    }

    /**
                Pass through for byKey.
        Returns: range of cids
    */
    auto byKey() {
        return (cast()holyMap_).byKey;      // need to cast off the shared attribute to avoid a compiler error
    }

    /**
                Pass through for byValue.
        Returns: range of concepts
    */
    auto byValue() {
        return (cast()holyMap_).byValue;      // need to cast off the shared attribute to avoid a compiler error
    }

    /**
                Rebuild associative array to make it more efficient.
    */
    void rehash() {
        holyMap_.rehash;
    }

    /**
                Generate a namber of dynamic cids.
        Parameters:
            howMany = how many cids you need
        Returns: array of fresh cidsj
    */
    Cid[] generate_some_cids(int howMany) {

        Cid[] sids;
        foreach(i; 0..howMany)
            sids ~= generateDynamicCid_;

        return sids;
    }

    //###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%
    //
    //                               Private
    //
    //###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%

    //---%%%---%%%---%%%---%%%---%%% data ---%%%---%%%---%%%---%%%---%%%---%%%
    private SpiritConcept[Cid] holyMap_;       /// map concept/cid

    //---%%%---%%%---%%%---%%%---%%% functions ---%%%---%%%---%%%---%%%---%%%---%%%--

    /**
                Generate new unique throughout the system cid.
        Returns: cid
    */
    private Cid generateDynamicCid_() {
        Cid cid;
        do {
            cid = rnd_.uniform!Cid;
        } while(cid in holyMap_);        // do until not repeated in the map

        return cid;
    }

    //---%%%---%%%---%%%---%%%---%%% types ---%%%---%%%---%%%---%%%---%%%---%%%--
}

//###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%
//
//                               Private
//
//###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%

//---%%%---%%%---%%%---%%%---%%% data ---%%%---%%%---%%%---%%%---%%%---%%%

/// rnd generator. Initialized from constructor.
private static typeof(Random(unpredictableSeed())) rnd_;

//---%%%---%%%---%%%---%%%---%%% functions ---%%%---%%%---%%%---%%%---%%%---%%%--


/**
            Fill in gathered in statDescriptors_ and dynDescriptors_ info into the holy map and name map.
    Parameters:
        hm = holy map to fill
*/
private void fillInConceptMaps_(shared SpiritMap hm, shared string[Cid] nm)
out{
    assert(hm.length == statDescriptors.length + dynDescriptors.length);
    assert(nm.length == statDescriptors.length + dynDescriptors.length);
}
do {
    import std.stdio: writefln;

    // Accept static concepts and their names from the statDescriptors_ enum
    foreach(sd; statDescriptors) {
        assert(sd.cid !in hm, "Cid: " ~ to!string(sd.cid) ~ ". Cids cannot be reused.");
        hm.add(new shared SpStaticConcept(sd.cid, sd.fun_ptr, sd.call_type));
        nm[sd.cid] = sd.name;
    }

    // report static cids usage
    writefln("Unused static cids: %s", unusedStaticCids);
    writefln("Last used static cid: %s", statDescriptors[$-1].cid);

    // Accept dynamic concept names from the dynDescriptors_ enum
    foreach(dd; dynDescriptors) {
        assert(dd.cid !in nm);
        nm[dd.cid] = dd.name;
    }

    // Create dynamic concepts based on the dynDescriptors_ enum
    static foreach(dd; dynDescriptors) {
        _sm_[] = mixin("new shared " ~ dd.class_name ~ "(" ~ to!string(dd.cid) ~ ")");
    }
}

/**
            Remove from the name map all entries that don't have related entry in the holy map.
*/
private void cleanupNotUsedNames() {
    import std.typecons: Tuple;

    // Find all orphan entries in the name map.
    alias Entry = Tuple!(Cid, "cid", string, "name");
    Entry[] orphans;
    Entry orphan;
    foreach(cid; (cast()_nm_).byKey)
        if      //is not cid present in the holy map?
                (cid !in _sm_)
        {
            orphan.cid = cid;
            orphan.name =_nm_[cid];

            orphans ~= orphan;
        }

    // Remove orphans
    foreach(orph; orphans) {
        logit(format!"Removing from _nm_ name: %s, cid %s is not in the _sm_"(orph.name, orph.cid), TermColor.red);
        _nm_.remove(orph.cid);
    }
}

//---%%%---%%%---%%%---%%%---%%% types ---%%%---%%%---%%%---%%%---%%%---%%%--
