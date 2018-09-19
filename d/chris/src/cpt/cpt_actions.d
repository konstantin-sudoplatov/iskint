module cpt_actions;
import std.stdio;
import std.format;

import global, tools;
import cpt_abstract, cpt_pile, cpt_premises;
import attn_circle_thread;

/**
            Base for all holy actions. The action concept is an interface, bridge between the world of cids and dynamic concepts,
    that knows nothing about the code and the static world, which is a big set of functions, that actually are the code.
    All concrete descendants will have the "_act" suffix.
*/
class SpAction: SpiritDynamicConcept {

    /**
                Constructor
        Parameters:
            cid = predefined concept identifier
    */
    this(Cid cid) { super(cid); }

    /// Create live wrapper for the holy static concept.
    override Action live_factory() const {
        return new Action(cast(immutable)this);
    }

    //---***---***---***---***---***--- functions ---***---***---***---***---***--

    /**
                Call static concept function.
        Parameters:
            caldron = name space it which static concept function will be working.
    */
    void run(Caldron caldron) {
        assert((cast(SpStaticConcept)_hm_[_statActionCid])._callType_ == StatCallType.p0Cal,
                format!"Static concept: %s( cid:%s) in HolyAction must have StatCallType none and it has %s."
                      (_nm_[_statActionCid], _statActionCid, (cast(SpStaticConcept)_hm_[_statActionCid])._callType_));

        auto statCpt = (cast(SpStaticConcept)_hm_[_statActionCid]);
        (cast(void function(Caldron))statCpt.fp)(caldron);
    }

    /// Full setup
    void load(Cid statAction) {
        checkCid!SpStaticConcept(statAction);
        _statActionCid = statAction;
    }

    /// Getter
    @property Cid statAction() {
        return _statActionCid;
    }

    /// Setter
    @property Cid statAction(Cid statActionCid) {
        debug checkCid!SpStaticConcept(statActionCid);
        return _statActionCid = statActionCid;
    }

    //---%%%---%%%---%%%---%%%---%%% data ---%%%---%%%---%%%---%%%---%%%---%%%

    // Static action.
    protected Cid _statActionCid;
}

/// Live.
class Action: DynamicConcept {

    /// Private constructor. Use HolyTidPrimitive.live_factory() instead.
    private this(immutable SpAction holyAction) { super(holyAction); }

    //---***---***---***---***---***--- functions ---***---***---***---***---***--

    /**
                Call static concept function.
        Parameters:
            caldron = name space it which static concept function will be working.
    */
    void run(Caldron caldron) {
        assert((cast(shared SpAction)sp).statAction != 0, format!"Cid: %s, static action must be assigned."(this.cid));

        (cast(shared SpAction)sp).run(caldron);
    }
}

/// Actions, that operate on only one concept. Examples: activate/anactivate concept.
final class SpUnaryAction: SpAction {

    /// Constructor
    this(Cid cid) { super(cid); }

    /// Create live wrapper for the holy static concept.
    override UnaryAction live_factory() const {
        return new UnaryAction(cast(immutable)this);
    }

    //---***---***---***---***---***--- functions ---***---***---***---***---***--

    /**
                Call static concept function.
        Parameters:
            caldron = name space it which static concept function will be working.
    */
    override void run(Caldron caldron) {
        assert((cast(SpStaticConcept)_hm_[_statActionCid])._callType_ == StatCallType.p0Calp1Cid,
                format!"Static concept: %s( cid:%s) in HolyAction must have StatCallType p0Calp1Cid and it has %s."
                      (typeid(_nm_[this._statActionCid]), _statActionCid,
                      (cast(SpStaticConcept)_hm_[_statActionCid])._callType_));

        auto statCpt = (cast(SpStaticConcept)_hm_[_statActionCid]);
        assert(operandCid_ != 0, "Operand must be assigned.");
        (cast(void function(Caldron, Cid))statCpt.fp)(caldron, operandCid_);
    }

    /// Full setup
    void load(Cid statAction, CptDescriptor operand) {
        checkCid!SpStaticConcept(statAction);
        _statActionCid = statAction;
        checkCid!SpiritDynamicConcept(operand.cid);
        operandCid_ = operand.cid;
    }

