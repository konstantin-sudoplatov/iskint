/// The HolyConcept and its descendants. All holy classes are shared, and they inherit the shared attribute from the root class
/// HolyConcept.
module cpt.abs.abs_concept;
import std.stdio;
import std.format, std.typecons;

import project_params, tools;

import cpt.cpt_types, cpt.cpt_registry;
import chri_shared;
import atn.atn_circle_thread;
import cpt.cpt_actions, cpt.cpt_neurons, cpt.cpt_premises, cpt.cpt_interfaces;
import crank.crank_types: DcpDescriptor;

/**
            Base for all concepts.
    "Spiritual" means stable and storable as opposed to "Live" concepts, that are in a constant using and change and living only
    in memory. All live concepts contain reference to its holy counterpart. There can be many sin instances that corresponds
    to only one holy partner, which is considered immutable by them.

    "shared" attribute is inherrited by successors and cannot be changed.
*/
abstract class SpiritConcept {

    /// Spirit concept classes registry (classinfo by clid
    enum TypeInfo_Class[] spiritRegistry = createSpiritClassesRegistry;

    /// Concept identifier.
    immutable Cid cid = 0;

    /// Version.
    Cvr ver = 0;

    /// Spirit concept class identifier
    immutable Clid clid;

    /// Attributes of the concept.
    immutable SpCptFlags flags =  cast(SpCptFlags)0;

    /**
                Constructor
            Used for concepts with predefined cids.
        Parameters:
            cid = Concept identifier.
            clid = concept class identifier
    */
    this(Cid cid, Clid clid) {
        this.cid = cid;
        this.clid = clid;
    }

    /**
                Clone an object and than make it a deep copy.
        Note, the runtime type of the object is used, not the compile (declared) type.
            Written by Burton Radons <burton-radons smocky.com>
            https://digitalmars.com/d/archives/digitalmars/D/learn/1625.html
            Tested against memory leaks in the garbage collecter both via copied object omission and omission of reference to other
        object in the its body.
        Returns: deep clone of itself
    */
    SpiritConcept _deep_copy_() const {

        void* copy = cast(void*)_d_newclass(this.classinfo);
        size_t size = this.classinfo.initializer.length;
        copy[8 .. size] = (cast(void *)this)[8 .. size];
        return cast(SpiritConcept)copy;
    }

    /**
        Create "live" wrapper for this object.
    */
    abstract Concept live_factory() const;

    /// Serialize concept
    Serial serialize() const {
        return Serial(cid, ver, clid);
    }

    /**
            Initialize concept from its serialized form.
        Parameters:
            cid = cid
            ver = concept version
            clid = classinfo identifier
            stable = stable part of data
            transient = unstable part of data
        Returns: newly constructed object of this class
    */
    static SpiritConcept deserialize(Cid cid, Cvr ver, Clid clid, const byte[] stable, const byte[] transient) {
        auto res = cast(SpiritConcept)_d_newclass(spiritRegistry[clid]);    // create object
        cast()res.cid = cid;
        res.ver = ver;
        cast()res.clid = clid;
        res._deserialize(stable, transient);

        return res;
    }

    /**
            "==" operation overload. Test for equality excluding unsignigicant information like usage statistics. Onle check data
        that influence behavior of the concept and logic it implements. For example the cid and ver fields are not checked.
        Must be realised in every concrete concept since it is used in versioning.
    */
    override bool opEquals(Object sc) const {
        assert(this.clid == scast!SpiritConcept(sc).clid);
        assert(typeid(this) == typeid(sc));

        return true;
    }

    /// To human readable string.
    override string toString() const {
        import std.format: format;

        if(auto p = cid in _nm_)
            return format!"%s(%s): %,3?s(%s)"(*p, typeid(this), '_', cid, '_', ver);
        else
            return format!"noname(%s): %,3?s(%s)"(typeid(this), '_', cid, '_', ver);
    }

    //---***---***---***---***---***--- types ---***---***---***---***---***--

    /// Serialized form of this concept. Used as a return and type in the serialize() method.
    struct Serial {
        Cid cid;
        Cvr ver;
        Clid clid;
        byte[] stable;
        byte[] transient;
    }

    //~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$
    //
    //                                 Protected
    //
    //~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$

    //---$$$---$$$---$$$---$$$---$$$--- data ---$$$---$$$---$$$---$$$---$$$--

    //---$$$---$$$---$$$---$$$---$$$--- functions ---$$$---$$$---$$$---$$$---$$$---

    /**
            Initialize concept from its serialized form.
        Parameters:
            stable = stable part of data
            transient = unstable part of data
        Returns: unconsumed slices of the stable and transient byte arrays.
    */
    protected Tuple!(const byte[], "stable", const byte[], "transient") _deserialize(const byte[] stable,
            const byte[] transient) {
        return tuple!(const byte[], "stable", const byte[], "transient")(stable, transient);
    }
}

/**
            Live wrapper for the HolyConcept.
        Every live concept has a reference to its holy counterpart.
    While the holy concepts contain stable data, and in fact all namespaces (caldrons) can count on them to be immutable,
    dispite the fact that the holy classes declared as just shared, their live mates operate with changeable data, like
    activation or prerequisites. While the holy concepts are shared by all caldrons, the live ones are thread local.

        We don't create live concepts directly through constructors, instead we use the live_factory() method of their
    holy partners.
*/
abstract class Concept {
    immutable SpiritConcept spirit;

    /// Constructor
    this(immutable SpiritConcept spirit) {
        this.spirit = spirit;
    }

    /**
            It is a partly deep copy. All fields of the object cloned deeply except the holy part. The holy is immutable
        for a caldron, no need to duplicate it.
    */
    Concept clone() const {

        // binary copy
        void* copy = cast(void*)_d_newclass(this.classinfo);
        size_t size = this.classinfo.initializer.length;
        copy [8 .. size] = (cast(void *)this)[8 .. size];
        Concept cpt = cast(Concept)copy;

        return cpt;
    }

    /// Overrided default Object.toString()
    override string toString() const {
        import std.format: format;
        import std.array: replace;

        string s = format!"%s(%s):"(_nm_[spirit.cid], typeid(this));
        s ~= format!"\nsp = %s"(spirit.toString).replace("\n", "\n    ");
        return s;
    }

    //---***---***---***---***---***--- functions ---***---***---***---***---***--

    /// Getter
    @property cid() const {
        return spirit.cid;
    }
}

/**
            Base for all holy dynamic concepts.
*/
abstract class SpiritDynamicConcept: SpiritConcept {

    /**
                Constructor
        Used for concepts with predefined cids.
        Parameters:
            cid = Concept identifier. Can be a preassigned value or 0. If it is 0, then actual value is generated when you
                  add the concept to the holy map.
            clid = Concept class identifier.
    */
    this(Cid cid, Clid clid) {
        super(cid, clid);
        cast()flags |= SpCptFlags.PERM;       // all dynamic concepts are permanent until further notice
    }

    //---***---***---***---***---***--- functions ---***---***---***---***---***--
}

/// Ditto
abstract class DynamicConcept: Concept {
    this(immutable SpiritDynamicConcept holyDynamicConcept) { super(holyDynamicConcept); }
}
