/**
        The action concept is an interface, bridge between the world of cids and dynamic concepts,
    that knows nothing about the code and the static world, which is a big set of functions, that actually are the code.
*/
module cpt.cpt_actions;
import std.stdio;
import std.string, std.typecons;

import proj_data, proj_funcs;

import chri_types, chri_data;
import cpt.cpt_types, cpt.abs.abs_concept, cpt.cpt_stat;
import atn.atn_caldron;

/// Spirit Action. Runs a static concept function with signature p0Cal.
@(1) class SpA: SpiritDynamicConcept {

    /**
                Constructor
        Parameters:
            cid = predefined concept identifier
    */
    this(Cid cid) { super(cid); }

    /// Create live wrapper for the holy static concept.
    override A live_factory() const {
        return new A(cast(immutable)this);
    }

    /// Serialize concept
    override Serial serialize() const {
        Serial res = super.serialize;

        res.stable.length = St.length;  // allocate
        *cast(Cid*)&res.stable[St._statActionCid_ofs] = _statAction;

        return res;
    }

    /// Equality test
    override bool opEquals(Object sc) const {

        if(!super.opEquals(sc)) return false;
        return _statAction == scast!(typeof(this))(sc)._statAction;
    }

    override string toString() const {
        string s = super.toString;
        s ~= format!"\n    _statAction = %s(%s)"(cptName(_statAction), _statAction);
        return s;
    }

    //---***---***---***---***---***--- functions ---***---***---***---***---***--

    /**
                Call static concept function.
        Parameters:
            caldron = name space it which static concept function will be working.
    */
    void run(Caldron caldron) {
        assert((cast(SpStaticConcept)_sm_[_statAction]).callType == StatCallType.p0Cal,
                "Static concept: %s( cid:%s) in SpAction must have StatCallType none and it has %s.".
                format(_nm_[_statAction], _statAction, (cast(SpStaticConcept)_sm_[_statAction]).callType));

        auto statCpt = (cast(SpStaticConcept)_sm_[_statAction]);
        (cast(void function(Caldron))statCpt.fp)(caldron);
    }

    /// Full setup
    final void load(Cid statAction) {
        checkCid!SpStaticConcept(statAction);
        _statAction = statAction;
    }

    /// Getter
    final @property Cid statAction() {
        return _statAction;
    }

    /// Setter
    //final @property Cid statAction(Cid statActionCid) {
    //    debug checkCid!SpStaticConcept(statActionCid);
    //    return _statActionCid = statActionCid;
    //}

    //~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$
    //
    //                                 Protected
    //
    //~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$

    //---$$$---$$$---$$$---$$$---$$$--- data ---$$$---$$$---$$$---$$$---$$$--

    // Static action.
    protected Cid _statAction;

    //---$$$---$$$---$$$---$$$---$$$--- functions ---$$$---$$$---$$$---$$$---$$$---

    /**
            Initialize concept from its serialized form.
        Parameters:
            stable = stable part of data
            transient = unstable part of data
        Returns: unconsumed slices of the stable and transient byte arrays.
    */
    protected override Tuple!(const byte[], "stable", const byte[], "transient") _deserialize(const byte[] stable,
            const byte[] transient)
    {
        _statAction = *cast(Cid*)&stable[St._statActionCid_ofs];

        return tuple!(const byte[], "stable", const byte[], "transient")(stable[St.length..$], transient);
    }

    //===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@
    //
    //                                  Private
    //
    //===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@

    /// Stable offsets. Used by serialize()/_deserialize()
    private enum St {
        _statActionCid_ofs = 0,
        length = _statActionCid_ofs + _statAction.sizeof
    }

    /// Tranzient offsets. Used by serialize()/_deserialize()
    private enum Tr {
        length = 0
    }
}

unittest {
    auto a = new SpA(42);
    a.ver = 5;
    a.load(43);

    Serial ser = a.serialize;
    auto b = cast(SpA)a.deserialize(ser.cid, ser.ver, ser.clid, ser.stable, ser.transient);
    assert(b.cid == 42 && b.ver == 5 && typeid(b) == typeid(SpA));

    assert(a == b);
}

/// Live.
class A: DynamicConcept {

    /// Private constructor. Use SpiritConcept.live_factory() instead.
    private this(immutable SpA spAction) { super(spAction); }

    //---***---***---***---***---***--- functions ---***---***---***---***---***--

    /**
                Call static concept function.
        Parameters:
            caldron = name space it which static concept function will be working.
    */
    void run(Caldron caldron) {
        assert((cast(SpA)spirit).statAction != 0, "Cid: %s, static action must be assigned.".format(this.cid));
        (cast(SpA)spirit).run(caldron);
    }
}