    /// Setter
    @property Cid operand(Cid cid) {
        checkCid!SpiritDynamicConcept(cid);
        return operandCid_ = cid;
    }

    /// Adapter
    @property Cid operand(CptDescriptor cd) {
        checkCid!SpiritDynamicConcept(cd.cid);
        return operandCid_ = cd.cid;
    }

    //---%%%---%%%---%%%---%%%---%%% data ---%%%---%%%---%%%---%%%---%%%---%%%

    /// Cid of a concept to operate on
    private Cid operandCid_;
}

/// Live.
final class UnaryAction: Action {

    /// Private constructor. Use live_factory() instead.
    private this(immutable SpUnaryAction spUnaryAction) { super(spUnaryAction); }

}

/// Actions, that operate on two concepts. Examples: sending a message - the first operand breed of the correspondent,
/// the second operand concept object to send.
final class SpBinaryAction: SpAction {

    /// Constructor
    this(Cid cid) { super(cid); }

    /// Create live wrapper for the holy static concept.
    override BinaryAction live_factory() const {
        return new BinaryAction(cast(immutable)this);
    }

    //---***---***---***---***---***--- functions ---***---***---***---***---***--

    /**
                Call static concept function.
        Parameters:
            caldron = name space it which static concept function will be working.
    */
    override void run(Caldron caldron) {
        assert((cast(SpStaticConcept)_hm_[statAction])._callType_ == StatCallType.p0Calp1Cidp2Cid,
                format!"Static concept: %s( cid:%s) in HolyAction must have StatCallType p0Calp1Cidp2Cid and it has %s."
                      (typeid(_nm_[this.statAction]), statAction,
                      (cast(SpStaticConcept)_hm_[statAction])._callType_));

        auto statCpt = (cast(SpStaticConcept)_hm_[_statActionCid]);
        assert(firstOperandCid_ != 0, "Operand must be assigned.");
        assert(secondOperandCid_ != 0, "Operand must be assigned.");
        (cast(void function(Caldron, Cid, Cid))statCpt.fp)(caldron, firstOperandCid_, secondOperandCid_);
    }

    /// Full setup
    void load(Cid statAction, CptDescriptor firstOperand, CptDescriptor secondOperand) {
        checkCid!SpStaticConcept(statAction);

        _statActionCid = statAction;
        checkCid!SpiritDynamicConcept(firstOperand.cid);
        firstOperandCid_ = firstOperand.cid;
        checkCid!SpiritDynamicConcept(secondOperand.cid);
        secondOperandCid_ = secondOperand.cid;
    }

    /// Setter
    @property Cid firstOperand(Cid cid) {
        checkCid!SpiritDynamicConcept(cid);
        return firstOperandCid_ = cid;
    }

    /// Adapter
    @property Cid firstOperand(CptDescriptor cd) {
        checkCid!SpiritDynamicConcept(cd.cid);
        return firstOperandCid_ = cd.cid;
    }

    /// Setter
    @property Cid secondOperand(Cid cid) {
        checkCid!SpiritDynamicConcept(cid);
        return secondOperandCid_ = cid;
    }

    /// Adapter
    @property Cid secondOperand(CptDescriptor cd) {
        checkCid!SpiritDynamicConcept(cd.cid);
        return secondOperandCid_ = cd.cid;
    }

    //---%%%---%%%---%%%---%%%---%%% data ---%%%---%%%---%%%---%%%---%%%---%%%

    /// Cid of the first concept
    private Cid firstOperandCid_;

    /// Cid of the second concept
    private Cid secondOperandCid_;
}

/// Live.
final class BinaryAction: Action {

    /// Private constructor. Use live_factory() instead.
    private this(immutable SpBinaryAction spBinaryAction) { super(spBinaryAction); }
}

/// Sets activation value in the local and remote branches.
final class SpSetActivation: SpAction {

    /// Constructor
    this(Cid cid) { super(cid); }

    /// Create live wrapper for the holy static concept.
    override SetActivation live_factory() const {
        return new SetActivation(cast(immutable)this);
    }

