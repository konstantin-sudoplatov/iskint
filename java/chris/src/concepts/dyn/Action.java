package concepts.dyn;

import attention.ConceptNameSpace;
import concepts.DynamicConcept;
import concepts.StaticAction;

/**
 * All that needed to invoke the static concept processing. This concept is stateless, i.e. it cannot be used as a premise or a data source.
 * @author su
 */
public class Action extends DynamicConcept {

    //---***---***---***---***---***--- public classes ---***---***---***---***---***---***

    //---***---***---***---***---***--- public data ---***---***---***---***---***--

    /**
     * Constructor.
     * @param statActionCid cid of the static concept
     */
    public Action(long statActionCid) {
        this._statActionCid_ = statActionCid;
    }

    //^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v
    //
    //                                  Public methods
    //
    //v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^

    /**
     * Invoke the function of the static concept functor.
     * @param nameSpace
     */
    public void go(ConceptNameSpace nameSpace) {
        ((StaticAction)nameSpace.get_cpt(_statActionCid_)).go(nameSpace, null, null);
    }
//    
//    /** 
//     * Append new cid to paramCids.
//     * @param cid 
//     */
//    public void add_parameter(long cid) {
//        Glob.append_array(paramCids, cid);
//    }
    
    //~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$
    //
    //      Protected    Protected    Protected    Protected    Protected    Protected
    //
    //~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$

    //---$$$---$$$---$$$---$$$---$$$--- protected data $$$---$$$---$$$---$$$---$$$---$$$--

    /** Concept, that provides the processing. */
    protected final long _statActionCid_;

    //---$$$---$$$---$$$---$$$---$$$--- protected methods ---$$$---$$$---$$$---$$$---$$$---

    //###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%
    //
    //      Private    Private    Private    Private    Private    Private    Private
    //
    //###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%

    //---%%%---%%%---%%%---%%%---%%% private data %%%---%%%---%%%---%%%---%%%---%%%---%%%
    
//    /** Array of parameters to the static concept. */
//    private long[] paramCids;
    
    //---%%%---%%%---%%%---%%%---%%% private methods ---%%%---%%%---%%%---%%%---%%%---%%%--

    //---%%%---%%%---%%%---%%%---%%% private classes ---%%%---%%%---%%%---%%%---%%%---%%%--
}