/// SpA - spirit action, Cid - p0Calp1Cid
/// Action, that operate on only one concept. Examples: activate/anactivate concept.
@(2) final class SpA_Cid: SpA {

    /// Constructor
    this(Cid cid) { super(cid); }

    /// Create live wrapper for the holy static concept.
    override A_Cid live_factory() const {
        return new A_Cid(cast(immutable)this);
    }

    /// Serialize concept
    override Serial serialize() const {
        Serial res = super.serialize;

        res.stable.length = St.length;  // allocate
        *cast(Cid*)&res.stable[St._statActionCid_ofs] = _statAction;
        *cast(Cid*)&res.stable[St._p1Cid_ofs] = _p1Cid;

        return res;
    }

    /// Equality test
    override bool opEquals(Object sc) const {

        if(!super.opEquals(sc)) return false;
        auto o = scast!(typeof(this))(sc);
        return _p1Cid == o._p1Cid;
    }

    override string toString() const {
        string s = super.toString;
        s ~= format!"\n    _p1Cid = %s(%,?s)"(cptName(_p1Cid), '_', _p1Cid);
        return s;
    }

    //---***---***---***---***---***--- functions ---***---***---***---***---***--

    /**
                Call static concept function.
        Parameters:
            caldron = name space it which static concept function will be working.
    */
    override void run(Caldron caldron) {
        auto statAct = (scast!SpStaticConcept(_sm_[_statAction]));
        assert(statAct.callType == StatCallType.p0Calp1Cid,
                "Static concept: %s( cid:%s) in SpAction must have StatCallType p0Calp1Cid and it has %s.".
                format(typeid(statAct), _statAction, statAct.callType));
        checkCid!DynamicConcept(caldron, _p1Cid);

        (cast(void function(Caldron, Cid))statAct.fp)(caldron, _p1Cid);
    }

    /// Allow loading only static action using load(Cid statAction) of the SpA class.
    alias load = SpA.load;

    /// Full setup
    void load(Cid statAction, DcpDsc operand) {
        checkCid!SpStaticConcept(statAction);
        _statAction = statAction;
        checkCid!SpiritDynamicConcept(operand.cid);
        _p1Cid = operand.cid;
    }

    /// Partial setup, only operand
    void load(DcpDsc operand) {
        checkCid!SpiritDynamicConcept(operand.cid);
        _p1Cid = operand.cid;
    }

    //---%%%---%%%---%%%---%%%---%%% data ---%%%---%%%---%%%---%%%---%%%---%%%

    /// Cid of a concept to operate on
    protected Cid _p1Cid;

    //---%%%---%%%---%%%---%%%---%%% funcs ---%%%---%%%---%%%---%%%---%%%---%%%

    /**
            Initialize concept from its serialized form.
        Parameters:
            stable = stable part of data
            transient = unstable part of data
        Returns: unconsumed slices of the stable and transient byte arrays.
    */
    protected override Tuple!(const byte[], "stable", const byte[], "transient") _deserialize(const byte[] stable,
            const byte[] transient)
    {
        _statAction = *cast(Cid*)&stable[St._statActionCid_ofs];
        _p1Cid = *cast(Cid*)&stable[St._p1Cid_ofs];

        return tuple!(const byte[], "stable", const byte[], "transient")(stable[St.length..$], transient);
    }

    //===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@
    //
    //                                  Private
    //
    //===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@

    /// Stable offsets. Used by serialize()/_deserialize()
    private enum St {
        _statActionCid_ofs = 0,
        _p1Cid_ofs = _statActionCid_ofs + _statAction.sizeof,
        length = _p1Cid_ofs + _p1Cid.sizeof
    }

    /// Tranzient offsets. Used by serialize()/_deserialize()
    private enum Tr {
        length = 0
    }
}

unittest {
    auto a = new SpA_Cid(42);
    a.ver = 5;
    a._statAction = 43;
    a._p1Cid = 44;

    Serial ser = a.serialize;
    auto b = cast(SpA_Cid)a.deserialize(ser.cid, ser.ver, ser.clid, ser.stable, ser.transient);
    assert(b.cid == 42 && b.ver == 5 && typeid(b) == typeid(SpA_Cid) &&
            b._statAction == 43 && b._p1Cid == 44);

    assert(a == b);
}

/// Live.
final class A_Cid: A {

    /// Private constructor. Use live_factory() instead.
    private this(immutable SpA_Cid spUnaryAction) { super(spUnaryAction); }

}

