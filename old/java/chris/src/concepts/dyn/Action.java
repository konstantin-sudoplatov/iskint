package concepts.dyn;

import attention.ConceptNameSpace;
import chris.Glob;
import concepts.DynamicConcept;
import concepts.SCN;
import concepts.StaticAction;
import java.util.List;

/**
 * Call static action without parameters and return value.
 * @author su
 */
public class Action extends DynamicConcept {

    //---***---***---***---***---***--- public classes ---***---***---***---***---***---***

    //---***---***---***---***---***--- public data ---***---***---***---***---***--

    /**
     * Constructor.
     */
    public Action(){}

    /**
     * Constructor.
     * @param statAction as it is presented in the SCN enum.
     */
    public Action(SCN statAction) {
        this._statActionCid_ = statAction.ordinal();
    }
    
    //^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v
    //
    //                                  Public methods
    //
    //v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^

    /**
     * Invoke the function of the static concept functor without parameter and return cids.
     * @param nameSpace
     */
    public void go(ConceptNameSpace nameSpace) {
        resultCids = ((StaticAction)nameSpace.load_cpt(_statActionCid_)).go(nameSpace, null, null);
    }

    /**
     * Get the static action cid.
     * @return 
     */
    public long get_stat_action() {
        return _statActionCid_;
    }
    
    /**
     * Set static action.
     * @param statAction as the SCN enum.
     */
    public void set_static_action(SCN statAction) {
        _statActionCid_ = statAction.ordinal();
    }
    
    /**
     * Get array of parameter cids.
     * @return parameters
     */
    public long[] get_parameters() {
        return null;
    }
    
    /**
     * Get the extra parameter.
     * @return extra
     */
    public Object get_extra() {
        return null;
    }
    
    /**
     * Getter.
     * @return result cids array. 
     */
    public long[] get_result_cids() {
        return resultCids;
    }

    /**
     * Create list of lines, which shows the object's content. For debugging. Invoked from Glob.print().
     * @param note printed in the first line just after the object type.
     * @param debugLevel 0 - the shortest, 2 - the fullest
     * @return list of lines, describing this object.
     */
    @Override
    public List<String> to_list_of_lines(String note, Integer debugLevel) {
        List<String> lst = super.to_list_of_lines(note, debugLevel);
        if (debugLevel >= 0) {
            Glob.add_line(lst, String.format("_statActionCid_ = %s", _statActionCid_));
            Glob.add_list_of_lines(lst, "resultCids", resultCids, debugLevel-1);
        }
        
        return lst;
    }
    
    //~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$
    //
    //      Protected    Protected    Protected    Protected    Protected    Protected
    //
    //~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$

    //---$$$---$$$---$$$---$$$---$$$--- protected data $$$---$$$---$$$---$$$---$$$---$$$--

    /** Static concept, that provides the processing. */
    protected long _statActionCid_;

    //---$$$---$$$---$$$---$$$---$$$--- protected methods ---$$$---$$$---$$$---$$$---$$$---

    //###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%
    //
    //      Private    Private    Private    Private    Private    Private    Private
    //
    //###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%

    //---%%%---%%%---%%%---%%%---%%% private data %%%---%%%---%%%---%%%---%%%---%%%---%%%
    
    private long[] resultCids;
    
    //---%%%---%%%---%%%---%%%---%%% private methods ---%%%---%%%---%%%---%%%---%%%---%%%--

    //---%%%---%%%---%%%---%%%---%%% private classes ---%%%---%%%---%%%---%%%---%%%---%%%--
}