    //---***---***---***---***---***--- functions ---***---***---***---***---***--

    override void run(Caldron caldron) {

        SpStaticConcept statCpt = cast(SpStaticConcept)_hm_[_statActionCid];
        if      // isn't the destination breed setup?
                (destBreedCid_ == 0)
        {   // no: do it locally
            assert((cast(SpStaticConcept)_hm_[statAction])._callType_ == StatCallType.p0Calp1Cidp2Float,
                format!"Static concept: %s( cid:%s) in HolyAction must have StatCallType p0Calp1Cidp2Float and it has %s."
                      (typeid(_nm_[this.statAction]), statAction, (cast(SpStaticConcept)_hm_[statAction])._callType_));

            (cast(void function(Caldron, Cid, float))statCpt.fp)(caldron, destConceptCid_, activation_);
        }
        else {  //yes: do it remotely
            assert((cast(SpStaticConcept)_hm_[statAction])._callType_ == StatCallType.p0Calp1Cidp2Cidp3Float,
                format!"Static concept: %s( cid:%s) in HolyAction must have StatCallType p0Calp1Cidp2Cidp3Float and it has %s."
                      (typeid(_nm_[this.statAction]), statAction, (cast(SpStaticConcept)_hm_[statAction])._callType_));

            (cast(void function(Caldron, Cid, Cid, float))statCpt.fp)(caldron, destBreedCid_, destConceptCid_, activation_);
        }
    }

    /**
            Set activation for a concept in the current namespace.
        Parameters:
            destConceptCid = concept to set activation
            activation = activation value
    */
    void load(Cid statAction, CptDescriptor destConcept, float activation) {
        checkCid!SpStaticConcept(statAction);

        _statActionCid = statAction;
        destConceptCid_ = destConcept.cid;
        activation_ = activation;
    }

    /**
            Set activation for a concept in the remote namespace.
        Parameters:
            destBreedCid = destination branch
            destConceptCid = concept to set activation
            activation = activation value
    */
    void load(Cid statAction, CptDescriptor destBreed, CptDescriptor destConcept, float activation) {
        checkCid!SpStaticConcept(statAction);
        checkCid!SpBreed(destBreed.cid);

        _statActionCid = statAction;
        destBreedCid_ = destBreed.cid;
        destConceptCid_ = destConcept.cid;
        activation_ = activation;
    }

    //---%%%---%%%---%%%---%%%---%%% data ---%%%---%%%---%%%---%%%---%%%---%%%

    // Defines destination. If the destination is the current branch, this field remains 0.
    private Cid destBreedCid_;

    // Destination concept. It must implement one of the forms of the ActivationIfc interface.
    private Cid destConceptCid_;

    // Activation value. It must be +1/-1 for bin activation or a arbitrary value for esquash.
    private float activation_;
}

/// Live.
final class SetActivation: Action {

    /// Private constructor. Use live_factory() instead.
    private this(immutable SpSetActivation spSetActivation) { super(spSetActivation); }
}

//---***---***---***---***---***--- types ---***---***---***---***---***---***

//---***---***---***---***---***--- data ---***---***---***---***---***--

/**
        Constructor
*/
//this(){}

//---***---***---***---***---***--- functions ---***---***---***---***---***--

//~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$
//
//                                 Protected
//
//~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$
protected:
//---$$$---$$$---$$$---$$$---$$$--- data ---$$$---$$$---$$$---$$$---$$$--

//---$$$---$$$---$$$---$$$---$$$--- functions ---$$$---$$$---$$$---$$$---$$$---

//---$$$---$$$---$$$---$$$---$$$--- types ---$$$---$$$---$$$---$$$---$$$---

//===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@
//
//                                  Private
//
//===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@
private:
//---%%%---%%%---%%%---%%%---%%% data ---%%%---%%%---%%%---%%%---%%%---%%%

//---%%%---%%%---%%%---%%%---%%% functions ---%%%---%%%---%%%---%%%---%%%---%%%--

//---%%%---%%%---%%%---%%%---%%% types ---%%%---%%%---%%%---%%%---%%%---%%%--