/**
        SpA - spirit action, CidCid - p0Calp1Cidp2Cid
    Actions, that operate on two concepts. Examples: sending a message - the first operand breed of the correspondent,
    the second operand concept object to send.
*/
@(3) final class SpA_2Cid: SpA {

    /// Constructor
    this(Cid cid) { super(cid); }

    /// Create live wrapper for the holy static concept.
    override A_2Cid live_factory() const {
        return new A_2Cid(cast(immutable)this);
    }

    /// Serialize concept
    override Serial serialize() const {
        Serial res = super.serialize;

        res.stable.length = St.length;  // allocate
        *cast(Cid*)&res.stable[St._statActionCid_ofs] = _statAction;
        *cast(Cid*)&res.stable[St._p1Cid_ofs] = _p1Cid;
        *cast(Cid*)&res.stable[St._p2Cid_ofs] = _p2Cid;

        return res;
    }

    /// Equality test
    override bool opEquals(Object sc) const {

        if(!super.opEquals(sc)) return false;
        auto o = scast!(typeof(this))(sc);
        return _p1Cid == o._p1Cid && _p2Cid == o._p2Cid;
    }

    override string toString() const {
        string s = super.toString;
        s ~= format!"\n    _p1Cid = %s(%,?s)"(cptName(_p1Cid), '_', _p1Cid);
        s ~= format!"\n    _p2Cid = %s(%,?s)"(cptName(_p2Cid), '_', _p2Cid);
        return s;
    }

    //---***---***---***---***---***--- functions ---***---***---***---***---***--

    /**
                Call static concept function.
        Parameters:
            caldron = name space it which static concept function will be working.
    */
    override void run(Caldron caldron) {
        auto statAct = (scast!SpStaticConcept(_sm_[_statAction]));
        assert(statAct.callType == StatCallType.p0Calp1Cidp2Cid,
                "Static concept: %s( cid:%s) in SpAction must have StatCallType p0Calp1Cidp2Cid and it has %s.".
                format(typeid(statAct), _statAction, statAct.callType));
        checkCid!DynamicConcept(caldron, _p1Cid);
        checkCid!DynamicConcept(caldron, _p2Cid);

        (cast(void function(Caldron, Cid, Cid))statAct.fp)(caldron, _p1Cid, _p2Cid);
    }

    /// Allow loading only static action using load(Cid statAction) of the SpA class.
    alias load = SpA.load;

    /// Full setup
    void load(Cid statAction, DcpDsc firstOperand, DcpDsc secondOperand) {
        checkCid!SpStaticConcept(statAction);

        _statAction = statAction;
        checkCid!SpiritDynamicConcept(firstOperand.cid);
        _p1Cid = firstOperand.cid;
        checkCid!SpiritDynamicConcept(secondOperand.cid);
        _p2Cid = secondOperand.cid;
    }

    /// Partial setup, without the static action
    void load(DcpDsc firstOperand, DcpDsc secondOperand) {
        checkCid!SpiritDynamicConcept(firstOperand.cid);
        _p1Cid = firstOperand.cid;
        checkCid!SpiritDynamicConcept(secondOperand.cid);
        _p2Cid = secondOperand.cid;
    }

    //---%%%---%%%---%%%---%%%---%%% data ---%%%---%%%---%%%---%%%---%%%---%%%

    /// Cid of the first concept
    protected Cid _p1Cid;

    /// Cid of the second concept
    protected Cid _p2Cid;

    //---%%%---%%%---%%%---%%%---%%% funcs ---%%%---%%%---%%%---%%%---%%%---%%%

    /**
            Initialize concept from its serialized form.
        Parameters:
            stable = stable part of data
            transient = unstable part of data
        Returns: unconsumed slices of the stable and transient byte arrays.
    */
    protected override Tuple!(const byte[], "stable", const byte[], "transient") _deserialize(const byte[] stable,
            const byte[] transient)
    {
        _statAction = *cast(Cid*)&stable[St._statActionCid_ofs];
        _p1Cid = *cast(Cid*)&stable[St._p1Cid_ofs];
        _p2Cid = *cast(Cid*)&stable[St._p2Cid_ofs];

        return tuple!(const byte[], "stable", const byte[], "transient")(stable[St.length..$], transient);
    }

    //===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@
    //
    //                                  Private
    //
    //===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@

    /// Stable offsets. Used by serialize()/_deserialize()
    private enum St {
        _statActionCid_ofs = 0,
        _p1Cid_ofs = _statActionCid_ofs + _statAction.sizeof,
        _p2Cid_ofs = _p1Cid_ofs + _p1Cid.sizeof,
        length = _p2Cid_ofs + _p2Cid.sizeof
    }

    /// Tranzient offsets. Used by serialize()/_deserialize()
    private enum Tr {
        length = 0
    }
}

unittest {
    auto a = new SpA_2Cid(42);
    a.ver = 5;
    a._statAction = 43;
    a._p1Cid = 44;
    a._p2Cid = 45;

    Serial ser = a.serialize;
    auto b = cast(SpA_2Cid)a.deserialize(ser.cid, ser.ver, ser.clid, ser.stable, ser.transient);
    assert(b.cid == 42 && b.ver == 5 && typeid(b) == typeid(SpA_2Cid) &&
            b._statAction == 43 && b._p1Cid == 44 && b._p2Cid == 45);

    assert(a == b);
}

/// Live.
final class A_2Cid: A {

    /// Private constructor. Use live_factory() instead.
    private this(immutable SpA_2Cid spBinaryAction) { super(spBinaryAction); }
}

/**
        SpA - spirit action, 3Cid - p0Calp1Cidp2Cidp3Cid
    Actions, that operate on two concepts. Examples: sending a message - the first operand breed of the correspondent,
    the second operand concept object to send.
*/
@(4) final class SpA_3Cid: SpA {

    /// Constructor
    this(Cid cid) { super(cid); }

    /// Create live wrapper for the holy static concept.
    override A_3Cid live_factory() const {
        return new A_3Cid(cast(immutable)this);
    }

    /// Serialize concept
    override Serial serialize() const {
        Serial res = super.serialize;

        res.stable.length = St.length;  // allocate
        *cast(Cid*)&res.stable[St._statActionCid_ofs] = _statAction;
        *cast(Cid*)&res.stable[St._p1Cid_ofs] = _p1Cid;
        *cast(Cid*)&res.stable[St._p2Cid_ofs] = _p2Cid;
        *cast(Cid*)&res.stable[St._p3Cid_ofs] = _p3Cid;

        return res;
    }

    /// Equality test
    override bool opEquals(Object sc) const {

        if(!super.opEquals(sc)) return false;
        auto o = scast!(typeof(this))(sc);
        return _p1Cid == o._p1Cid && _p2Cid == o._p2Cid && _p3Cid == o._p3Cid;
    }

    override string toString() const {
        string s = super.toString;
        s ~= format!"\n    _p1Cid = %s(%,?s)"(cptName(_p1Cid), '_', _p1Cid);
        s ~= format!"\n    _p2Cid = %s(%,?s)"(cptName(_p2Cid), '_', _p2Cid);
        s ~= format!"\n    _p3Cid = %s(%,?s)"(cptName(_p3Cid), '_', _p3Cid);
        return s;
    }

    //---***---***---***---***---***--- functions ---***---***---***---***---***--

    /**
                Call static concept function.
        Parameters:
            caldron = name space it which static concept function will be working.
    */
    override void run(Caldron caldron) {
        auto statAct = (scast!SpStaticConcept(_sm_[_statAction]));
        assert(statAct.callType == StatCallType.p0Calp1Cidp2Cidp3Cid,
                "Static concept: %s( cid:%s) in SpAction must have StatCallType p0Calp1Cidp2Cid3Cid and it has %s.".
                format(typeid(statAct), _statAction, statAct.callType));
        checkCid!DynamicConcept(caldron, _p1Cid);
        checkCid!DynamicConcept(caldron, _p2Cid);
        checkCid!DynamicConcept(caldron, _p3Cid);

        (cast(void function(Caldron, Cid, Cid, Cid))statAct.fp)(caldron, _p1Cid, _p2Cid, _p3Cid);
    }

    /// Allow loading only static action using load(Cid statAction) of the SpA class.
    alias load = SpA.load;

    /// Full setup
    void load(Cid statAction, DcpDsc firstOperand, DcpDsc secondOperand, DcpDsc thirdOperand) {
        checkCid!SpStaticConcept(statAction);

        _statAction = statAction;
        checkCid!SpiritDynamicConcept(firstOperand.cid);
        _p1Cid = firstOperand.cid;
        checkCid!SpiritDynamicConcept(secondOperand.cid);
        _p2Cid = secondOperand.cid;
        checkCid!SpiritDynamicConcept(thirdOperand.cid);
        _p3Cid = thirdOperand.cid;
    }

    /// Partial setup, without the static action
    void load(DcpDsc firstOperand, DcpDsc secondOperand, DcpDsc thirdOperand) {
        checkCid!SpiritDynamicConcept(firstOperand.cid);
        _p1Cid = firstOperand.cid;
        checkCid!SpiritDynamicConcept(secondOperand.cid);
        _p2Cid = secondOperand.cid;
        checkCid!SpiritDynamicConcept(thirdOperand.cid);
        _p3Cid = thirdOperand.cid;
    }

    //---%%%---%%%---%%%---%%%---%%% data ---%%%---%%%---%%%---%%%---%%%---%%%

    /// Cid of the first concept
    protected Cid _p1Cid;

    /// Cid of the second concept
    protected Cid _p2Cid;

    /// Cid of the third concept
    protected Cid _p3Cid;

    //---%%%---%%%---%%%---%%%---%%% funcs ---%%%---%%%---%%%---%%%---%%%---%%%

    /**
            Initialize concept from its serialized form.
        Parameters:
            stable = stable part of data
            transient = unstable part of data
        Returns: unconsumed slices of the stable and transient byte arrays.
    */
    protected override Tuple!(const byte[], "stable", const byte[], "transient") _deserialize(const byte[] stable,
            const byte[] transient)
    {
        _statAction = *cast(Cid*)&stable[St._statActionCid_ofs];
        _p1Cid = *cast(Cid*)&stable[St._p1Cid_ofs];
        _p2Cid = *cast(Cid*)&stable[St._p2Cid_ofs];
        _p3Cid = *cast(Cid*)&stable[St._p3Cid_ofs];

        return tuple!(const byte[], "stable", const byte[], "transient")(stable[St.length..$], transient);
    }

    //===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@
    //
    //                                  Private
    //
    //===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@

    /// Stable offsets. Used by serialize()/_deserialize()
    private enum St {
        _statActionCid_ofs = 0,
        _p1Cid_ofs = _statActionCid_ofs + _statAction.sizeof,
        _p2Cid_ofs = _p1Cid_ofs + _p1Cid.sizeof,
        _p3Cid_ofs = _p2Cid_ofs + _p2Cid.sizeof,
        length = _p3Cid_ofs + _p3Cid.sizeof
    }

    /// Tranzient offsets. Used by serialize()/_deserialize()
    private enum Tr {
        length = 0
    }
}

unittest {
    auto a = new SpA_3Cid(42);
    a.ver = 5;
    a._statAction = 43;
    a._p1Cid = 44;
    a._p2Cid = 45;
    a._p3Cid = 46;

    Serial ser = a.serialize;
    auto b = cast(SpA_3Cid)a.deserialize(ser.cid, ser.ver, ser.clid, ser.stable, ser.transient);
    assert(b.cid == 42 && b.ver == 5 && typeid(b) == typeid(SpA_3Cid) &&
            b._statAction == 43 && b._p1Cid == 44 && b._p2Cid == 45 && b._p3Cid == 46);

    assert(a == b);
}

/// Live.
final class A_3Cid: A {

    /// Private constructor. Use live_factory() instead.
    private this(immutable SpA_3Cid spBinaryAction) { super(spBinaryAction); }
}

/// SpA - spirit action, CidFloat - p0Calp1Cidp2Float
/// Action, that works on a concept and a float value
@(5) final class SpA_CidFloat: SpA {

    /// Constructor
    this(Cid cid) { super(cid); }

    /// Create live wrapper for the holy static concept.
    override A_CidFloat live_factory() const {
        return new A_CidFloat(cast(immutable)this);
    }

    /// Serialize concept
    override Serial serialize() const {
        Serial res = super.serialize;

        res.stable.length = St.length;  // allocate
        *cast(Cid*)&res.stable[St._statActionCid_ofs] = _statAction;
        *cast(Cid*)&res.stable[St._p1Cid_ofs] = _p1Cid;
        *cast(float*)&res.stable[St._p2Float_ofs] = _p2Float;

        return res;
    }

    /// Equality test
    override bool opEquals(Object sc) const {

        if(!super.opEquals(sc)) return false;
        auto o = scast!(typeof(this))(sc);
        return _p1Cid == o._p1Cid && _p2Float == o._p2Float;
    }

    override string toString() const {
        string s = super.toString;
        s ~= format!"\n    _p1Cid = %s(%,?s)"(cptName(_p1Cid), '_', _p1Cid);
        s ~= format!"\n    _p2Float = %s"(_p2Float);
        return s;
    }

    //---***---***---***---***---***--- functions ---***---***---***---***---***--

    /// Run the static action.
    override void run(Caldron caldron) {
        auto statAct = (scast!SpStaticConcept(_sm_[_statAction]));
        assert(statAct.callType == StatCallType.p0Calp1Cidp2Float,
                "Static concept: %s( cid:%s) in SpAction must have StatCallType p0Calp1Cidp2Float and it has %s.".
                format(typeid(statAct), _statAction, statAct.callType));
        checkCid!DynamicConcept(caldron, _p1Cid);

        (cast(void function(Caldron, Cid, float))statAct.fp)(caldron, _p1Cid, _p2Float);
    }

    /// Allow loading only static action using load(Cid statAction) of the SpA class.
    alias load = SpA.load;

    /**
            Set float value for a concept in the current namespace.
        Parameters:
            statActionCid = static action to perform
            p1 = concept, that takes the float value
            p2 = float value
    */
    void load(Cid statActionCid, DcpDsc p1, float p2) {
        checkCid!SpStaticConcept(statActionCid);
        checkCid!SpiritDynamicConcept(p1.cid);

        _statAction = statActionCid;
        _p1Cid = p1.cid;
        _p2Float = p2;
    }

    /// Partial setup, without the static action
    void load(DcpDsc p1, float p2) {
        checkCid!SpiritDynamicConcept(p1.cid);

        _p1Cid = p1.cid;
        _p2Float = p2;
    }

    //---%%%---%%%---%%%---%%%---%%% data ---%%%---%%%---%%%---%%%---%%%---%%%

    // Parameter 1 - a concept cid.
    protected Cid _p1Cid;

    // Parameter 2 - a float value
    protected float _p2Float;

    //---%%%---%%%---%%%---%%%---%%% funcs ---%%%---%%%---%%%---%%%---%%%---%%%

    /**
            Initialize concept from its serialized form.
        Parameters:
            stable = stable part of data
            transient = unstable part of data
        Returns: unconsumed slices of the stable and transient byte arrays.
    */
    protected override Tuple!(const byte[], "stable", const byte[], "transient") _deserialize(const byte[] stable,
            const byte[] transient)
    {
        _statAction = *cast(Cid*)&stable[St._statActionCid_ofs];
        _p1Cid = *cast(Cid*)&stable[St._p1Cid_ofs];
        _p2Float = *cast(float*)&stable[St._p2Float_ofs];

        return tuple!(const byte[], "stable", const byte[], "transient")(stable[St.length..$], transient);
    }

    //===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@
    //
    //                                  Private
    //
    //===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@

    /// Stable offsets. Used by serialize()/_deserialize()
    private enum St {
        _statActionCid_ofs = 0,
        _p1Cid_ofs = _statActionCid_ofs + _statAction.sizeof,
        _p2Float_ofs = _p1Cid_ofs + _p1Cid.sizeof,
        length = _p2Float_ofs + _p2Float.sizeof
    }

    /// Tranzient offsets. Used by serialize()/_deserialize()
    private enum Tr {
        length = 0
    }
}

unittest {
    auto a = new SpA_CidFloat(42);
    a.ver = 5;
    a._statAction = 43;
    a._p1Cid = 44;
    a._p2Float = 4.5;

    Serial ser = a.serialize;
    auto b = cast(SpA_CidFloat)a.deserialize(ser.cid, ser.ver, ser.clid, ser.stable, ser.transient);
    assert(b.cid == 42 && b.ver == 5 && typeid(b) == typeid(SpA_CidFloat) &&
            b._statAction == 43 && b._p1Cid == 44 && b._p2Float == 4.5);

    assert(a == b);
}

/// Live.
final class A_CidFloat: A {

    /// Private constructor. Use live_factory() instead.
    private this(immutable SpA_CidFloat spUnaryFloatAction) { super(spUnaryFloatAction); }
}

/// SpA - spirit action, CidCidFloat stands for p0Calp1Cidp2Cidp3Float
/// Action, that involves two concepts and a float value
@(6) final class SpA_2CidFloat: SpA {

    /// Constructor
    this(Cid cid) { super(cid); }

    /// Create live wrapper for the holy static concept.
    override A_2CidFloat live_factory() const {
        return new A_2CidFloat(cast(immutable)this);
    }

    /// Serialize concept
    override Serial serialize() const {
        Serial res = super.serialize;

        res.stable.length = St.length;  // allocate
        *cast(Cid*)&res.stable[St._statActionCid_ofs] = _statAction;
        *cast(Cid*)&res.stable[St._p1Cid_ofs] = _p1Cid;
        *cast(Cid*)&res.stable[St._p2Cid_ofs] = _p2Cid;
        *cast(float*)&res.stable[St._p3Float_ofs] = _p3Float;

        return res;
    }

    /// Equality test
    override bool opEquals(Object sc) const {

        if(!super.opEquals(sc)) return false;
        auto o = scast!(typeof(this))(sc);
        return _p1Cid == o._p1Cid && _p2Cid == o._p2Cid && _p3Float == o._p3Float;
    }

    override string toString() const {
        string s = super.toString;
        s ~= format!"\n    _p1Cid = %s(%,?s)"(cptName(_p1Cid), '_', _p1Cid);
        s ~= format!"\n    _p2Cid = %s(%,?s)"(cptName(_p2Cid), '_', _p2Cid);
        s ~= format!"\n    _p3Float = %s"(_p3Float);
        return s;
    }

    //---***---***---***---***---***--- functions ---***---***---***---***---***--

    /// Run the static action.
    override void run(Caldron caldron) {
        auto statAct = (scast!SpStaticConcept(_sm_[_statAction]));
        assert(statAct.callType == StatCallType.p0Calp1Cidp2Cidp3Float,
                    "Static concept: %s( cid:%s) in SpAction must have StatCallType p0Calp1Cidp2Cidp3Float and it has %s.".
                    format(typeid(statAct), _statAction, statAct.callType));
        checkCid!DynamicConcept(caldron, _p1Cid);
        checkCid!DynamicConcept(caldron, _p2Cid);

        (cast(void function(Caldron, Cid, Cid, float))statAct.fp)(caldron, _p1Cid, _p2Cid, _p3Float);
    }

    /// Allow loading only static action using load(Cid statAction) of the SpA class.
    alias load = SpA.load;

    /**
            Set float value for a concept in the current namespace.
        Parameters:
            statActionCid = static action to perform
            p1 = first concept
            p2 = second concept
            p3 = float value
    */
    void load(Cid statActionCid, DcpDsc p1, DcpDsc p2, float p3) {
        checkCid!SpStaticConcept(statActionCid);
        checkCid!SpiritDynamicConcept(p1.cid);
        checkCid!SpiritDynamicConcept(p2.cid);

        _statAction = statActionCid;
        _p1Cid = p1.cid;
        _p2Cid = p2.cid;
        _p3Float = p3;
    }

    /// Partial setup, without the static action
    void load(DcpDsc p1, DcpDsc p2, float p3) {
        checkCid!SpiritDynamicConcept(p1.cid);
        checkCid!SpiritDynamicConcept(p2.cid);

        _p1Cid = p1.cid;
        _p2Cid = p2.cid;
        _p3Float = p3;
    }

    //---%%%---%%%---%%%---%%%---%%% data ---%%%---%%%---%%%---%%%---%%%---%%%

    // Parameter 1 - a concept cid.
    protected Cid _p1Cid;

    // Parameter 2 - a concept cid.
    protected Cid _p2Cid;

    // Parameter 2 - a float value
    protected float _p3Float;

    //---%%%---%%%---%%%---%%%---%%% funcs ---%%%---%%%---%%%---%%%---%%%---%%%

    /**
            Initialize concept from its serialized form.
        Parameters:
            stable = stable part of data
            transient = unstable part of data
        Returns: unconsumed slices of the stable and transient byte arrays.
    */
    protected override Tuple!(const byte[], "stable", const byte[], "transient") _deserialize(const byte[] stable,
            const byte[] transient)
    {
        _statAction = *cast(Cid*)&stable[St._statActionCid_ofs];
        _p1Cid = *cast(Cid*)&stable[St._p1Cid_ofs];
        _p2Cid = *cast(Cid*)&stable[St._p2Cid_ofs];
        _p3Float = *cast(float*)&stable[St._p3Float_ofs];

        return tuple!(const byte[], "stable", const byte[], "transient")(stable[St.length..$], transient);
    }

    //===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@
    //
    //                                  Private
    //
    //===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@

    /// Stable offsets. Used by serialize()/_deserialize()
    private enum St {
        _statActionCid_ofs = 0,
        _p1Cid_ofs = _statActionCid_ofs + _statAction.sizeof,
        _p2Cid_ofs = _p1Cid_ofs + _p1Cid.sizeof,
        _p3Float_ofs = _p2Cid_ofs + _p2Cid.sizeof,
        length = _p3Float_ofs + _p3Float.sizeof
    }

    /// Tranzient offsets. Used by serialize()/_deserialize()
    private enum Tr {
        length = 0
    }
}

unittest {
    auto a = new SpA_2CidFloat(42);
    a.ver = 5;
    a._statAction = 43;
    a._p1Cid = 44;
    a._p2Cid = 45;
    a._p3Float = 4.5;

    Serial ser = a.serialize;
    auto b = cast(SpA_2CidFloat)a.deserialize(ser.cid, ser.ver, ser.clid, ser.stable, ser.transient);
    assert(b.cid == 42 && b.ver == 5 && typeid(b) == typeid(SpA_2CidFloat) &&
            b._statAction == 43 && b._p1Cid == 44 && b._p2Cid == 45 && b._p3Float == 4.5);

    assert(a == b);
}

/// Live.
final class A_2CidFloat: A {

    /// Private constructor. Use live_factory() instead.
    private this(immutable SpA_2CidFloat spBinaryFloatAction) { super(spBinaryFloatAction); }
}

/// SpA - spirit action, CidInt - p0Calp1Cidp2Int
/// Action, that involves a concept and a float value
@(7) final class SpA_CidInt: SpA {

    /// Constructor
    this(Cid cid) { super(cid); }

    /// Create live wrapper for the holy static concept.
    override A_CidInt live_factory() const {
        return new A_CidInt(cast(immutable)this);
    }

    /// Serialize concept
    override Serial serialize() const {
        Serial res = super.serialize;

        res.stable.length = St.length;  // allocate
        *cast(Cid*)&res.stable[St._statActionCid_ofs] = _statAction;
        *cast(Cid*)&res.stable[St._p1Cid_ofs] = _p1Cid;
        *cast(int*)&res.stable[St._p2Int_ofs] = _p2Int;

        return res;
    }

    /// Equality test
    override bool opEquals(Object sc) const {

        if(!super.opEquals(sc)) return false;
        auto o = scast!(typeof(this))(sc);
        return _p1Cid == o._p1Cid && _p2Int == o._p2Int;
    }

    override string toString() const {
        string s = super.toString;
        s ~= format!"\n    _p1Cid = %s(%,?s)"(cptName(_p1Cid), '_', _p1Cid);
        s ~= format!"\n    _p2Int = %s"(_p2Int);
        return s;
    }

    //---***---***---***---***---***--- functions ---***---***---***---***---***--

    /// Run the static action.
    override void run(Caldron caldron) {
        auto statAct = (scast!SpStaticConcept(_sm_[_statAction]));
        assert(statAct.callType == StatCallType.p0Calp1Cidp2Int,
                "Static concept: %s( cid:%s) in SpAction must have StatCallType p0Calp1Cidp2Int and it has %s.".
                format(typeid(statAct), _statAction, statAct.callType));
        checkCid!DynamicConcept(caldron, _p1Cid);

        (cast(void function(Caldron, Cid, int))statAct.fp)(caldron, _p1Cid, _p2Int);
    }

    /// Allow loading only static action using load(Cid statAction) of the SpA class.
    alias load = SpA.load;

    /**
            Set int value for a concept in the current namespace.
        Parameters:
            statActionCid = static action to perform
            p1 = concept, that takes the int value
            p2 = int value
    */
    void load(Cid statActionCid, DcpDsc p1, int p2) {
        checkCid!SpStaticConcept(statActionCid);
        checkCid!SpiritDynamicConcept(p1.cid);

        _statAction = statActionCid;
        _p1Cid = p1.cid;
        _p2Int = p2;
    }

    /// Partial setup, without the static action
    void load(DcpDsc p1, int p2) {
        checkCid!SpiritDynamicConcept(p1.cid);

        _p1Cid = p1.cid;
        _p2Int = p2;
    }

    //---%%%---%%%---%%%---%%%---%%% data ---%%%---%%%---%%%---%%%---%%%---%%%

    // Parameter 1 - a concept cid.
    protected Cid _p1Cid;

    // Parameter 2 - a float value
    protected int _p2Int;

    //---%%%---%%%---%%%---%%%---%%% funcs ---%%%---%%%---%%%---%%%---%%%---%%%

    /**
            Initialize concept from its serialized form.
        Parameters:
            stable = stable part of data
            transient = unstable part of data
        Returns: unconsumed slices of the stable and transient byte arrays.
    */
    protected override Tuple!(const byte[], "stable", const byte[], "transient") _deserialize(const byte[] stable,
            const byte[] transient)
    {
        _statAction = *cast(Cid*)&stable[St._statActionCid_ofs];
        _p1Cid = *cast(Cid*)&stable[St._p1Cid_ofs];
        _p2Int = *cast(int*)&stable[St._p2Int_ofs];

        return tuple!(const byte[], "stable", const byte[], "transient")(stable[St.length..$], transient);
    }

    //===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@
    //
    //                                  Private
    //
    //===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@

    /// Stable offsets. Used by serialize()/_deserialize()
    private enum St {
        _statActionCid_ofs = 0,
        _p1Cid_ofs = _statActionCid_ofs + _statAction.sizeof,
        _p2Int_ofs = _p1Cid_ofs + _p1Cid.sizeof,
        length = _p2Int_ofs + _p2Int.sizeof
    }

    /// Tranzient offsets. Used by serialize()/_deserialize()
    private enum Tr {
        length = 0
    }
}

unittest {
    auto a = new SpA_CidInt(42);
    a.ver = 5;
    a._statAction = 43;
    a._p1Cid = 44;
    a._p2Int = 45;

    Serial ser = a.serialize;
    auto b = cast(SpA_CidInt)a.deserialize(ser.cid, ser.ver, ser.clid, ser.stable, ser.transient);
    assert(b.cid == 42 && b.ver == 5 && typeid(b) == typeid(SpA_CidInt) &&
            b._statAction == 43 && b._p1Cid == 44 && b._p2Int == 45);

    assert(a == b);
}

/// Live.
final class A_CidInt: A {

    /// Private constructor. Use live_factory() instead.
    private this(immutable SpA_CidInt spUnaryIntAction) { super(spUnaryIntAction); }
}
